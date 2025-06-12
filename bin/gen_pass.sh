#!/bin/bash

# Default values
DEFAULT_LENGTH=12
DEFAULT_N_SYMBOLS=2
DEFAULT_SYMBOLS="@#$%^&*"
MIN_LENGTH=8
MAX_LENGTH=50

# Function to print help
print_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Generate a random password."
  echo
  echo "Options:"
  echo "  --no-symbols           Do not include symbols in the password."
  echo "  --symbols SYMBOLS      Specify the symbols to include in the password."
  echo "  --length LENGTH        Specify the length of the password (default: $DEFAULT_LENGTH)."
  echo "  --n-symbols N          Specify the number of symbols in the password (default: $DEFAULT_N_SYMBOLS)."
  echo "  --help                 Display this help message."
}

# Parse arguments
NO_SYMBOLS=false
SYMBOLS=$DEFAULT_SYMBOLS
LENGTH=$DEFAULT_LENGTH
N_SYMBOLS=$DEFAULT_N_SYMBOLS

while [[ $# -gt 0 ]]; do
  case $1 in
  --no-symbols)
    NO_SYMBOLS=true
    shift
    ;;
  --symbols)
    SYMBOLS="$2"
    shift 2
    ;;
  --length)
    LENGTH="$2"
    shift 2
    ;;
  --n-symbols)
    N_SYMBOLS="$2"
    shift 2
    ;;
  --help)
    print_help
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    print_help
    exit 1
    ;;
  esac
done

# Validate options
if $NO_SYMBOLS && [[ -n $SYMBOLS ]]; then
  echo "Error: --no-symbols and --symbols cannot be used together."
  exit 1
fi

if ! [[ $LENGTH =~ ^[0-9]+$ ]] || [[ $LENGTH -lt $MIN_LENGTH ]] || [[ $LENGTH -gt $MAX_LENGTH ]]; then
  echo "Error: --length must be an integer between $MIN_LENGTH and $MAX_LENGTH."
  exit 1
fi

if ! [[ $N_SYMBOLS =~ ^[0-9]+$ ]]; then
  echo "Error: --n-symbols must be an integer."
  exit 1
fi

# Determine the maximum number of symbols allowed based on the length
if [[ $LENGTH -le 10 ]]; then
  MAX_N_SYMBOLS=1
elif [[ $LENGTH -le 20 ]]; then
  MAX_N_SYMBOLS=2
elif [[ $LENGTH -le 30 ]]; then
  MAX_N_SYMBOLS=3
elif [[ $LENGTH -le 40 ]]; then
  MAX_N_SYMBOLS=4
else
  MAX_N_SYMBOLS=5
fi

if [[ $N_SYMBOLS -gt $MAX_N_SYMBOLS ]]; then
  echo "Error: --n-symbols cannot be greater than $MAX_N_SYMBOLS for the specified length."
  exit 1
fi

# Define character sets
letters="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
numbers="0123456789"

if $NO_SYMBOLS; then
  symbols=""
else
  symbols="$SYMBOLS"
fi

# Generate the first character (a letter)
first_char=$(echo "$letters" | fold -w1 | shuf | head -n1)

# Calculate the number of remaining characters
remaining_length=$((LENGTH - 1 - N_SYMBOLS))

# Generate the remaining characters (letters and numbers)
remaining_chars=$(echo "$letters$numbers" | fold -w1 | shuf | head -n$remaining_length)

# Ensure exactly N_SYMBOLS symbols are included
symbols_included=$(echo "$symbols" | fold -w1 | shuf | head -n$N_SYMBOLS)

# Combine all parts
password="$first_char$remaining_chars$symbols_included"

# Shuffle the final password to ensure randomness
final_password=$(echo "$password" | fold -w1 | shuf | tr -d '\n')

# Print the final password
echo "$final_password"
