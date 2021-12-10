#!/usr/bin/env python
import socket
import re
import argparse
from OpenSSL import SSL, crypto
import OpenSSL

def main(arg):
    def verify_cb(conn, cert, errnum, depth, ok):
        return True

    port = 443
    host = arg
    if ':' in arg:
        host, port = arg.split(':')
        if " " in host or "\t" in host or "\n" in host:
            print("invalid host '{}' used, space is not allowed".format(host))
            exit(1)
        try:
            port = int(port)
        except ValueError:
            print("invalid port '{}' used, port must be an integer".format(port))
            exit(1)

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    ctx = SSL.Context(SSL.SSLv3_METHOD)
    conn = SSL.Connection(ctx, s)
    ctx.set_verify(SSL.VERIFY_NONE, verify_cb)

    try:
        conn.connect((host, port))
        conn.do_handshake()
        cert = conn.get_peer_certificate()

        #match = re_subject.search(cert.get_subject())
        print("Subject Common Name: {}".format(cert.get_subject().CN))
        if cert.get_issuer().CN is None:
            print("Issuer Name: {}".format(cert.get_issuer().OU))
        else:
            print("Issuer Name: {}".format(cert.get_issuer().CN))
        d = cert.get_notBefore()
        print('Not Valid Before: {}-{}-{} {}:{}:{}'.format(d[4:6],d[6:8],d[0:4],d[8:10],d[10:12],d[12:14]))
        d = cert.get_notAfter()
        print('Not Valid After: {}-{}-{} {}:{}:{}'.format(d[4:6],d[6:8],d[0:4],d[8:10],d[10:12],d[12:14]))
        print('RSA key length: {}'.format(cert.get_pubkey().bits()))
    except socket.error as msg:
        print('error connecting to host {}'.format(arg))

    except OpenSSL.SSL.Error as msg:
        print('Error in SSL handshake with host {}'.format(arg))

if __name__ == '__main__':
    ap = argparse.ArgumentParser(
        description='obtain ssl certificate information',
        epilog = 'a simple routine to test openssl'
        )
    ap.add_argument('host', help="host and port information for the connection, ':' must be used to sparate the port from host, if no port is given, 443 is assumed, i.e www.verisign.com, 10.10.10.10:4445")
    args = ap.parse_args()
    main(args.host)
