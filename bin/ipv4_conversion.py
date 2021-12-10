#!/usr/bin/env python

#Version: 0.1
#Copyright 2013 Han Chen
#All Rights Reserved

from __future__ import print_function
import argparse
import sys
import re
from IPv4 import IPv4

class ArgumentException(Exception):
    pass

def p2m(x):
    a = IPv4(x)
    return "{} {}".format(a.ipv4_addr, a.ipv4_mask)

def p2i(x):
    a = IPv4(x)
    return "{} {}".format(a.ipv4_addr, a.ipv4_invmask)

def m2p(x):
    a = IPv4(x)
    return "{}/{}".format(a.ipv4_addr, a.ipv4_pref_len)

def m2i(x):
    a = IPv4(x)
    return "{} {}".format(a.ipv4_addr, a.ipv4_invmask)

def main(args):
    action = None
    expected_format = None

    pattern1 = re.compile(r"(\d+\.\d+\.\d+\.\d+/\d+)")
    pattern2 = re.compile(r"(\d+\.\d+\.\d+\.\d+)\s+(\d+\.\d+\.\d+\.\d+)")
    pattern3 = re.compile(r"(host)\s+(\d+\.\d+\.\d+\.\d+)")
    pattern4 = re.compile(r"(\d+\.\d+\.\d+\.\d+)")

    if args.p2m:
        action = p2m
        expected_format = 1
    
    if args.p2i:
        if action is not None:
            raise ArgumentException('more than 1 action is selected')
        action = p2i
        expected_format = 1

    if args.m2p:
        if action is not None:
            raise ArgumentException('more than 1 action is selected')
        action = m2p
        expected_format = 2

    if args.m2i:
        if action is not None:
            raise ArgumentException('more than 1 action is selected')
        action = m2i
        expected_format = 2

    if action is None:
        print('an action must be selected such as -m2p, etc', file=sys.stderr)
        exit(1)

    fin = sys.stdin
    if args.f is not None:
        try:
            fin = open(args.f,'r')
        except:
            print("unable to open file {}".format(args.f), file=sys.stderr)
            exit(1)

    for i in fin:
        i = i.rstrip()
        if expected_format == 1:
            result = ''
            s = 0
            while True:
                match = pattern1.search(i, s)
                if match is None:
                    result += i[s:]
                    break
                else:
                    result = i[s:match.start(1)]
                    result += action(match.group(1))
                    s = match.end(1)
            print(result)

        elif expected_format == 2:
            result = ''
            s = 0
            found_match = False
            while True:
                match = pattern2.search(i,s)
                if match is None:
                    result += i[s:]
                    break
                else:
                    result = i[s:match.start(1)]
                    result += action((match.group(1),match.group(2)))
                    s = match.end(2)
                    found_match = True
            s = 0
            n_result = ''
            while True:
                match = pattern3.search(result,s)
                if match is None:
                    n_result += result[s:]
                    break
                else:
                    n_result = result[s:match.start(1)]
                    n_result += action(match.group(2))
                    s = match.end(2)
                    found_match = True

            if found_match is True:
                print(n_result)
            else:
                result = ''
                s = 0
                while True:
                    match = pattern4.search(i,s)
                    if match is None:
                        result += i[s:]
                        break
                    else:
                        result = i[s:match.start(1)]
                        result += action(match.group(1))
                        s = match.end(1)
                print(result)

    fin.close()

if __name__ == "__main__":
    ap = argparse.ArgumentParser(
        description="convert ip form between prefix <-> mask <-> inverse mask",
        epilog = "Happy coding!",
        prefix_chars='-'
        )
    #add position mandatory argument
    ap.add_argument('-f', action='store', help="file for conversion, one entry per line")
    ap.add_argument('-p2m', action='store_true', help="prefix to mask")
    ap.add_argument('-m2p', action='store_true', help="mask to prefix")
    ap.add_argument('-p2i', action='store_true', help="prefix to inverse mask")
    ap.add_argument('-m2i', action='store_true', help="mask to inverse mask")
    ap.add_argument('--version','-v',action="version",version='%(prog)s 0.1')

    #default namespace return 
    args = ap.parse_args()
    main(args)
