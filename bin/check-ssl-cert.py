#!/usr/bin/env python
from typing import Tuple
import os
import sys
import socket
import re

re_ip = re.compile(r'\d+\.\d+\.\d+\.\d+')


def verify_port(port: int):
    if not 0 < port <= 65535:
        raise ValueError('port must be between 1 and 65535')
    return port


def command_format(host_info: Tuple[str, int, str]):
    cmd_template = (
        """echo | timeout 3 openssl s_client -tls1_2 {2}-connect """
        """{0}:{1} 2>/dev/null | """
        """sed -n '/Certificate chain/,/Server certificate/p; """
        """/subject=\|issuer=/p' | grep -v -E '\-\-\-|Server certificate'""")

    return cmd_template.format(
        host_info[0], host_info[1],
        (lambda s: f'-servername {s} ' if s else s)(host_info[2]))


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-host', action='store', required=True,
        help='host name or ip address to retrieve the certificate')
    parser.add_argument(
        '-port', action='store', default=443, type=int,
        help='tcp port, default to 443, port must be between 1 and 65535')
    parser.add_argument(
        '-sni', action='store', help='sni to use, for example, www.yahoo.com',
        default='')
    args = parser.parse_args()
    try:
        args.port = verify_port(args.port)
    except ValueError:
        print(f"\ninvalid port specified!, {args.port}\n", file=sys.stderr)
        parser.print_help()
        exit(1)

    try:
        addr_infos = socket.getaddrinfo(args.host, args.port, socket.AF_INET,
                                proto=socket.IPPROTO_TCP)
        if re_ip.match(args.host) is None:
            args.sni = args.host
        host_infos = [(addr_info[-1][0], addr_info[-1][1], args.sni)
                     for addr_info in addr_infos]
    except Exception as error:
        print(f"\n{error}\n", file=sys.stderr)
        parser.print_help()
        exit(1)

    for host_info in host_infos:
        print(f"connecting to {host_info[0]}:{host_info[1]}")
        os.system(command_format(host_info))
        print('-' * 60)
