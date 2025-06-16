#!/usr/bin/env bash

set -euo pipefail

print_help() {
  cat <<EOF
Usage: $(basename "$0") -f <local-file> -b <git-branch-ref> [-p <git-file-path>]

Options:
  -f  Local file path to compare (absolute or relative path, must exist)
  -b  Git branch reference (e.g. origin/main, branch-name, etc.)
  -p  Path of file inside Git branch (optional, auto-detects if omitted)
  -h  Show this help

This script compares a local file with the corresponding file in a Git branch.
- If content differs, prints filename and Git-style diff.
- If content matches, remains silent.
- If -p is omitted, it will try to auto-match based on file suffix.
EOF
}

normalize_path() {
  local file="$1"
  echo "$(cd "$(dirname "$file")" && pwd)/$(basename "$file")"
}

discover_git_path() {
  local local_file="$1"
  local branch="$2"

  local tmp_gitlist
  tmp_gitlist=$(mktemp)
  git ls-tree -r --name-only "$branch" >"$tmp_gitlist"

  local suffix="$local_file"
  local candidates=""

  while [ "${suffix#*/}" != "$suffix" ]; do
    suffix="${suffix#*/}"
    candidates="$candidates $suffix"
  done
  candidates="$candidates $(basename "$local_file")"

  for cand in $candidates; do
    while IFS= read -r gitfile; do
      case "$gitfile" in
      *"$cand")
        echo "$gitfile"
        rm -f "$tmp_gitlist"
        return 0
        ;;
      esac
    done <"$tmp_gitlist"
  done

  rm -f "$tmp_gitlist"
  echo "ERROR: Cannot find matching file for '$local_file' in branch '$branch'" >&2
  exit 1
}

validate_inputs() {
  local local_file="$1"
  local branch="$2"
  local git_path="$3"

  if [ ! -f "$local_file" ]; then
    echo "ERROR: Local file '$local_file' does not exist."
    exit 1
  fi

  if ! git rev-parse --verify "$branch" >/dev/null 2>&1; then
    echo "ERROR: Git reference '$branch' not found."
    exit 1
  fi

  if ! git ls-tree -r --name-only "$branch" | grep -Fxq "$git_path"; then
    echo "ERROR: File '$git_path' not found in branch '$branch'."
    exit 1
  fi
}

compare_files() {
  local local_file="$1"
  local branch="$2"
  local git_path="$3"

  tmpfile=$(mktemp)
  trap 'rm -f "$tmpfile"' EXIT

  git show "$branch:$git_path" >"$tmpfile" 2>/dev/null || {
    echo "ERROR: Cannot extract file from branch"
    exit 1
  }

  if ! cmp -s "$local_file" "$tmpfile"; then
    echo "=== DIFFERENCE: $local_file vs $branch:$git_path ==="
    git diff --no-index "$tmpfile" "$local_file" || true
  fi
}

main() {
  local local_file="" branch="" git_path=""

  while getopts ":f:b:p:h" opt; do
    case ${opt} in
    f) local_file="$OPTARG" ;;
    b) branch="$OPTARG" ;;
    p) git_path="$OPTARG" ;;
    h)
      print_help
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      print_help
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      print_help
      exit 1
      ;;
    esac
  done

  if [ -z "$local_file" ] || [ -z "$branch" ]; then
    echo "ERROR: Both -f and -b options are required."
    print_help
    exit 1
  fi

  local_file=$(normalize_path "$local_file")

  if [ -z "$git_path" ]; then
    git_path=$(discover_git_path "$local_file" "$branch")
  fi

  validate_inputs "$local_file" "$branch" "$git_path"
  compare_files "$local_file" "$branch" "$git_path"
}

main "$@"
