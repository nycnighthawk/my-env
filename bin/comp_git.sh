#!/usr/bin/env bash

set -euo pipefail

# ========================
# Utility functions
# ========================

print_help() {
  cat <<EOF
Usage: $(basename "$0") -d <directory> -b <git-branch-ref> [-s <git-subdir>]

Options:
  -d  Local directory path to compare (must exist)
  -b  Git branch reference (e.g. origin/main, branch-name, etc.)
  -s  Subdirectory inside branch to compare (optional, default: local dir basename)
  -h  Show this help

This script compares file names and file content between a local directory and a Git branch directory.
- Shows files missing on either side.
- If filenames exist on both sides, compare content.
- If content differs, only shows the filename.
EOF
}

validate_inputs() {
  local dir="$1"
  local branch="$2"
  local git_subdir="$3"

  if [[ ! -d "$dir" ]]; then
    echo "ERROR: Directory '$dir' does not exist."
    exit 1
  fi

  if ! git rev-parse --verify "$branch" >/dev/null 2>&1; then
    echo "ERROR: Git reference '$branch' not found."
    exit 1
  fi

  if ! git ls-tree --name-only "$branch" "$git_subdir" >/dev/null 2>&1; then
    echo "ERROR: Subdirectory '$git_subdir' does not exist in branch '$branch'."
    exit 1
  fi
}

extract_git_file_list() {
  local branch="$1"
  local git_subdir="$2"

  git ls-tree -r --name-only "$branch" "$git_subdir" | sed "s|^$git_subdir/||"
}

extract_local_file_list() {
  local dir="$1"

  (cd "$dir" && find . -type f | sed 's|^\./||')
}

compare_file_lists() {
  local local_dir="$1"
  local branch="$2"
  local git_subdir="$3"
  local local_files="$4"
  local branch_files="$5"

  sort "$local_files" -o "$local_files"
  sort "$branch_files" -o "$branch_files"

  echo "=== Files only in local ==="
  comm -23 "$local_files" "$branch_files"

  echo
  echo "=== Files only in branch ==="
  comm -13 "$local_files" "$branch_files"

  echo
  echo "=== Files with different content ==="

  comm -12 "$local_files" "$branch_files" | while read -r file; do
    # Extract git version
    tmpfile=$(mktemp)
    git show "$branch:$git_subdir/$file" >"$tmpfile" 2>/dev/null || {
      echo "ERROR reading $file from branch"
      rm -f "$tmpfile"
      continue
    }

    # Compare content
    if ! cmp -s "$local_dir/$file" "$tmpfile"; then
      echo "$file"
    fi

    rm -f "$tmpfile"
  done
}

cleanup() {
  local tmpdir="$1"
  rm -rf "$tmpdir"
}

# ========================
# Main (Imperative Shell)
# ========================

main() {
  local dir="" branch="" subdir=""

  while getopts ":d:b:s:h" opt; do
    case ${opt} in
    d) dir="$OPTARG" ;;
    b) branch="$OPTARG" ;;
    s) subdir="$OPTARG" ;;
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

  if [[ -z "$dir" || -z "$branch" ]]; then
    echo "ERROR: Both -d and -b options are required."
    print_help
    exit 1
  fi

  if [[ -z "$subdir" ]]; then
    subdir="$(basename "$dir")"
  fi

  validate_inputs "$dir" "$branch" "$subdir"

  tmpdir=$(mktemp -d)
  trap "cleanup \"$tmpdir\"" EXIT

  local_local_file="$tmpdir/local_files.txt"
  local_branch_file="$tmpdir/branch_files.txt"

  extract_local_file_list "$dir" >"$local_local_file"
  extract_git_file_list "$branch" "$subdir" >"$local_branch_file"

  compare_file_lists "$dir" "$branch" "$subdir" "$local_local_file" "$local_branch_file"
}

main "$@"
