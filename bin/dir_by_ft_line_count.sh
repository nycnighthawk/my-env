#!/bin/bash

# Usage: ./count_lines_by_type.sh py [directory]
# Example: ./count_lines_by_type.sh js apps

ext="${1:?Please provide a file extension (e.g., py, js)}"
dir="${2:-.}"

printf "%-30s %10s\n" "Directory" "Line Count"
printf "%-30s %10s\n" "------------------------------" "----------"

find "$dir" -mindepth 1 -maxdepth 1 -type d | while read app; do
  count=$(find "$app" -type f -name "*.${ext}" -exec cat {} + 2>/dev/null | wc -l)
  appname=$(basename "$app")
  printf "%-30s %10d\n" "$appname" "$count"
done | sort -k2 -nr
