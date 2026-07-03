#!/bin/bash
# dump_tree.sh – Recursively dump directory tree and filtered file contents.
#
# Options:
#   -g PATTERN   Glob pattern for file inclusion (default: '*')
#   -r PATTERN   Regex pattern for file inclusion (overrides -g)
#   -i           Invert match – exclude files that match the pattern
#   -h           Show this help message
#
# Usage: ./dump_tree.sh [-g pattern] [-r pattern] [-i] [-h] [directory]
# Default directory is the current working directory.

set -euo pipefail

# -------------------------------------------------------------------
# Global variables (set by parse_args)
# -------------------------------------------------------------------
ROOT_DIR=""
FILTER_TYPE="glob" # "glob" or "regex"
FILTER_PATTERN="*"
INVERT=false

# -------------------------------------------------------------------
# Function: usage
# -------------------------------------------------------------------
usage() {
  cat <<EOF
Usage: $0 [OPTIONS] [DIRECTORY]

Recursively dump the directory tree and then the full content of each
regular file that matches the given filter.

Options:
  -g PATTERN   Glob pattern for file selection (default: '*')
  -r PATTERN   Regex pattern for file selection (overrides -g)
  -i           Invert selection – exclude files matching the pattern
  -h           Display this help message

If no DIRECTORY is given, the current working directory is used.

Examples:
  $0 -g "*.txt" ~/docs          # dump only .txt files in ~/docs
  $0 -r ".*\\.log$" -i ./logs   # dump all files EXCEPT .log files
  $0                            # dump everything in current directory
EOF
  exit 0
}

# -------------------------------------------------------------------
# Function: parse_args
# -------------------------------------------------------------------
parse_args() {
  local opt
  while getopts "g:r:ih" opt; do
    case "$opt" in
    g)
      FILTER_TYPE="glob"
      FILTER_PATTERN="$OPTARG"
      ;;
    r)
      FILTER_TYPE="regex"
      FILTER_PATTERN="$OPTARG"
      ;;
    i) INVERT=true ;;
    h) usage ;;
    *) usage ;;
    esac
  done
  shift $((OPTIND - 1))

  # The remaining argument is the root directory
  if [ $# -eq 0 ]; then
    ROOT_DIR="."
  elif [ $# -eq 1 ]; then
    ROOT_DIR="$1"
  else
    echo "Error: too many arguments." >&2
    usage
  fi

  # Resolve to absolute path
  if ! ROOT_DIR="$(realpath "$ROOT_DIR" 2>/dev/null)"; then
    ROOT_DIR="$(cd "$ROOT_DIR" 2>/dev/null && pwd -P)" || {
      echo "Error: '$ROOT_DIR' is not a valid directory." >&2
      exit 1
    }
  fi
}

# -------------------------------------------------------------------
# Function: file_matches_filter
#   Returns 0 (true) if the file should be included, else 1 (false).
#   The file path is given as an absolute path; we compare against
#   the path relative to ROOT_DIR.
# -------------------------------------------------------------------
file_matches_filter() {
  local file="$1"
  local rel="${file#$ROOT_DIR/}"
  # If file is exactly ROOT_DIR (should not happen for regular files)
  [ "$rel" = "$file" ] && rel="."

  local match=false
  case "$FILTER_TYPE" in
  glob)
    # Use bash's extended glob pattern matching against the relative path
    if [[ "$rel" == $FILTER_PATTERN ]]; then
      match=true
    fi
    ;;
  regex)
    if [[ "$rel" =~ $FILTER_PATTERN ]]; then
      match=true
    fi
    ;;
  esac

  if $INVERT; then
    $match && return 1 || return 0
  else
    $match && return 0 || return 1
  fi
}

# -------------------------------------------------------------------
# Function: dump_tree
#   Prints the directory tree using 'tree' if available, else a simple
#   indented listing.
# -------------------------------------------------------------------
dump_tree() {
  echo "=== TREE STRUCTURE ==="
  if command -v tree >/dev/null 2>&1; then
    tree "$ROOT_DIR"
  else
    echo "Note: 'tree' command not found. Using a simple recursive listing."
    find "$ROOT_DIR" -print 2>/dev/null | while IFS= read -r path; do
      rel="${path#$ROOT_DIR/}"
      if [ "$rel" = "$path" ]; then
        depth=0
      else
        depth=$(echo "$rel" | tr -cd '/' | wc -c)
      fi
      indent=""
      for ((i = 0; i < depth; i++)); do indent="    $indent"; done
      printf "%s%s\n" "$indent" "$(basename "$path")"
    done
  fi
  echo
}

# -------------------------------------------------------------------
# Function: dump_contents
#   Finds all regular files, filters them, and dumps each matching file.
# -------------------------------------------------------------------
dump_contents() {
  echo "=== FILE CONTENTS ==="
  find "$ROOT_DIR" -type f -print0 2>/dev/null | while IFS= read -r -d '' file; do
    if file_matches_filter "$file"; then
      echo "--- FILE: $file ---"
      cat "$file"
      echo
    fi
  done
}

# -------------------------------------------------------------------
# Function: main
# -------------------------------------------------------------------
main() {
  parse_args "$@"
  echo "Root directory: $ROOT_DIR"
  echo "Filter: $FILTER_TYPE pattern '$FILTER_PATTERN' (invert=$INVERT)"
  echo

  dump_tree
  dump_contents
}

# -------------------------------------------------------------------
# Script entry point
# -------------------------------------------------------------------
main "$@"
