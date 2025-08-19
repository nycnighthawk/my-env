#!/usr/bin/env bash
# Works on macOS (Bash 3.2+) and Linux (Bash 4+)
set -euo pipefail

show_help() {
  echo "Usage: $(basename "$0") [--dry-run|-n] [links.txt] [excludes.txt]"
  echo
  echo "Symlink dotfiles from my-env/... into \$HOME according to links.txt."
  echo
  echo "links.txt lines: <source> <target>   (paths relative to my-env/ and \$HOME)"
  echo
  echo "Mapping types:"
  echo "  • CONTAINER (source has a glob: *, ?, [ )"
  echo "     - 'vim/* .vim/' or 'bin/* bin' -> ensure container dir exists in \$HOME,"
  echo "       then link each child under my-env/vim/ into \$HOME/.vim/<child>."
  echo "  • ONE-TO-ONE (no glob in source), with trailing '/' semantics like cp:"
  echo "     - DIR + 'bin/': link my-env/bin -> \$HOME/bin"
  echo "     - FILE + '.vim/': ensure \$HOME/.vim, then link inside by basename"
  echo "     - Plain 'bin bin': link my-env/bin -> \$HOME/bin"
  echo
  echo "Safeties:"
  echo "  • If a container path (e.g. \$HOME/bin) is a SYMLINK, remove that symlink only (safe),"
  echo "    create a real directory, then link children."
  echo "  • Never removes anything inside the source tree (my-env/)."
  echo "  • Prevents indirect writes into the repo: after a one-to-one directory link"
  echo "    (e.g. 'bin bin'), any later mapping targeting under ~/bin (e.g. 'vim bin/vim')"
  echo "    is rejected."
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

# ---------- Resolve script root even if this script is a SYMLINK (BSD + GNU friendly) ----------
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  SRC_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  LINK_TARGET="$(readlink "$SOURCE")"
  case "$LINK_TARGET" in
  /*) SOURCE="$LINK_TARGET" ;;
  *) SOURCE="$SRC_DIR/$LINK_TARGET" ;;
  esac
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
MY_ENV_DIR="$(cd "$SCRIPT_DIR/.." && pwd -P)"

# ---------- Inputs ----------
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
    pat="${pat%$'\r'}"
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
    if [[ $path == $pat ]]; then
      return 0
    fi
  done
  return 1
}

# ---------- Helpers ----------
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

is_under() {
  local path="$1" base="$2"
  [[ -e "$path" ]] || return 1
  local p_abs b_abs
  p_abs="$(phys_abs "$path")" || return 1
  b_abs="$(cd "$base" 2>/dev/null && pwd -P)" || return 1
  case "$p_abs" in "$b_abs" | "$b_abs"/*) return 0 ;; *) return 1 ;; esac
}

# Detect literal glob characters (works on macOS & Linux)
is_glob() {
  case "$1" in *\** | *\?* | *\[*) return 0 ;; *) return 1 ;; esac
}

# ---------- Planned anchors (one-to-one directory links into repo) ----------
PLANNED_ANCHORS="" # lines "TARGET_ABS|SOURCE_ABS\n"
add_planned_anchor() {
  local anchor_t="$1" anchor_s="$2"
  PLANNED_ANCHORS="${PLANNED_ANCHORS}${anchor_t}|${anchor_s}"$'\n'
}
FOUND_ANCHOR_T=""
FOUND_ANCHOR_S=""
match_planned_anchor() {
  local p="$1"
  FOUND_ANCHOR_T=""
  FOUND_ANCHOR_S=""
  local IFS=$'\n'
  for entry in $PLANNED_ANCHORS; do
    [[ -z "$entry" ]] && continue
    IFS='|' read -r a_t a_s <<<"$entry"
    [[ -z "$a_t" || -z "$a_s" ]] && continue
    case "$p" in
    "$a_t")
      FOUND_ANCHOR_T="$a_t"
      FOUND_ANCHOR_S="$a_s"
      return 0
      ;;
    "$a_t"/*)
      FOUND_ANCHOR_T="$a_t"
      FOUND_ANCHOR_S="$a_s"
      return 0
      ;;
    esac
  done
  return 1
}

# ---------- Dry-run mkdir de-dup ----------
DRY_CREATED_DIRS=":" # colon-delimited set
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

# ---------- Summary counters ----------
declare -i CNT_BLOCKED_RISK=0
declare -i CNT_UNCHANGED=0
declare -i CNT_LINKED=0
declare -i CNT_DIR_PLANNED_OR_CREATED=0
BLOCKED_RISK_LIST=""

note_blocked_risk() {
  CNT_BLOCKED_RISK=$((CNT_BLOCKED_RISK + 1))
  BLOCKED_RISK_LIST="${BLOCKED_RISK_LIST}$1"$'\n'
}
note_unchanged() { CNT_UNCHANGED=$((CNT_UNCHANGED + 1)); }
note_linked() { CNT_LINKED=$((CNT_LINKED + 1)); }
note_dir_made() { CNT_DIR_PLANNED_OR_CREATED=$((CNT_DIR_PLANNED_OR_CREATED + 1)); }

# Holds the active container base during DRY-RUN so kids are treated as if the container symlink has already been removed.
ACTIVE_DRY_CONTAINER_BASE=""

# ---------- Action reporters ----------
dry_run_report() {
  local real_src="$1" target="$2"

  # Respect planned anchors: if under an anchor and not the anchor itself, SKIP (protect)
  if match_planned_anchor "$target"; then
    if [[ "$target" != "$FOUND_ANCHOR_T" ]]; then
      echo "[PROTECT][DRY-RUN] SKIP: Target under planned repo symlink anchor: $FOUND_ANCHOR_T -> $FOUND_ANCHOR_S (target $target)"
      note_blocked_risk "$target"
      return 0
    fi
  fi

  # In container dry-run mode: act as if container symlink already removed
  if [[ -n "$ACTIVE_DRY_CONTAINER_BASE" ]]; then
    case "$target" in
    "$ACTIVE_DRY_CONTAINER_BASE" | "$ACTIVE_DRY_CONTAINER_BASE"/*)
      if [[ -L "$target" ]]; then
        local link_target
        link_target="$(readlink "$target")"
        if [[ "$link_target" == "$real_src" ]]; then
          echo "[DRY-RUN] Symlink exists: $target -> $link_target"
          note_unchanged
        else
          echo "[DRY-RUN] Would replace symlink: $target (currently $link_target) -> $real_src"
          note_linked
        fi
        return 0
      elif [[ -e "$target" ]]; then
        if [[ -d "$target" ]]; then
          echo "[DRY-RUN] Would remove directory and its content: $target"
          echo "[DRY-RUN] Would create symlink: $real_src -> $target"
          note_linked
        else
          echo "[DRY-RUN] Would overwrite file: $target"
          echo "[DRY-RUN] Would create symlink: $real_src -> $target"
          note_linked
        fi
        return 0
      else
        echo "[DRY-RUN] Would create symlink: $real_src -> $target"
        note_linked
        return 0
      fi
      ;;
    esac
  fi

  # Normal dry-run safety/reporting
  if [[ -e "$target" && ! -L "$target" ]] && is_under "$target" "$MY_ENV_DIR"; then
    echo "[PROTECT][DRY-RUN] SKIP: Target inside source tree (refuse to remove): $target"
    note_blocked_risk "$target"
    return 0
  fi

  if [[ -L "$target" ]]; then
    local link_target
    link_target="$(readlink "$target")"
    if [[ "$link_target" == "$real_src" ]]; then
      echo "[DRY-RUN] Symlink exists: $target -> $link_target"
      note_unchanged
    else
      echo "[DRY-RUN] Would replace symlink: $target (currently $link_target) -> $real_src"
      note_linked
    fi
  elif [[ -e "$target" ]]; then
    if [[ -d "$target" ]]; then
      echo "[DRY-RUN] Would remove directory and its content: $target"
      echo "[DRY-RUN] Would create symlink: $real_src -> $target"
      note_linked
    else
      echo "[DRY-RUN] Would overwrite file: $target"
      echo "[DRY-RUN] Would create symlink: $real_src -> $target"
      note_linked
    fi
  else
    echo "[DRY-RUN] Would create symlink: $real_src -> $target"
    note_linked
  fi
}

maybe_create_dir() {
  local dir="$1"
  if [[ $DRY_RUN -eq 1 ]]; then
    if [[ ! -d "$dir" ]] && dry_dir_print_once "$dir"; then
      echo "[DRY-RUN] Would create directory: $dir"
      note_dir_made
    fi
  else
    if [[ ! -d "$dir" ]]; then
      mkdir -p "$dir"
      echo "Created directory: $dir"
      note_dir_made
    fi
  fi
}

ensure_container_dir() {
  local CONTAINER_DIR="$1" # cleaned (no trailing /)
  if [[ $DRY_RUN -eq 1 ]]; then
    ACTIVE_DRY_CONTAINER_BASE="$CONTAINER_DIR"
    if [[ -L "$CONTAINER_DIR" ]]; then
      echo "[DRY-RUN] Would remove symlink: $CONTAINER_DIR"
      if dry_dir_print_once "$CONTAINER_DIR"; then
        echo "[DRY-RUN] Would create directory: $CONTAINER_DIR"
        note_dir_made
      fi
    elif [[ -e "$CONTAINER_DIR" && ! -d "$CONTAINER_DIR" ]]; then
      echo "[DRY-RUN] Would overwrite file: $CONTAINER_DIR"
      if dry_dir_print_once "$CONTAINER_DIR"; then
        echo "[DRY-RUN] Would create directory: $CONTAINER_DIR"
        note_dir_made
      fi
    elif [[ ! -d "$CONTAINER_DIR" ]]; then
      if dry_dir_print_once "$CONTAINER_DIR"; then
        echo "[DRY-RUN] Would create directory: $CONTAINER_DIR"
        note_dir_made
      fi
    fi
  else
    ACTIVE_DRY_CONTAINER_BASE=""
    if [[ -L "$CONTAINER_DIR" ]]; then
      rm -f -- "$CONTAINER_DIR"
      mkdir -p -- "$CONTAINER_DIR"
      echo "Converted container symlink to directory: $CONTAINER_DIR"
      note_dir_made
    elif [[ -e "$CONTAINER_DIR" && ! -d "$CONTAINER_DIR" ]]; then
      rm -f -- "$CONTAINER_DIR"
      mkdir -p -- "$CONTAINER_DIR"
      echo "Replaced file with directory: $CONTAINER_DIR"
      note_dir_made
    else
      mkdir -p -- "$CONTAINER_DIR"
      note_dir_made
    fi
  fi
}

# Block targets that would land under:
#   (a) a PLANNED one-to-one dir link into repo, or
#   (b) an EXISTING symlink that resolves into repo.
guard_target_allowed() {
  local target="$1"

  # 1) Planned anchors
  if match_planned_anchor "$target"; then
    if [[ "$target" != "$FOUND_ANCHOR_T" ]]; then
      if [[ $DRY_RUN -eq 1 ]]; then
        echo "[PROTECT][DRY-RUN] SKIP: Target under planned repo symlink anchor: $FOUND_ANCHOR_T -> $FOUND_ANCHOR_S (target $target)"
      else
        echo "[PROTECT] SKIP: Target under planned repo symlink anchor: $FOUND_ANCHOR_T -> $FOUND_ANCHOR_S (target $target)"
      fi
      note_blocked_risk "$target"
      return 1
    fi
  fi

  # 2) Existing symlink ancestors that resolve into repo
  local base_to_check
  base_to_check="$(dirname "$target")"
  while [[ -n "$base_to_check" && "$base_to_check" != "/" ]]; do
    if [[ -L "$base_to_check" ]]; then
      local link
      link="$(readlink "$base_to_check" 2>/dev/null || true)"
      if [[ -n "$link" ]]; then
        local resolved
        case "$link" in
        /*) resolved="$link" ;;
        *) resolved="$(cd -P "$(dirname "$base_to_check")" && pwd)/$link" ;;
        esac
        if resolved="$(cd -P "$resolved" 2>/dev/null && pwd -P)"; then
          if is_under "$resolved" "$MY_ENV_DIR"; then
            if [[ $DRY_RUN -eq 1 ]]; then
              echo "[PROTECT][DRY-RUN] SKIP: Target under existing symlink into repo: $base_to_check -> $resolved (target $target)"
            else
              echo "[PROTECT] SKIP: Target under existing symlink into repo: $base_to_check -> $resolved (target $target)"
            fi
            note_blocked_risk "$target"
            return 1
          fi
        fi
      fi
      break
    fi
    local parent
    parent="$(dirname "$base_to_check")"
    [[ "$parent" == "$base_to_check" ]] && break
    [[ ! -e "$parent" ]] && break
    base_to_check="$parent"
  done

  return 0
}

link_one() {
  local real_src="$1" TARGET_PATH="$2"
  # Enforce guards (protect source)
  if ! guard_target_allowed "$TARGET_PATH"; then
    return 0
  fi

  local parent
  parent="$(dirname "$TARGET_PATH")"
  maybe_create_dir "$parent"

  if [[ $DRY_RUN -eq 1 ]]; then
    dry_run_report "$real_src" "$TARGET_PATH"
    return 0
  fi

  # Never remove anything inside MY_ENV_DIR
  if [[ -e "$TARGET_PATH" && ! -L "$TARGET_PATH" ]] && is_under "$TARGET_PATH" "$MY_ENV_DIR"; then
    echo "[PROTECT] SKIP: Refusing to remove path inside source tree: $TARGET_PATH"
    note_blocked_risk "$TARGET_PATH"
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
    note_unchanged
    return 0
  fi

  ln -sfn "$real_src" "$TARGET_PATH"
  echo "Linked: $real_src -> $TARGET_PATH"
  note_linked
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

  # Determine mapping kind: CONTAINER only if source has a glob
  is_container=0
  if is_glob "$src"; then
    is_container=1
  fi

  # Reset per-line dry container base
  ACTIVE_DRY_CONTAINER_BASE=""

  # If ONE-TO-ONE directory link → record as planned anchor before linking
  if [[ $is_container -eq 0 ]]; then
    if [[ ${#matched[@]} -eq 1 && -d "${matched[0]}" ]]; then
      one_to_one_target="$HOME/${tgt%/}" # normalize trailing slash away
      if is_under "${matched[0]}" "$MY_ENV_DIR"; then
        add_planned_anchor "$one_to_one_target" "${matched[0]}"
      fi
    fi
  fi

  # Container setup (src had glob)
  if [[ $is_container -eq 1 ]]; then
    CONTAINER_DIR="$HOME/${tgt%/}"
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
      # container: always place by child name
      TARGET_PATH="$CONTAINER_DIR/$(basename "$real_src")"
    else
      # ONE-TO-ONE with cp-like trailing '/' semantics
      if [[ "${tgt%/}" != "$tgt" ]]; then
        # target had trailing '/':
        tgt_base="$HOME/${tgt%/}"
        if [[ -d "$real_src" ]]; then
          # DIR + dir/  => link the directory to the directory path (strip slash)
          TARGET_PATH="$tgt_base"
        else
          # FILE + dir/ => ensure dir, link inside by basename
          maybe_create_dir "$tgt_base"
          TARGET_PATH="$tgt_base/$(basename "$real_src")"
        fi
      else
        # plain one-to-one
        TARGET_PATH="$HOME/$tgt"
      fi
    fi

    link_one "$real_src" "$TARGET_PATH"
  done
done <"$LINKS_FILE"

# ---------- Summary ----------
echo "----- Summary -----"
if [[ $DRY_RUN -eq 1 ]]; then
  echo "Planned links created/replaced : $CNT_LINKED"
  echo "Unchanged (already correct)    : $CNT_UNCHANGED"
  echo "Planned directories to create  : $CNT_DIR_PLANNED_OR_CREATED"
else
  echo "Links created/replaced         : $CNT_LINKED"
  echo "Unchanged (already correct)    : $CNT_UNCHANGED"
  echo "Directories created            : $CNT_DIR_PLANNED_OR_CREATED"
fi
echo "BLOCKED to PROTECT source      : $CNT_BLOCKED_RISK"
if [[ $CNT_BLOCKED_RISK -gt 0 ]]; then
  echo "  (These were skipped to avoid modifying your repo through a symlinked path)"
  printf "%s" "$BLOCKED_RISK_LIST" | sed '/^$/d;s/^/   - /'
fi
