#!/bin/sh

# Function to display help message
display_help() {
    echo "Usage: $0 <input_file> <output_file> [<output_filename>]"
    echo
    echo "Generate a script from <input_file> that, when executed, will print the"
    echo "contents of <input_file> to <output_filename> or stdout if not specified."
    echo
    echo "Arguments:"
    echo "  <input_file>      The input script file."
    echo "  <output_file>     The generated script file."
    echo "  <output_filename> Optional. The file to which the generated script will write."
}

# Check if the script is invoked with no arguments or with -h
if [ $# -eq 0 ] || [ "$1" = "-h" ]; then
    display_help
    exit 0
fi

input_file=$1
output_file=$2

# Create or clear the output file
: > "$output_file"

# Make the output file executable
chmod +x "$output_file"

# If the third argument is provided, use it as the output filename in the generated script
if [ $# -eq 3 ]; then
    output_filename=$3
    printf "exec > %s\n" "$output_filename" >> "$output_file"
fi

# Read the input file line by line
while IFS= read -r line || [ -n "$line" ]
do
    # Check if line ends with a backslash
    if [ "${line: -1}" = "\\" ]; then
        # Remove the trailing backslash
        line=${line%\\}
        # Escape any special characters
        escaped_line=$(printf '%s' "$line" | sed -e "s/'/'\\\\''/g")
        # Add the trailing backslash back and append to the output file
        printf "printf '%%s\\\\' '%s'\n" "$escaped_line" >> "$output_file"
        printf "echo ''\n" >> "$output_file"
    else
        # Escape any special characters
        escaped_line=$(printf '%s\n' "$line" | sed -e "s/'/'\\\\''/g")
        # Write a printf statement to the output file
        printf "printf '%%s\\n' '%s'\n" "$escaped_line" >> "$output_file"
    fi
done < "$input_file"
