#!/bin/sh

# Usage: combine.sh [-o output] [-m pattern] [-e pattern] [-d directory]...
# Combines files matching patterns into a single formatted output

set -e

# Default values
output_file="combined.md"
match_patterns=""
exclude_patterns=""
directories="."
temp_file="./.combine_temp_$$"
show_help=0

# Help message
show_help_msg() {
  cat <<EOF
Usage: $0 [OPTIONS]

OPTIONS:
    -o FILE          Output file (default: combined.md)
    -m PATTERN       Match pattern (regex, can be used multiple times)
    -e PATTERN       Exclude pattern (regex, can be used multiple times)
    -d DIRECTORY     Directory to search (can be used multiple times, default: current directory)
    -h, --help       Show this help message

DESCRIPTION:
    Recursively finds files matching any match pattern (-m) that do NOT match
    any exclude pattern (-e), then combines them into a single output file.

PATTERN MATCHING:
    Patterns are POSIX extended regular expressions (grep -E style).
    Without ^ or \\$ anchors, patterns match substrings (like grep).
    Examples:
        -m "\\.md\$"          Matches files ending with .md
        -m "^test"            Matches files starting with test
        -e "\\\\.tmp\\\$"     Excludes files ending with .tmp
        -e "backup"           Excludes files containing "backup"

EXAMPLES:
    $0 -o output.txt -m "\\.md\$" -e "test" -e "backup"
    $0 -m ".*" -d ./src -d ./docs -e "\\\\.git"
    $0 -m "^README" -o readme.txt

NOTES:
    - Multiple -m options: file matches if ANY match pattern applies
    - Multiple -e options: file is excluded if ANY exclude pattern applies
    - Exclusion is checked BEFORE matching
    - The output file is automatically excluded from processing
EOF
  exit 0
}

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
  -o)
    if [ -z "$2" ]; then
      echo "Error: -o requires an argument" >&2
      exit 1
    fi
    output_file="$2"
    shift 2
    ;;
  -m)
    if [ -z "$2" ]; then
      echo "Error: -m requires an argument" >&2
      exit 1
    fi
    if [ -z "$match_patterns" ]; then
      match_patterns="$2"
    else
      match_patterns="$match_patterns|$2"
    fi
    shift 2
    ;;
  -e)
    if [ -z "$2" ]; then
      echo "Error: -e requires an argument" >&2
      exit 1
    fi
    if [ -z "$exclude_patterns" ]; then
      exclude_patterns="$2"
    else
      exclude_patterns="$exclude_patterns|$2"
    fi
    shift 2
    ;;
  -d)
    if [ -z "$2" ]; then
      echo "Error: -d requires an argument" >&2
      exit 1
    fi
    if [ "$directories" = "." ]; then
      directories="$2"
    else
      directories="$directories $2"
    fi
    shift 2
    ;;
  -h | --help)
    show_help=1
    shift
    ;;
  *)
    echo "Error: Unknown option: $1" >&2
    echo "Use -h or --help for usage information" >&2
    exit 1
    ;;
  esac
done

# Show help if requested
[ $show_help -eq 1 ] && show_help_msg

# Validate required parameters
if [ -z "$match_patterns" ]; then
  echo "Error: At least one match pattern (-m) is required" >&2
  echo "Use -h or --help for usage information" >&2
  exit 1
fi

# Clean up temp file on exit
cleanup() {
  rm -f "$temp_file"
}
trap cleanup EXIT

# Create empty temp file
>"$temp_file"

# Get absolute path of output file for exclusion
output_abs="$output_file"
case "$output_file" in
/*) ;;
*) output_abs="$(pwd)/$output_file" ;;
esac

# Process each directory
for dir in $directories; do
  # Convert to absolute path if relative
  case "$dir" in
  /*) ;;
  *) dir="$(pwd)/$dir" ;;
  esac

  # Check if directory exists
  if [ ! -d "$dir" ]; then
    echo "Warning: Directory '$dir' does not exist, skipping" >&2
    continue
  fi

  # Find all files and filter with regex patterns
  find "$dir" -type f 2>/dev/null | while read -r file; do
    # Skip the output file itself
    file_abs="$file"
    case "$file" in
    /*) ;;
    *) file_abs="$(pwd)/$file" ;;
    esac
    [ "$file_abs" = "$output_abs" ] && continue

    # Check exclusion patterns first (invert: if matches any, skip)
    if [ -n "$exclude_patterns" ]; then
      if echo "$file" | grep -qE "$exclude_patterns" 2>/dev/null; then
        echo "Excluding: $file" >&2
        continue
      fi
    fi

    # Check match patterns (if matches any, include)
    if echo "$file" | grep -qE "$match_patterns" 2>/dev/null; then
      echo "Processing: $file" >&2

      # Write formatted content to temp file
      echo "---" >>"$temp_file"
      echo "# file: $file" >>"$temp_file"
      echo "#" >>"$temp_file"

      # Write file content
      if [ -s "$file" ]; then
        cat "$file" >>"$temp_file"
        # Ensure trailing newline
        if [ -n "$(tail -c 1 "$file" 2>/dev/null)" ]; then
          echo "" >>"$temp_file"
        fi
      fi

      echo "---" >>"$temp_file"
    fi
  done
done

# Check if we have any content
if [ -s "$temp_file" ]; then
  mv "$temp_file" "$output_file"
  echo "Successfully created: $output_file"

  # Count processed files
  file_count=$(grep -c '^# file:' "$output_file" 2>/dev/null || echo "0")
  echo "Total files processed: $file_count"
else
  echo "Warning: No files found matching the patterns" >&2
  exit 1
fi

exit 0
