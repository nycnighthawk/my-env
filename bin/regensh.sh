#!/bin/sh

print_string() {
    local redirect_filename="$2"
    local new_line="$3"
    if [ -n "${redirect_filename}" ]; then
        printf '%s' "$1" >> "${redirect_filename}"
        if [ -n "${new_line}" ]; then
          printf "\n" >> "${redirect_filename}"
        fi
    else
        printf '%s' "$1"
        if [ -n "${new_line}" ]; then
          printf "\n"
        fi
    fi
}

process_args() {
    arg_input_file=""
    arg_gensh_name=""
    arg_redirect_file_name=""
    arg_continuation=0

    usage() {
        echo "Usage: $0 [options] positional_argument"
        echo "Options:"
        echo "  --gensh_name NAME         Set the gensh_name"
        echo "  --redirect_file_name FILE Set the redirect_file_name"
        echo "  --continuation            Set the continuation flag"
        echo "  -h, --help                Display this help message"
    }

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --gensh_name)
                shift
                arg_gensh_name="$1"
                ;;
            --redirect_file_name)
                shift
                arg_redirect_file_name="$1"
                ;;
            --continuation)
                arg_continuation=1
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -*)
                echo "Unknown option: $1" >&2
                usage
                exit 1
                ;;
            *)
                if [ -z "$arg_input_file" ]; then
                    arg_input_file="$1"
                else
                    echo "Unknown argument: $1" >&2
                    usage
                    exit 1
                fi
                ;;
        esac
        shift
    done

    if [ -z "$arg_input_file" ]; then
        echo "Missing positional argument" >&2
        usage
        exit 1
    fi

    if [ "$#" -gt 0 ]; then
        echo "Unknown arguments: $@" >&2
        usage
        exit 1
    fi
}

process_line() {
  local line="$1"
  local filename="$2"
  local redirect_filename="$3"
  local continuation="$4"
  local part=""
  local sep=""

  while [ -n "$line" ]; do
    case "$line" in
      "\\"*|"\$"*|"\""*|"'"* )
        sep="${line%"${line#?}"}"
        line="${line#?}"
        break
        ;;
      *)
        part="$part${line%"${line#?}"}"
        line="${line#?}"
        ;;
    esac
  done

  if [ -n "$redirect_filename" ]; then
    print_string "$(printf "printf '%%s' '%s' >> %s" "$part" "$redirect_filename")" "$filename"
  else
    print_string "$(printf "printf '%%s' '%s'" "$part")" "$filename"
  fi

  if [ "$continuation" = "1" ]; then
    print_string "$(printf " && \\\\\n")" "$filename" 1
  else
    print_string "" "$filename" 1
  fi

  if [ -n "$sep" ]; then
    case "$sep" in
      "\\" )
        if [ -n "$redirect_filename" ]; then
          print_string "$(printf "printf '\\\\\\\\' >> %s" "$redirect_filename")" "$filename"
        else
          print_string "$(printf "printf '\\\\\\\\'")" "$filename"
        fi
        ;;
      "\$" )
        if [ -n "$redirect_filename" ]; then
          print_string "$(printf "printf \"\\\$\" >> %s" "$redirect_filename")" "$filename"
        else
          print_string "$(printf "printf \"\\\$\"")" "$filename"
        fi
        ;;
      '"' )
        if [ -n "$redirect_filename" ]; then
          print_string "$(printf "printf '\\\"' >> %s" "$redirect_filename")" "$filename"
        else
          print_string "$(printf "printf '\\\"'")" "$filename"
        fi
        ;;
      "'" )
        if [ -n "$redirect_filename" ]; then
          print_string "$(printf "printf \"'\" >> %s" "$redirect_filename")" "$filename"
        else
          print_string "$(printf "printf \"'\"")" "$filename"
        fi
        ;;
    esac
    if [ "$continuation" = "1" ]; then
      print_string "$(printf " && \\\\\n")" "$filename" 1
    else
      print_string "$(printf "\n")" "$filename" 1
    fi
    process_line "$line" "$filename" "$redirect_filename" "$continuation"
  fi
}

process_file() {
  local file="$1"
  local filename="$2"
  local redirect_filename="$3"
  local continuation="$4"

  # Print the shebang to the file
  if [ -n "$filename" ]; then
    printf "" > "$filename"
  fi
  if [ -n "$redirect_filename" ]; then
    # print_string "$(printf "#!/bin/sh\nprintf \"\" > %s" "$redirect_filename")" "$filename"
    print_string "$(printf "#!/bin/sh")" "$filename" 1
    print_string "$(printf "printf \"\" > %s" "$redirect_filename")" "$filename"
  else
    print_string "$(printf "#!/bin/sh\n")" "$filename"
  fi

  if [ "$continuation" = "1" ]; then
    print_string "$(printf " && \\\\")" "$filename"
  fi

  # Process each line in the file
  local print_continuation=0
  while IFS= read -r line || [ -n "$line" ]; do
    if [ "$continuation" = "1" ] && [ "${print_continuation}" = "1"  ]; then
      print_string "$(printf " && \\\\\n")" "$filename"
    fi
    print_string "" "$filename" 1
    print_continuation=1
    process_line "$line" "$filename" "$redirect_filename" "$continuation"
    if [ -n "$redirect_filename" ]; then
        print_string "$(printf "printf \"\\\\n\" >> %s" "$redirect_filename")" "$filename"
    else
        print_string "$(printf "printf \"\\\\n\"")" "$filename"
    fi
  done < "$file"
}

_main() {
    process_args "$@"
    process_file "$arg_input_file" "$arg_gensh_name" "$arg_redirect_file_name" "$arg_continuation"
}

_main "$@"
