#!/bin/sh
exec awk -f "$(dirname "$0")/csv.awk" -- "$@"
