#!/usr/bin/env bash
# Compatible with macOS Bash 3.2+
set -euo pipefail

show_help() {
  echo "Usage: $(basename "$0") [--dry-run|-n] [links.txt] [excludes.txt]"
  echo
  echo "Symlink dotfiles from my-env/... into \$HOME according to links.txt."
  echo
  echo "links.txt lines: <source> <target>   (paths relative to my-env/ and \$HOME)"
  echo "  - If <target> ends with '/', or <source> contains a glob (* ? [ ]), the line"
  echo "    is treated as a CONTAINER mapping:"
  echo "      • 'vim/* .vim/'  -> ensure \$HOME/.vim exists; link each child under my-env/vim/"
  echo "                          into \$HOME/.vim/<child>"
  echo "      • 'bin/* bin'    -> same (container recognized from glob, even without '/')"
  echo "  - Otherwise it's a one-to-one mapping:"
  echo "      • 'vim .vim'     -> link my-env/vim (dir or file) to \$HOME/.vim"
  echo
  echo "Safeties:"
  echo "  • For CONTAINER mappings, if the container path (e.g. \$HOME/bin) is a SYMLINK,"
  echo "    the script removes that symlink (safe; does NOT delete the target), creates a real"
  echo "    directory, then proceeds to link children."
  echo "  • Never removes anything inside the source tree (my-env/)."
  echo
  echo "Use --dry-run or -n to preview actions without making changes."
}

DRY_RUN=0
LINKS_FILE=""
EXCLUDES_FILE=""

# ---------- CLI ----------
while [[ $# -gt 0 ]]; do
  case "$1" in
  --dry-run | -n)
    DRY_RUN=1
    shift
    ;;
  -h | --help)
    show_help
    exit 0
    ;;
  *)
    if [[ -z "$LINKS_FILE" ]]; then LINKS_FILE="$1"; else EXCLUDES_FILE="$1"; fi
    shift
    ;;
  esac
done

# ---------- Locate repo root ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
MY_ENV_DIR="$(cd "$SCRIPT_DIR/.." && pwd -P)"

LINKS_FILE="${LINKS_FILE:-$MY_ENV_DIR/links.txt}"
EXCLUDES_FILE="${EXCLUDES_FILE:-$MY_ENV_DIR/excludes.txt}"

[[ -f "$LINKS_FILE" ]] || {
  echo "links.txt not found: $LINKS_FILE"
  exit 1
}

