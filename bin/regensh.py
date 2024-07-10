#!/bin/sh
''''which env >/dev/null 2>&1 && exec env python3 "$0" "$@" || exec /usr/bin/env python3 "$0" "$@" #'''
import sys
import argparse
from typing import Optional

def process_line(line: str, output_file: Optional[str] = "", last: bool = False, continuation: bool = True) -> str:
    # Initialize the accumulator and the list of printf commands
    accumulator = ""
    commands = []
    # Determine the output file for the printf commands
    output_file = output_file or "$1"
    # Iterate over the characters in the line
    continuation_str = ""
    if continuation:
        continuation_str = " && \\"
    for char in line.rstrip("\n"):
        # If the character is a backslash or a dollar sign, output the accumulated characters with an extra backslash
        if char == "\\" or char == "$":
            commands.append(f'printf "{accumulator}\\{char}" >> {output_file}{continuation_str}')
            accumulator = ""
        # If the character is a double quote, add an escaped double quote to the accumulator
        elif char == '"':
            accumulator += '\\"'
        else:
            # Otherwise, add the character to the accumulator
            accumulator += char
    # Output the remaining accumulated characters with a newline
    accumulator += "\\n"
    if last:
        commands.append(f'printf "{accumulator}" >> {output_file}')
    else:
        commands.append(f'printf "{accumulator}" >> {output_file}{continuation_str}')
    return "\n".join(commands)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("file", nargs="?", type=argparse.FileType("r"), default=sys.stdin)
    parser.add_argument("--output", "-o", type=str, default="", help="Output file name")
    parser.add_argument("--gensh", type=str, default="", help="Generated shell script file name")
    parser.add_argument("--continuation", default=False, action="store_true", help="continuation used to generate the script")
    args = parser.parse_args()

    output = []
    previous_line = ""
    for line in args.file:
        if previous_line:
            output.append(process_line(previous_line, args.output, continuation=args.continuation))
        previous_line = line
    output.append(process_line(previous_line, args.output, last=True, continuation=args.continuation))

    if args.gensh:
        with open(args.gensh, 'w') as f:
            f.write("\n".join(output))
    else:
        print("\n".join(output))

if __name__ == "__main__":
    main()
