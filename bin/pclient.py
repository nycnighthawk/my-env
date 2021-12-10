#!/usr/bin/env python
# copyright (C) 2017
# author: Han Chen
# email: hchen@metlife.com
from socket import socket, AF_INET, SOCK_STREAM, SOL_SOCKET, SO_REUSEADDR
from socket import gethostbyname_ex, gethostname
import os
import sys
from select import epoll, EPOLLIN, EPOLLOUT, EPOLLHUP
from time import time, sleep
from mylib import setupLogger

RESOURCENOTAVAILABLE = 11
READBUFFERSIZE = 2048
log = setupLogger(__name__, 'DEBUG').info
MB = 1024 * 1024

def main(args):
    data_size = args.size
    scaling_factor = 1
    if data_size.isdigit():
        data_size = int(data_size)
    else:
        data_unit = data_size[-1]
        data_size = int(data_size[:-1])
        if data_unit == 'B':
            scaling_factor = 1
        elif data_unit == 'K':
            scaling_factor = 1024
        elif data_unit == 'M':
            scaling_factor = 1024 * 1024
        elif data_unit == 'G':
            scaling_factor = 1024 * 1024 * 1024
        else:
            raise ValueError("Unknown unit size")
    data_size *= scaling_factor
    data = b"".join([ b'A' for i in range(READBUFFERSIZE) ])
    poller = epoll()
    connections = {}
    totalSent = 0
    totalRemained = args.n * data_size
    nextReportingInterval = time() + 5
    start_time = time()
    for i in range(args.n):
        s = socket(AF_INET, SOCK_STREAM)
        s.connect((args.ip, args.port))
        s.setblocking(0)
        fd = s.fileno()
        poller.register(fd, EPOLLOUT)
        connections[fd] = [s, data_size]
        results = poller.poll(0.5)
        for fd, event in results:
            totalSent += handleClient(poller, connections, fd, data)
        if time() > nextReportingInterval:
            log("total sent: {} bytes".format(totalSent))
            log("total remained: {} bytes".format(totalRemained))

    while connections:
        results = poller.poll(0.5)
        for fd, event in results:
            totalSent += handleClient(poller, connections, fd, data)
        if time() > nextReportingInterval:
            nextReportingInterval = time() + 5
            log("total sent: {} bytes".format(totalSent))
            log("remaining: {} bytes".format(totalRemained))
    end_time = time()
    print_summary(totalSent, end_time - start_time)

def handleClient(poller, connections, fd, data):
    connection = connections[fd]
    #s.sendall(data)
    #totalSent += READBUFFERSIZE
    #remain -= READBUFFERSIZE
    if connection[1] <= READBUFFERSIZE:
        connection[0].sendall(data[connection[1]:])
        connection[1] = 0
        bytesSent = connection[1]
    else:
        bytesSent = connection[0].send(data)
        connection[1] -= bytesSent
    if connection[1] == 0:
        poller.unregister(fd)
        connection[0].close()
        del connections[fd]
    return bytesSent

def print_summary(bytes, total_time):
    print("total transfer bytes: {}".format(bytes))
    print("total seconds: {:.3f}".format(total_time))
    print("network throughput: {:.2f} bits per second".format((bytes * 8) / total_time))

def check_args(parser):
    import re
    args = parser.parse_args()
    pgn = os.path.basename(sys.argv[0])
    err = {}
    err['port'] = pgn + ': error!, argument -port ' + str(args.port) + ' not valid!'
    err['ip'] = pgn + ': error!, argument -ip ' + args.ip + ' not valid!'

    valid_ip_re = re.compile('(?:2[0-5][0-5]|1[0-9][0-9]|[1-9][0-9]|[1-9])\.(?:(?:2[0-5][0-5]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.){2}(?:2[0-5][0-5]|1[0-9][0-9]|[1-9][0-9]|[0-9])$')
    
    if args.port <= 0 or args.port > 65535:
        print(err['port'], file=sys.stderr)
        return None
    if not valid_ip_re.match(args.ip):
        print(err['ip'], file=sys.stderr)
        return None
    return args

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Test python program",
            epilog = 'knowledge is power')

    parser.add_argument('-ip', help = "the listening address", action = 'store',
            default = '127.0.0.1')
    parser.add_argument('-port', default=10080, action = 'store', type=int,
            help="tcp port the server is listening on")
    parser.add_argument('-size', default = '10M', action = 'store',
            help = "size of data to transmit")
    parser.add_argument('-n', default = 1, action = 'store', type = int,
            help = "number of parallel connections")

    args = check_args(parser)
    if args:
        main(args)
    else:
        parser.print_help()