# ---------- Excludes ----------
declare -a EXCLUDES=()
if [[ -f "$EXCLUDES_FILE" ]]; then
  while IFS= read -r pat || [[ -n "$pat" ]]; do
    pat="${pat%$'\r'}" # strip CR
    # trim
    pat="${pat#"${pat%%[![:space:]]*}"}"
    pat="${pat%"${pat##*[![:space:]]}"}"
    [[ -z "$pat" ]] && continue
    case "$pat" in \#*) continue ;; esac
    EXCLUDES+=("$MY_ENV_DIR/$pat")
  done <"$EXCLUDES_FILE"
fi

should_exclude() {
  local path="$1" pat
  for pat in ${EXCLUDES[@]+"${EXCLUDES[@]}"}; do
    # glob match against absolute pattern
    if [[ $path == $pat ]]; then
      return 0
    fi
  done
  return 1
}

# ---------- Helpers (portable) ----------
# Physical absolute path for an arbitrary path (file or dir); prints empty on failure
phys_abs() {
  local p="$1"
  local dir base
  dir="$(dirname "$p")"
  base="$(basename "$p")"
  if dir="$(cd "$dir" 2>/dev/null && pwd -P)"; then
    printf "%s/%s" "$dir" "$base"
  else
    printf ""
  fi
}

# Is path physically under base?
is_under() {
  local path="$1" base="$2"
  [[ -e "$path" ]] || return 1
  local p_abs b_abs
  p_abs="$(phys_abs "$path")" || return 1
  b_abs="$(cd "$base" 2>/dev/null && pwd -P)" || return 1
  case "$p_abs" in "$b_abs" | "$b_abs"/*) return 0 ;; *) return 1 ;; esac
}

# Does the source string contain a glob?
is_glob() {
  case "$1" in *\** | *?* | *[*]*) return 0 ;; *) return 1 ;; esac
}

# ---------- Dry-run mkdir de-dup (string registry, Bash 3.2 safe) ----------
DRY_CREATED_DIRS=":" # colon-delimited set, e.g., ":/path1:/path2:"
dry_dir_print_once() {
  local d=":$1:"
  case "$DRY_CREATED_DIRS" in
  *"$d"*) return 1 ;;
  *)
    DRY_CREATED_DIRS="${DRY_CREATED_DIRS}$1:"
    return 0
    ;;
  esac
}

# Holds the active container base during DRY-RUN so kids are treated as if
# the container symlink has already been removed.
ACTIVE_DRY_CONTAINER_BASE=""

# ---------- Action reporters ----------
dry_run_report() {
  local real_src="$1" target="$2"

  # In container dry-run mode: treat as if the container symlink was removed,
  # but still check what's currently at the child target.
  if [[ -n "$ACTIVE_DRY_CONTAINER_BASE" ]]; then
    case "$target" in
    "$ACTIVE_DRY_CONTAINER_BASE" | "$ACTIVE_DRY_CONTAINER_BASE"/*)
      if [[ -L "$target" ]]; then
        local link_target
        link_target="$(readlink "$target")"
        if [[ "$link_target" == "$real_src" ]]; then
          echo "[DRY-RUN] Symlink exists: $target -> $link_target"
        else
          echo "[DRY-RUN] Would replace symlink: $target (currently $link_target) -> $real_src"
        fi
        return 0
      elif [[ -e "$target" ]]; then
        if [[ -d "$target" ]]; then
          echo "[DRY-RUN] Would remove directory and its content: $target"
          echo "[DRY-RUN] Would create symlink: $real_src -> $target"
        else
          echo "[DRY-RUN] Would overwrite file: $target"
          echo "[DRY-RUN] Would create symlink: $real_src -> $target"
        fi
        return 0
      else
        echo "[DRY-RUN] Would create symlink: $real_src -> $target"
        return 0
      fi
      ;;
    esac
  fi

  # Normal dry-run safety/reporting
  if [[ -e "$target" && ! -L "$target" ]] && is_under "$target" "$MY_ENV_DIR"; then
    echo "[DRY-RUN] SKIP: Target inside source tree (refuse to remove): $target"
    return 0
  fi

  if [[ -L "$target" ]]; then
    local link_target
    link_target="$(readlink "$target")"
    if [[ "$link_target" == "$real_src" ]]; then
      echo "[DRY-RUN] Symlink exists: $target -> $link_target"
    else
      echo "[DRY-RUN] Would replace symlink: $target (currently $link_target) -> $real_src"
    fi
  elif [[ -e "$target" ]]; then
    if [[ -d "$target" ]]; then
      echo "[DRY-RUN] Would remove directory and its content: $target"
      echo "[DRY-RUN] Would create symlink: $real_src -> $target"
    else
      echo "[DRY-RUN] Would overwrite file: $target"
      echo "[DRY-RUN] Would create symlink: $real_src -> $target"
    fi
  else
    echo "[DRY-RUN] Would create symlink: $real_src -> $target"
  fi
}

maybe_create_dir() {
  local dir="$1"
  if [[ $DRY_RUN -eq 1 ]]; then
    if [[ ! -d "$dir" ]] && dry_dir_print_once "$dir"; then
      echo "[DRY-RUN] Would create directory: $dir"
    fi
  else
    if [[ ! -d "$dir" ]]; then
      mkdir -p "$dir"
      echo "Created directory: $dir"
    fi
  fi
}

# Container setup: remove symlink container safely, ensure directory exists
ensure_container_dir() {
  local CONTAINER_DIR="$1" # cleaned (no trailing /)
  if [[ $DRY_RUN -eq 1 ]]; then
    ACTIVE_DRY_CONTAINER_BASE="$CONTAINER_DIR"
    if [[ -L "$CONTAINER_DIR" ]]; then
      echo "[DRY-RUN] Would remove symlink: $CONTAINER_DIR"
      if dry_dir_print_once "$CONTAINER_DIR"; then
        echo "[DRY-RUN] Would create directory: $CONTAINER_DIR"
      fi
    elif [[ -e "$CONTAINER_DIR" && ! -d "$CONTAINER_DIR" ]]; then
      echo "[DRY-RUN] Would overwrite file: $CONTAINER_DIR"
      if dry_dir_print_once "$CONTAINER_DIR"; then
        echo "[DRY-RUN] Would create directory: $CONTAINER_DIR"
      fi
    elif [[ ! -d "$CONTAINER_DIR" ]]; then
      if dry_dir_print_once "$CONTAINER_DIR"; then
        echo "[DRY-RUN] Would create directory: $CONTAINER_DIR"
      fi
    fi
  else
    ACTIVE_DRY_CONTAINER_BASE=""
    if [[ -L "$CONTAINER_DIR" ]]; then
      rm -f -- "$CONTAINER_DIR"
      mkdir -p -- "$CONTAINER_DIR"
      echo "Converted container symlink to directory: $CONTAINER_DIR"
    elif [[ -e "$CONTAINER_DIR" && ! -d "$CONTAINER_DIR" ]]; then
      rm -f -- "$CONTAINER_DIR"
      mkdir -p -- "$CONTAINER_DIR"
      echo "Replaced file with directory: $CONTAINER_DIR"
    else
      mkdir -p -- "$CONTAINER_DIR"
    fi
  fi
}

link_one() {
  local real_src="$1" TARGET_PATH="$2"
  local parent
  parent="$(dirname "$TARGET_PATH")"
  maybe_create_dir "$parent"

  if [[ $DRY_RUN -eq 1 ]]; then
    dry_run_report "$real_src" "$TARGET_PATH"
    return 0
  fi

  # Safety: never remove anything inside source tree
  if [[ -e "$TARGET_PATH" && ! -L "$TARGET_PATH" ]] && is_under "$TARGET_PATH" "$MY_ENV_DIR"; then
    echo "ERROR: Refusing to remove path inside source tree: $TARGET_PATH"
    return 1
  fi

  if [[ -e "$TARGET_PATH" && ! -L "$TARGET_PATH" ]]; then
    if [[ -d "$TARGET_PATH" ]]; then
      echo "Removing directory and its content: $TARGET_PATH"
      rm -rf -- "$TARGET_PATH"
    else
      echo "Overwriting file: $TARGET_PATH"
      rm -f -- "$TARGET_PATH"
    fi
  fi

  if [[ -L "$TARGET_PATH" && "$(readlink "$TARGET_PATH")" == "$real_src" ]]; then
    echo "Symlink exists: $TARGET_PATH"
    return 0
  fi

  ln -sfn "$real_src" "$TARGET_PATH"
  echo "Linked: $real_src -> $TARGET_PATH"
}

# ---------- Main ----------
while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%$'\r'}"
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  [[ -z "$line" ]] && continue
  case "$line" in \#*) continue ;; esac

  # Parse exactly two fields WITHOUT expanding globs
  src=""
  tgt=""
  IFS=' ' read -r src tgt <<<"$line"
  [[ -z "$src" || -z "$tgt" ]] && continue

  src_glob_abs="$MY_ENV_DIR/$src"

  shopt -s nullglob
  matched=($src_glob_abs)
  shopt -u nullglob
  [[ ${#matched[@]} -eq 0 ]] && matched=("$src_glob_abs")

  # Determine mapping type
  is_container=0
  if [[ "${tgt%/}" != "$tgt" ]] || is_glob "$src"; then
    is_container=1
  fi

  # Reset per-line dry container base
  ACTIVE_DRY_CONTAINER_BASE=""

  if [[ $is_container -eq 1 ]]; then
    CONTAINER_DIR="$HOME/$tgt"
    CONTAINER_DIR="${CONTAINER_DIR%/}" # normalize
    ensure_container_dir "$CONTAINER_DIR"
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "[DRY-RUN] Container mapping into: $CONTAINER_DIR"
    fi
  fi

  for real_src in "${matched[@]}"; do
    if [[ ! -e "$real_src" ]]; then
      echo "WARN: Source does not exist: $real_src"
      continue
    fi
    if should_exclude "$real_src"; then
      echo "Excluded: $real_src"
      continue
    fi

    if [[ $is_container -eq 1 ]]; then
      if is_glob "$src"; then
        TARGET_PATH="$CONTAINER_DIR/$(basename "$real_src")"
      else
        rel_path="${real_src:${#MY_ENV_DIR}+1}"
        TARGET_PATH="$CONTAINER_DIR/$rel_path"
        maybe_create_dir "$(dirname "$TARGET_PATH")"
      fi
    else
      TARGET_PATH="$HOME/$tgt"
    fi

    link_one "$real_src" "$TARGET_PATH"
  done
done <"$LINKS_FILE"
