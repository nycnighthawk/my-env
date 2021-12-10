#!/usr/bin/env python
# Copyright (C) 2013 Han Chen <hchen@metlife.com>
# All rights reserved. No warranty, explicit or implicit, provided

from multiprocessing import Process, Queue
import pexpect
import time
import argparse
import csv
import getpass
import socket

def login_telnet1(host, port, user_id, user_pass):
    
    child = pexpect.spawn("telnet %s %s" % (host,port))
    reason = ""
    try:
        reason = "failed to match username prompt"
        child.expect_exact("name:")
        child.delaybeforesend = 0.001
        child.sendline(user_id)
        reason = "failed to match password prompt"
        child.delaybeforesend = 0.001
        child.expect_exact("word:")
        child.sendline(user_pass)
        child.delaybeforesend = 0.1
        child.sendline("\r")
        while True:
            reason = "failed to match shell prompt"
            index = child.expect_exact(['#','>'])
            if index == 0:
                return (0,child)
            elif index == 1:
                child.sendline('enable')
    except pexpect.EOF:
        return (2, reason)
    except pexpect.TIMEOUT:
        return (1, reason)

def login_telnet2(host, user_id, user_pass, enable_pass):
    
    child = pexpect.spawn("telnet %s" % host)
    reason = ""
    try:
        reason = "failed to match username prompt"
        child.expect_exact("name:")
        child.delaybeforesend = 0.001
        child.sendline(user_id)
        reason = "failed to match password prompt"
        child.delaybeforesend = 0.001
        child.expect_exact("word:")
        child.sendline(user_pass)
        child.delaybeforesend = 0.1
        child.sendline("\r")
        while True:
            reason = "failed to match shell prompt"
            index = child.expect_exact(['#','>'])
            if index == 0:
                return (0,child)
            elif index == 1:
                child.sendline('enable')
                child.expect_exact("word:")
                child.sendline(enable_pass)
    except pexpect.EOF:
        return (2, reason)
    except pexpect.TIMEOUT:
        return (1, reason)
         
def exec_single_command(child, cmd, expect_string):
    try:
        child.sendline(cmd)
        while True:
            child.expect_exact(expect_string)
            if len(child.buffer) < 3:
                return (0, "sucessful")
    except pexpect.EOF:
        return (1, "process close unexpected!")
    except pexpect.TIMEOUT:
        return (1, "'%s:' failed to match '%s' within timeout period" % \
            (cmd, expect_string))

def auto_config(queue, host, user_id, user_pass):
    """ initialize the lab pod
    """
    hostinfo = {}
    hostinfo['R1'] = 3001
    hostinfo['R2'] = 3002
    hostinfo['R3'] = 3003
    hostinfo['R4'] = 3004
    hostinfo['R5'] = 3005
    hostinfo['R6'] = 3006
    hostinfo['SW1'] = 3011
    hostinfo['SW2'] = 3012
    hostinfo['SW3'] = 3013
    hostinfo['SW4'] = 3014
    port = hostinfo[host]
    ios_prompt = ['#','>']

    t_start = time.time()           
    status, child = login_telnet1('labcon-1', port, user_id, user_pass)
    t_stop = time.time()
    if status != 0:
        queue.put((host, 1, "failed to login %s: " % (child)))
        return
    print("%s took %d sec(s) to login" % (host, t_stop - t_start))

    child.delaybeforesend = 0.001

    t_start = time.time()           
    child.sendline('end')
    child.sendline('config t')
    child.sendline('no logging console')
    child.sendline('end')
    child.delaybeforesend = 0.1
    child.sendline('wr mem')
    child.expect_exact('#')
    child.sendline('copy flash:%s.conf startup-config' % (host))
    child.expect_exact(']?')
    child.sendline('\r')
    child.expect_exact('#')
    if 'SW' in host:
        child.sendline('del flash:vlan.dat')
        child.expect_exact('?')
        child.sendline("\r")
        child.delaybeforesend = 0.2
        child.sendline("\r")
    child.delaybeforesend = 0.5
    child.sendline('reload')
    child.delaybeforesend = 0.5
    child.sendline("\r")
    t_stop = time.time()
    print("%s took %d sec(s) to complete all config" % (host, t_stop - t_start))
    child.close()

    queue.put((host, 0, "completed successfully"))

