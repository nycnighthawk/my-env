#!/usr/bin/env python
# copyright (C) 2013
# author: Han Chen
# email: hchen@metlife.com

import argparse
import sys
import re

route_re = re.compile(r'([^,]+)\s*,\s*([^,]+)\s*,\s*([^,]+)*')
MASK_TO_PREFIX = {}
MASK_TO_PREFIX['255.255.255.255'] = 32
MASK_TO_PREFIX['255.255.255.254'] = 31
MASK_TO_PREFIX['255.255.255.252'] = 30
MASK_TO_PREFIX['255.255.255.248'] = 29
MASK_TO_PREFIX['255.255.255.240'] = 28
MASK_TO_PREFIX['255.255.255.224'] = 27
MASK_TO_PREFIX['255.255.255.192'] = 26
MASK_TO_PREFIX['255.255.255.128'] = 25
MASK_TO_PREFIX['255.255.255.0'] = 24
MASK_TO_PREFIX['255.255.254.0'] = 23
MASK_TO_PREFIX['255.255.252.0'] = 22
MASK_TO_PREFIX['255.255.248.0'] = 21
MASK_TO_PREFIX['255.255.240.0'] = 20
MASK_TO_PREFIX['255.255.224.0'] = 19
MASK_TO_PREFIX['255.255.192.0'] = 18
MASK_TO_PREFIX['255.255.128.0'] = 17
MASK_TO_PREFIX['255.255.0.0'] = 16
MASK_TO_PREFIX['255.254.0.0'] = 15
MASK_TO_PREFIX['255.252.0.0'] = 14
MASK_TO_PREFIX['255.248.0.0'] = 13
MASK_TO_PREFIX['255.240.0.0'] = 12
MASK_TO_PREFIX['255.224.0.0'] = 11
MASK_TO_PREFIX['255.192.0.0'] = 10
MASK_TO_PREFIX['255.128.0.0'] = 9
MASK_TO_PREFIX['255.0.0.0'] = 8
MASK_TO_PREFIX['254.0.0.0'] = 7
MASK_TO_PREFIX['252.0.0.0'] = 6
MASK_TO_PREFIX['248.0.0.0'] = 5
MASK_TO_PREFIX['240.0.0.0'] = 4
MASK_TO_PREFIX['224.0.0.0'] = 3
MASK_TO_PREFIX['192.0.0.0'] = 2
MASK_TO_PREFIX['128.0.0.0'] = 1
MASK_TO_PREFIX['0.0.0.0'] = 0

def main(args):
    fin = open(args.infile,'r')
    route_tab = {}

    while True:
        line = fin.readline()
        if line == '':
            break
        line = line.rstrip()
        match = route_re.match(line)
        if match is not None:
            route = mast = next_hop = None
            route = match.group(1)
            mask = match.group(2)
            next_hop = match.group(3)
            out = []
            out.append(route)
            out.append('/')
            out.append(MASK_TO_PREFIX[mask].__str__())
            if next_hop is not None:
                out.append(",")
                out.append(next_hop)
            print("".join(out))


if __name__ == "__main__":
    ap = argparse.ArgumentParser(
        description="convert route to prefix format",
        epilog = "knowledge is power",
        prefix_chars='-+/'
        )
    #add position mandatory argument
    ap.add_argument('infile', help="route in csv file, network, mask, next-hop")

    args = ap.parse_args()

    main(args)
