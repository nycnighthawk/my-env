#!/bin/env python
import system
import argparse
import socket
import select
import struct
import logging
import os
import time
import signal

signal.signal(signal.SIGTERM, signal.SIG_IGN)
signal.signal(signal.SIGHUP, signal.SIG_IGN)
signal.signal(signal.SIGINT, signal.SIG_IGN)

logging.basicConfig(format='%(asctime)s %(message)s',level=logging.DEBUG)

telnet_opts = (0xff, 0xfb, 0x01,
               0xff, 0xfb, 0x03,
               0xff, 0xfb, 0x00,
               0xff, 0xfd, 0x00)

telnet_opts = struct.pack("12B", *telnet_opts)

parent, child = socket.socketpair(socket.AF_UNIX, socket.SOCK_STREAM)

# set up the fd without any buffer, like autoflushing
parent_fd = os.fdopen(parent.fileno(),'rw',0)
child_fd = os.fdopen(child.fileno(),'rw',0)

# set up listening socket
LOOPBACK = '127.0.0.10'
MAXCONNECTIONS = 20
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock_fd = sock.fileno()
os.fdopen(sock_fd,'rw',0)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock.bind((LOOPBACK, 10001))
sock.setblocking(0)
sock.listen(20)

epoll = select.epoll()
epoll.add(sock_fd, select.EPOLLIN)

def server_run(epoll, sock_fd, child_fd):
    """ main server loop to handle incoming connections
    """
    telnet_opts = (0xff, 0xfb, 0x01,
               0xff, 0xfb, 0x03,
               0xff, 0xfb, 0x00,
               0xff, 0xfd, 0x00)

    telnet_opts = struct.pack("12B", *telnet_opts)

    connections = {}
    epoll.add(sock_fd, select.EPOLLIN)
    epoll.add(child_fd, select.EPOLLIN|select.EPOLLOUT)
    control_fd = None
    BUFFER_SIZE = 1024
    while True:
        events = epoll.poll()
        for fd, event in events:
            if fd == sock_fd:
                connection, address = sock.accept()
                client_fd = connection.fileno()
                connection.setblocking(0)
                if control_fd is None
                    control_fd = client_fd
                    connections[client_fd] = [1,telnet_opts]
                    epoll.register(client_fd, select.EPOLLIN|select.EPOLLOUT)
                else:
                    connections[client_fd] = [0,telnet_opts]
                    epoll.register(client_fd, select.EPOLLOUT)
                bytes_out = os.write(client_fd,telnet_opts)
                connections[client_fd][1] = connections[client_fd][1][bytes_out:]
                continue
            if event & select.EPOLLIN:
                if fd == control_fd:
                    data = os.read(fd, BUFFER_SIZE)
                    if len(data) == 
                pass
            elif event & select.EPOLLHUP:
                pass
            elif event & select.EPOLLOUT:
                pass
            if fd == child_fd:
                pass
            #only perform write since it's not a controlling sessions

pid = os.fork()
if pid == 0:
#child
    child.close()
    sock_fd.close()
    os.dup2(parent_fd_out.fileno(),sys.stdin.fileno())
    os.dup2(parent_fd_in.fileno(),sys.stdout.fileno())
    time.sleep(1)
    os.execv('/bin/bash',[''])
else:
#parent
    parent.close()
    epoll.add(child_fd, select.EPOLLIN | select.EPOLLOUT)
    server_run()


my $selector = IO::Select->new() || die "Can't create Select object!\n";
$selector->add($listen_sock, $childpipe);
setupsig();
if (!defined($kid = fork)) {
    die "Can not fork: $!";
} elsif ($kid == 0) {
        close CHILD;
        open(STDIN,  "<&PARENT");
        open(STDOUT, ">&PARENT");
        sleep 3;
        exec {$opts{'m'}} $opts{'n'}, @ARGV;
        die "Can not run $opts{'m'}: $!\n";
}
close PARENT;
#print "Parent ID is $$\nChild ID is $kid\n";
print "$$\n$kid\n";
while (1) {
        my @ready = $selector->can_read;
        for $handle (@ready) {
                if ($handle eq $listen_sock) {
                        $connect_sock = $listen_sock->accept();
                        $selector->add($connect_sock);
                        $selector->remove($listen_sock);
                        $connect_sock->autoflush(1);
                        syswrite($connect_sock, $telopt);
                        sysread($connect_sock, $user_input, 80);
                } elsif ($handle eq $connect_sock) {
                        $bytes = sysread($handle, $user_input, 80);
                        if ($bytes == 0) {
                                $selector->add($listen_sock);
                                $selector->remove($connect_sock);
                                $connect_sock->shutdown(2);
                                $connect_sock = 0;
                        } else {
                                syswrite(CHILD, $user_input);
                        }
                } elsif ($handle eq $childpipe) {
                        $bytes = sysread($handle, $user_input, 80);
                        if ($bytes == 0) {
                                close $connect_sock if ($connect_sock);
                                close $listen_sock;
                                exit(1);
                        } else {
                                if ($connect_sock) {
                                        syswrite($connect_sock, $user_input);
                                }
                        }
                }
        }
}
sub setupsig {
        $SIG{INT}  = 'IGNORE';
        $SIG{TERM} = 'IGNORE';
        $SIG{HUP}  = 'IGNORE';
        $SIG{HUP}   = \&catch_sig_exit;
        $SIG{INT}   = \&catch_sig_exit;
        $SIG{HUP}   = \&catch_sig_exit;
        $SIG{KILL}  = \&catch_sig_exit;
        $SIG{CHLD}  = \&catch_sig_child;
}
sub catch_sig_exit {
        close $connect_sock if ($connect_sock);
        close $listen_sock  if ($listen_sock);
        kill(9, $kid) if ($kid);
        print STDERR "Killed child process $kid\n";
        exit 1;
}
sub catch_sig_child {
        close $connect_sock if ($connect_sock);
        sleep 1;
        print STDERR "Program $opts{'m'} with process ID $kid exit!\n";
        exit 1;
}
sub usage {
    print <<USAGE;

Usage: $0 -m <program> -p <port number> -n <name> -- [OPTIONS]

  -m <program>     Program will be wrappered, enter full path if needed.
  -p <port number> Port number to access the program, default is 10000.
  -n <name>        Process name for executed program, optional.
  [OPTIONS]        All the options/arguments passed to executed program.

USAGE
        exit;
}
