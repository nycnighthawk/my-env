#!/usr/bin/env python
# copyright (C) 2013
# author: Han Chen
# email: hchen@metlife.com

import argparse
import sys
import re

re_acl = re.compile(r'(\d+\.\d+\.\d+\.\d+)/(\d+)')
PREFIX_TO_MASK = {}
PREFIX_TO_MASK[32] = '0.0.0.0'
PREFIX_TO_MASK[31] = '0.0.0.1'
PREFIX_TO_MASK[30] = '0.0.0.3'
PREFIX_TO_MASK[29] = '0.0.0.7'
PREFIX_TO_MASK[28] = '0.0.0.15'
PREFIX_TO_MASK[27] = '0.0.0.31'
PREFIX_TO_MASK[26] = '0.0.0.63'
PREFIX_TO_MASK[25] = '0.0.0.127'
PREFIX_TO_MASK[24] = '0.0.0.255'
PREFIX_TO_MASK[23] = '0.0.1.255'
PREFIX_TO_MASK[22] = '0.0.3.255'
PREFIX_TO_MASK[21] = '0.0.7.255'
PREFIX_TO_MASK[20] = '0.0.15.255'
PREFIX_TO_MASK[19] = '0.0.31.255'
PREFIX_TO_MASK[18] = '0.0.63.255'
PREFIX_TO_MASK[17] = '0.0.127.255'
PREFIX_TO_MASK[16] = '0.0.255.255'
PREFIX_TO_MASK[15] = '0.1.255.255'
PREFIX_TO_MASK[14] = '0.3.255.255'
PREFIX_TO_MASK[13] = '0.7.255.255'
PREFIX_TO_MASK[12] = '0.15.255.255'
PREFIX_TO_MASK[11] = '0.31.255.255'
PREFIX_TO_MASK[10] = '0.63.255.255'
PREFIX_TO_MASK[9] = '0.127.255.255'
PREFIX_TO_MASK[8] = '0.255.255.255'
PREFIX_TO_MASK[7] = '1.255.255.255'
PREFIX_TO_MASK[6] = '3.255.255.255'
PREFIX_TO_MASK[5] = '7.255.255.255'
PREFIX_TO_MASK[4] = '15.255.255.255'
PREFIX_TO_MASK[3] = '31.255.255.255'
PREFIX_TO_MASK[2] = '63.255.255.255'
PREFIX_TO_MASK[1] = '127.255.255.255'
PREFIX_TO_MASK[0] = '255.255.255.255'

def main(args):
    fin = open(args.infile,'r')
    while True:
        line = fin.readline()
        if line == '':
            break
        line = line.rstrip()
        match = re_acl.search(line)
        if match is not None:
            network=match.group(1)
            prefix = match.group(2)
            out = []
            pos = match.start()
            if pos != 0:
                out.append(line[:pos].rstrip())
            out.append(network)
            out.append(PREFIX_TO_MASK[int(prefix)])
            pos = match.end()
            match = re_acl.search(line, pos)

            if match is not None:
                network=match.group(1)
                prefix=match.group(2)
                out.append(network)
                out.append(PREFIX_TO_MASK[int(prefix)])
                out.append(line[match.end():])
            print(" ".join(out))

if __name__ == "__main__":
    ap = argparse.ArgumentParser(
        description="convert short hand prefix ACL to IOS inverse mask ACL format",
        epilog = "knowledge is power",
        )
    #add position mandatory argument
    ap.add_argument('infile', help="acl in csv file source,destination")

    args = ap.parse_args()

    main(args)
