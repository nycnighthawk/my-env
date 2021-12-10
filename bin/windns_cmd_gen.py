#!/usr/bin/env python
import re
import argparse

def main(args):

    with open(args.infile) as fstream:
        linenum = 0
        zonename = None
        rec_dat = None
        while True:
            line = fstream.readline()
            if line == '':
                break
            linenum += 1
            line = line.rstrip()
            try:
                if ',' in line:
                    name, ip = line.split(',')
                    # remove space
                    name = "".join(name.split())
                    ip = "".join(ip.split())
                else:
                    name, ip = line.split()
            except ValueError:
                print("Error in line {}:".format(linenum, line))
                continue
            if args.domain is not None:
                zonename = args.domain
            else:
                zonename = ".".join(name.split('.')[1:])
            # generate the forward record lookup
            print("dnscmd {} /RecordAdd {} {} A {}".format(args.server, 
                zonename, name, ip))
            reversed_ip = ip.split('.')[::-1]
            if int(reversed_ip[-1]) == 10:
                zonename = '10.in-addr.arpa'
                rec_dat = ".".join(reversed_ip[:-1])
            else:
                zonename = '.'.join(reversed_ip[1:]) + '.in-addr.arpa'
                rec_dat = revered_ip[0]
            if args.domain is not None:
                name += '.' + args.domain
            # generate the reverse record lookup
            print("dnscmd {} /RecordAdd {} {} PTR {}".format(args.server,
                zonename, rec_dat, name))

if __name__ == '__main__':
    
    argparser = argparse.ArgumentParser(description="Generate dns cli command \
        for windows os")

    argparser.add_argument('infile', help="input file with the format of \
        'name ip', or 'name, ip'")
    argparser.add_argument('-domain', help="domain name for the input file, if \
        not specified, fqdn is assumed in the input file")
    argparser.add_argument('-server', default='10.9.167.76', help="name or ip address \
        of the DNS server")

    args = argparser.parse_args()
    main(args)
