#!/usr/bin/env python3
from __future__ import print_function
import re, sys
re_escape = re.compile(r"""\x1b[ #%()*+\-./]. |
            \r |
            (?:\x1b\[|\x9b) [ -?]* [@-~] |
            (?:\x1b\]|\x9d) .*? (?:\x1b\\|[\a\x9c]) |
            (?:\x1b[P^_]|[\x90\x9e\x9f]) .*? (?:\x1b\\|\x9c) |
            \x1b.|[\x80-\x9f]""", re.VERBOSE)
re_bs = re.compile(r'[^\b][\b]')

for line in sys.stdin:
    line = re_escape.sub('', line)
    line = re_bs.sub('', line)
    print(line, end='')
