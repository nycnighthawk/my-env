#!/usr/bin/awk -f

function csv_parse(record, sep, quote, fields,    len, pos, n, start, c, in_quoted, field, i, debug) {
    len = length(record)
    pos = 1
    n = 0
    in_quoted = 0
    field = ""
    debug = (ENVIRON["DEBUG"] == "1")

    while (pos <= len) {
        c = substr(record, pos, 1)

        if (debug) printf "[DEBUG] pos=%d, c='%s', in_quoted=%d\n", pos, c, in_quoted > "/dev/stderr"

        if (!in_quoted && c == quote) {
            in_quoted = 1
            pos++
            start = pos
            if (debug) printf "[DEBUG]   entering quoted field at pos=%d\n", pos > "/dev/stderr"
            continue
        }

        if (in_quoted) {
            i = pos
            while (i <= len) {
                if (substr(record, i, 1) == quote) {
                    if (i < len && substr(record, i+1, 1) == quote) {
                        i += 2
                        continue
                    }
                    field = substr(record, start, i - start)
                    gsub(quote quote, quote, field)
                    n++
                    fields[n] = field
                    if (debug) printf "[DEBUG]   extracted quoted field: '%s'\n", field > "/dev/stderr"
                    pos = i + 1
                    in_quoted = 0
                    if (pos <= len) {
                        if (substr(record, pos, 1) == sep) {
                            pos++
                            if (debug) printf "[DEBUG]   skipped separator, pos now %d\n", pos > "/dev/stderr"
                        } else if (pos <= len) {
                            return -2
                        }
                    }
                    break
                }
                i++
            }
            if (in_quoted) return -3
            continue
        }

        if (c == sep) {
            n++
            fields[n] = ""
            if (debug) printf "[DEBUG]   empty field at pos=%d\n", pos > "/dev/stderr"
            pos++
            continue
        }

        start = pos
        while (pos <= len) {
            c = substr(record, pos, 1)
            if (c == sep) {
                field = substr(record, start, pos - start)
                n++
                fields[n] = field
                if (debug) printf "[DEBUG]   unquoted field: '%s'\n", field > "/dev/stderr"
                pos++
                break
            }
            if (c == quote) return -1
            pos++
        }
        if (pos > len) {
            field = substr(record, start)
            n++
            fields[n] = field
            if (debug) printf "[DEBUG]   last unquoted field: '%s'\n", field > "/dev/stderr"
        }
    }

    if (len > 0 && substr(record, len, 1) == sep) {
        n++
        fields[n] = ""
        if (debug) printf "[DEBUG]   trailing separator -> added empty field\n" > "/dev/stderr"
    }

    return n
}

function usage() {
    print "Usage: csv.awk [options] [file...]" > "/dev/stderr"
    print "Options:" > "/dev/stderr"
    print "  -s, --separator CHAR   Input field separator (default: ,)" > "/dev/stderr"
    print "  -q, --quote CHAR       Quote character (default: \")" > "/dev/stderr"
    print "  -o, --output CHAR      Output field separator (default: |)" > "/dev/stderr"
    print "  -c, --column N         Output only the Nth column (1-indexed)" > "/dev/stderr"
    print "  -d, --debug            Enable debug output" > "/dev/stderr"
    print "  -h, --help             Show this help" > "/dev/stderr"
    exit 0
}

BEGIN {
    # Default values
    SEP = ","
    QUOTE = "\""
    OFS = "|"
    COLUMN = 0
    DEBUG = 0

    # Parse command-line options
    for (i = 1; i < ARGC; i++) {
        arg = ARGV[i]
        if (arg == "-s" || arg == "--separator") {
            if (i+1 < ARGC) {
                SEP = ARGV[i+1]
                # Remove both arguments
                for (j = i; j <= ARGC-2; j++) ARGV[j] = ARGV[j+2]
                ARGC -= 2
                i--
            } else {
                print "ERROR: -s requires an argument" > "/dev/stderr"
                exit 1
            }
        } else if (arg == "-q" || arg == "--quote") {
            if (i+1 < ARGC) {
                QUOTE = ARGV[i+1]
                for (j = i; j <= ARGC-2; j++) ARGV[j] = ARGV[j+2]
                ARGC -= 2
                i--
            } else {
                print "ERROR: -q requires an argument" > "/dev/stderr"
                exit 1
            }
        } else if (arg == "-o" || arg == "--output") {
            if (i+1 < ARGC) {
                OFS = ARGV[i+1]
                for (j = i; j <= ARGC-2; j++) ARGV[j] = ARGV[j+2]
                ARGC -= 2
                i--
            } else {
                print "ERROR: -o requires an argument" > "/dev/stderr"
                exit 1
            }
        } else if (arg == "-c" || arg == "--column") {
            if (i+1 < ARGC) {
                COLUMN = int(ARGV[i+1])
                if (COLUMN <= 0) {
                    print "ERROR: column number must be positive" > "/dev/stderr"
                    exit 1
                }
                for (j = i; j <= ARGC-2; j++) ARGV[j] = ARGV[j+2]
                ARGC -= 2
                i--
            } else {
                print "ERROR: -c requires an argument" > "/dev/stderr"
                exit 1
            }
        } else if (arg == "-d" || arg == "--debug") {
            DEBUG = 1
            ENVIRON["DEBUG"] = "1"
            for (j = i; j < ARGC-1; j++) ARGV[j] = ARGV[j+1]
            ARGC--
            i--
        } else if (arg == "-h" || arg == "--help") {
            usage()
        } else if (substr(arg, 1, 1) == "-") {
            print "ERROR: Unknown option " arg > "/dev/stderr"
            usage()
        } else {
            # Not an option, stop parsing (treat remaining as files)
            break
        }
    }

    # If no files specified, read stdin
    if (ARGC == 1) {
        ARGV[1] = "-"
        ARGC = 2
    }
}

{
    n = csv_parse($0, SEP, QUOTE, fields)
    if (n < 0) {
        msg = (n == -1) ? "Unquoted quote" : \
              (n == -2) ? "Missing separator after quoted field" : \
              "Missing closing quote"
        printf "[CSV ERROR] line %d: %s\n", NR, msg > "/dev/stderr"
        print ""
        next
    }

    if (COLUMN > 0) {
        if (COLUMN <= n) {
            print fields[COLUMN]
        } else {
            print ""
        }
    } else {
        for (i = 1; i <= n; i++) {
            if (i > 1) printf "%s", OFS
            printf "%s", fields[i]
        }
        printf "\n"
    }
}