if __name__ == "__main__":
    ap = argparse.ArgumentParser(
        description="this program initialize the CCIE R&S pod in LIC lab",
        epilog = "python is a very cool language",
        prefix_chars='-'
        )

    ap.add_argument('--version','-v',action="version",version='0.2')
    ap.add_argument('host',help='lab host',nargs='*')
    args = ap.parse_args()
    user_id = 'admin'
    password = 'MyTest'
    enable_pass = 'MyTest'
    #user_id = raw_input("Username: ")
    #user_pass = getpass.getpass("Password: ")

    jobs = []

    q = Queue()
    hosts = ['SW1','SW2','SW3','SW4','R1','R2','R3','R4','R5','R6']
    if len(args.host) != 0:
        hosts = args.host

    status, child = login_telnet2('labcon-1',user_id,password,enable_pass)
    if status != 0:
        print("failed to login to clear line, program terminated!")
        exit(1)
    print("Clearing console lines ...")
    child.sendline('clear line 50')
    child.delaybeforesend = 0.1
    child.sendline('\r')
    child.delaybeforesend = 0.1
    child.sendline('clear line 51')
    child.delaybeforesend = 0.1
    child.sendline('\r')
    child.delaybeforesend = 0.1
    child.sendline('clear line 52')
    child.delaybeforesend = 0.1
    child.sendline('\r')
    child.delaybeforesend = 0.1
    child.sendline('clear line 53')
    child.delaybeforesend = 0.1
    child.sendline('\r')
    child.delaybeforesend = 0.1
    child.sendline('clear line 54')
    child.delaybeforesend = 0.1
    child.sendline('\r')
    child.delaybeforesend = 0.1
    child.sendline('clear line 55')
    child.delaybeforesend = 0.1
    child.sendline('\r')
    child.delaybeforesend = 0.1
    child.sendline('clear line 56')
    child.delaybeforesend = 0.1
    child.sendline('\r')
    child.delaybeforesend = 0.1
    child.sendline('clear line 57')
    child.delaybeforesend = 0.1
    child.sendline('\r')
    child.delaybeforesend = 0.1
    child.sendline('clear line 58')
    child.delaybeforesend = 0.1
    child.sendline('\r')
    child.delaybeforesend = 0.1
    child.sendline('clear line 59')
    child.delaybeforesend = 0.1
    child.sendline('\r')
    child.delaybeforesend = 0.1
    child.sendline('clear line 60')
    child.delaybeforesend = 0.1
    child.sendline('\r')
    child.delaybeforesend = 0.1
    child.sendline('clear line 61')
    child.delaybeforesend = 0.1
    child.sendline('\r')
    child.delaybeforesend = 0.1
    child.sendline('clear line 62')
    child.delaybeforesend = 0.1
    child.sendline('\r')
    child.delaybeforesend = 0.1
    child.sendline('clear line 63')
    child.delaybeforesend = 0.1
    child.sendline('\r')
    child.delaybeforesend = 0.1
    child.sendline('clear line 64')
    child.delaybeforesend = 0.1
    child.sendline('\r')
    child.delaybeforesend = 0.1
    child.sendline('clear line 65')
    child.delaybeforesend = 0.1
    child.sendline('\r')
    print("initialize individual lab device")
    for h in hosts:
        t_start = time.time()
            # device name, device ip, os type, access protocol, config file
        while len(jobs) > 30:
            for j in jobs:
                if not j.is_alive():
                    jobs.remove(j)

        p = Process(target=auto_config, args=(q, h, 
                user_id, password))
        jobs.append(p)
        p.start()

        # ensure all of the jobs are ran
        while len(jobs) > 0:
            for j in jobs:
                if not j.is_alive():
                    jobs.remove(j)
        while q.empty() is not True:
            i = q.get()
            print("%s: %s" % (i[0], i[2]))
        t_stop = time.time()
        print("program took %d sec(s) to complete" % (t_stop - t_start))
