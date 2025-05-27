#!/bin/bash

show_help() {
  echo "Usage: $0 <extension> [directory]"
  echo
  echo "Counts lines of files with the given extension in each immediate subdirectory."
  echo
  echo "Arguments:"
  echo "  <extension>   File extension to count (e.g., py, js, ts)"
  echo "  [directory]   Directory to search (default: current directory)"
  echo
  echo "Example:"
  echo "  $0 py apps"
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
fi

if [[ -z "$1" ]]; then
  echo "Error: Missing file extension argument."
  show_help
fi

ext="$1"
dir="${2:-.}"

printf "%-30s %10s\n" "Directory" "Line Count"
printf "%-30s %10s\n" "------------------------------" "----------"

find "$dir" -mindepth 1 -maxdepth 1 -type d | while read app; do
  count=$(find "$app" -type f -name "*.${ext}" -exec cat {} + 2>/dev/null | wc -l)
  appname=$(basename "$app")
  printf "%-30s %10d\n" "$appname" "$count"
done | sort -k2 -nr
