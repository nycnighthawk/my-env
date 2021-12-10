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
MAXBACKLOG = 5

logger = setupLogger(__name__)
log = logger.info

def main(args):
    s = socket(AF_INET, SOCK_STREAM)
    s.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
    s.bind((args.ip, args.port))
    s.setblocking(0)
    s.listen(MAXBACKLOG)
    poller = epoll()
    serverfd = s.fileno()
    poller.register(serverfd, EPOLLIN)

    connections = {}
    info = {}
    while True:
        results = poller.poll(0.01)
        for fd, event in results:
            if fd == serverfd:
                clientSocket, addr = s.accept()
                clientSocket.setblocking(0)
                log("client: " + addr[0] + ":" + str(addr[1]) + " connected")
                clientfd = clientSocket.fileno()
                poller.register(clientfd, EPOLLIN)
                connections[clientfd] = (clientSocket, addr[0], str(addr[1]))
                info[clientfd] = [time(), None, 0, b'']
            else:
                handleClient(poller, connections, info, fd, event)

def handleClient(poller, connections, info, fd, event):
    connection, clientIp, clientPort = connections[fd]
    data = info[fd]
    if (event & EPOLLIN) == EPOLLIN:
        t = connection.recv(READBUFFERSIZE)
        if t:
            data[2] += len(t)
            #data[-1] += t 
        else:
            # connection close
            log("client " + clientIp + ':' + clientPort + ' disconnected')
            log(summary(data[0], time(), data[2]))
            del info[fd]
            poller.unregister(fd)
            connection.close()
            del connections[fd]
#    if (event & EPOLLOUT) == EPOLLOUT:
#        if data[-1]:
#            try:
#                bytesSent = connection.send(data[-1])
#                data[-1] = data[-1][bytesSent:]
#            except ConnectionResetError:
#                log("client " + clientIp + ':' + clientPort + ' disconnected')
#                log(summary(data[0], time(), data[2]))
#                clientPoller.unregister(fd)
#                del info[fd]
#                connection.close()
#                del connections[fd]

def summary(startTime, endTime, totalBytesReceived):
    totalSecs = endTime - startTime
    mins, secs = int(totalSecs // 60), totalSecs % 60
    totalTimeStr = "{:.2f} seconds".format(secs)
    hours, mins = mins // 60, mins % 60
    if mins != 0:
        totalTimeStr = str(mins) + " minutes " + totalTimeStr
    days, hours = hours // 24, hours % 24
    if hours != 0:
        totalTimeStr = str(hours) + " hours " + totalTimeStr
    if days != 0:
        totalTimeStr = str(days) + " days " + totalTimeStr
    totalTimeStr = "Total Time: " + totalTimeStr
    totalBytesStr = ''
    kb = totalBytesReceived / 1024
    if kb > 0:
        totalBytesStr = "{:.2f}".format(kb) + "KB"
    if kb > 1024:
        mb = kb / 1024
        totalBytesStr = "{:.2f}".format(mb) + "MB"
        if mb > 1024:
            gb = mb / 1024
            totalBytesStr = "{:.2f}".format(gb) + "GB"
            if gb > 1024:
                tb = gb / 1024
                totalBytesStr = "{:.2f}".format(tb) + "TB"
    return totalTimeStr + "\n" + "Total Received Data: {} bytes ({})".format(totalBytesReceived, totalBytesStr)

def check_args(parser):
    args = parser.parse_args()
    pgn = os.path.basename(sys.argv[0])
    err = {}
    err['port'] = pgn + ': error!, argument -port ' + str(args.port) + ' not valid!'
    err['ip'] = pgn + ': error!, argument -ip ' + args.ip + ' not valid!'
    valid_ips = ['0.0.0.0', '127.0.0.1']
    valid_ips.extend(gethostbyname_ex(gethostname())[2])

    if args.port <= 0 or args.port > 65535:
        print(err['port'], file=sys.stderr)
        return None
    if args.ip not in valid_ips:
        print(err['ip'], file=sys.stderr)
        return None
    return args

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Test python program",
            epilog = 'knowledge is power')

    parser.add_argument('-ip', help = "the listening address", action = 'store',
            default = '0.0.0.0')
    parser.add_argument('-port', default=10080, action = 'store', type=int,
            help="tcp port the server is listening on")

    args = check_args(parser)
    if args:
        main(args)
    else:
        parser.print_help()
