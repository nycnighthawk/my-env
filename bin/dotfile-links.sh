#!/usr/bin/env bash

set -e

show_help() {
  echo "Usage: $(basename "$0") [--dry-run|-n] [links.txt] [excludes.txt]"
  echo "Symlink dotfiles from my-env/config/... to \$HOME."
  echo
  echo "links.txt format: <source> <target>"
  echo "  <source>: relative to my-env/config/, supports glob"
  echo "  <target>: relative to \$HOME"
  echo
  echo "excludes.txt: glob patterns (relative to config/) to skip"
  echo
  echo "Use --dry-run or -n to preview actions without making changes."
}

DRY_RUN=0
LINKS_FILE=""
EXCLUDES_FILE=""

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
    if [[ -z "$LINKS_FILE" ]]; then
      LINKS_FILE="$1"
    else
      EXCLUDES_FILE="$1"
    fi
    shift
    ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MY_ENV_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$MY_ENV_DIR/config"
LINKS_FILE="${LINKS_FILE:-$MY_ENV_DIR/links.txt}"
EXCLUDES_FILE="${EXCLUDES_FILE:-$MY_ENV_DIR/excludes.txt}"

if [[ ! -f "$LINKS_FILE" ]]; then
  echo "links.txt not found: $LINKS_FILE"
  exit 1
fi

EXCLUDES=()
if [[ -f "$EXCLUDES_FILE" ]]; then
  while read -r pat; do
    [[ -z "$pat" || "$pat" =~ ^# ]] && continue
    EXCLUDES+=("$CONFIG_DIR/$pat")
  done <"$EXCLUDES_FILE"
fi

should_exclude() {
  local path="$1"
  for pat in "${EXCLUDES[@]}"; do
    if [[ "$path" == $pat ]]; then
      return 0
    fi
    # Support glob matching
    if [[ "$path" == $pat ]]; then
      return 0
    fi
  done
  return 1
}

dry_run_report() {
  local real_src="$1"
  local target="$2"
  if [[ -L "$target" ]]; then
    local link_target
    link_target="$(readlink "$target")"
    if [[ "$link_target" == "$real_src" ]]; then
      echo "[DRY-RUN] Symlink exists: $target -> $link_target"
    else
      echo "[DRY-RUN] Would replace symlink: $target (currently points to $link_target) -> $real_src"
    fi
  elif [[ -e "$target" ]]; then
    if [[ -d "$target" ]]; then
      echo "[DRY-RUN] Would overwrite directory: $target"
    else
      echo "[DRY-RUN] Would overwrite file: $target"
    fi
  else
    echo "[DRY-RUN] Would create symlink: $real_src -> $target"
  fi
}

while read -r src tgt; do
  [[ -z "$src" || "$src" =~ ^# ]] && continue
  src_glob="$CONFIG_DIR/${src#config/}"
  for real_src in $src_glob; do
    rel_path="${real_src#$CONFIG_DIR/}"
    if should_exclude "$real_src"; then
      echo "Excluded: $real_src"
      continue
    fi
    if [[ -d "$real_src" && "$tgt" == */ ]]; then
      target="$HOME/$tgt"
      if [[ $DRY_RUN -eq 1 ]]; then
        dry_run_report "$real_src" "$target"
      else
        mkdir -p "$(dirname "$target")"
        if [[ -L "$target" && "$(readlink "$target")" == "$real_src" ]]; then
          echo "Symlink exists: $target"
          continue
        fi
        ln -sfn "$real_src" "$target"
        echo "Linked directory: $real_src -> $target"
      fi
    else
      if [[ "$tgt" == */ ]]; then
        target="$HOME/$tgt$rel_path"
      else
        target="$HOME/$tgt"
      fi
      if [[ $DRY_RUN -eq 1 ]]; then
        dry_run_report "$real_src" "$target"
      else
        mkdir -p "$(dirname "$target")"
        if [[ -L "$target" && "$(readlink "$target")" == "$real_src" ]]; then
          echo "Symlink exists: $target"
          continue
        fi
        ln -sf "$real_src" "$target"
        echo "Linked: $real_src -> $target"
      fi
    fi
  done
done <"$LINKS_FILE"
