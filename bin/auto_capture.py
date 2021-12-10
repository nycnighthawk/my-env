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

def login_telnet(host, user_id, user_pass, enable_pass, shell_prompt):
    child = pexpect.spawn("telnet %s" % (host))
    reason = ""
    try:
        reason = "failed to match username prompt"
        child.expect_exact("name:")
        child.sendline(user_id)
        reason = "failed to match password prompt"
        child.expect_exact("word:")
        child.sendline(user_pass)
        while True:
            reason = "failed to match shell prompt"
            index = child.expect_exact(shell_prompt)
            if index == 0:
                return (0,child)
            elif index == 1:
                if len(child.buffer) < 3:
                    child.sendline("enable")
                    child.sendline(enable_pass)
    except pexpect.EOF:
        return (2, reason)
    except pexpect.TIMEOUT:
        return (1, reason)
         
def login_ssh(host, user_id, user_pass, enable_pass, shell_prompt):
    ssh_command = "ssh -o UserKnownHostsFile=/dev/null " + \
        "-o StrictHostKeyChecking=no -o TCPKeepAlive=yes " + \
        "-o ServerAliveInterval=30 -o CheckHostIP=no -l %s %s" %(user_id, host)
    child = pexpect.spawn(ssh_command)
    reason = ""
    try:
        reason = "failed to match password prompt"
        child.expect_exact("word:")
        child.sendline(user_pass)
        while True:
            reason = "failed to match shell prompt"
            index = child.expect_exact(shell_prompt)
            if index == 0:
                return (0,child)
            elif index == 1:
                if len(child.buffer) < 3:
                    child.sendline("enable")
                    child.sendline(enable_pass)
    except pexpect.EOF:
        return (1, reason)
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

def auto_config(queue, hostinfo, prot, os_type, user_id, user_pass, enable_pass, 
                cmd_file):

    """ configure the device based on the configuration file
    """

    with open(cmd_file,'r') as in_f:

        child = None
        catos_prompt = ['(enable)','>']

        ios_prompt = ['#','>']
        os_prompt = None

        host = None
        # check if the host can be resolved
        try:
            host = socket.gethostbyname(hostinfo)
        except:
            queue.put((hostinfo, 1, "unable to resolve name"))
            return

        t_start = time.time()           
        if os_type == "catos":
            if prot == "telnet":
                status, child = login_telnet(hostinfo, user_id, user_pass, enable_pass,
                    catos_prompt)
            elif prot == "ssh":
                status, child = login_ssh(hostinfo, user_id, user_pass, enable_pass,
                    catos_prompt)
            os_prompt = '(enable)'
        elif os_type == "ios":
            if prot == "telnet":
                status, child = login_telnet(hostinfo, user_id, user_pass, enable_pass,
                    ios_prompt)
            elif prot == "ssh":
                status, child = login_ssh(hostinfo, user_id, user_pass, enable_pass,
                    ios_prompt)
            os_prompt = '#'
        else:
            queue.put((hostinfo, 1, "invalid os type"))
            return

        t_stop = time.time()
        print("%s took %d sec(s) to login" % (hostinfo, t_stop - t_start))
        if status != 0:
            queue.put((hostinfo, 1, "failed to login %s: " % (child)))
            return

        child.delaybeforesend = 0.001

        reader = csv.reader(in_f)
        prompt = None
     
        outf = None
        try:
            outf =  open("%s.txt"%(hostinfo), "w")
        except:
            outf = None
            print("unable to create file: %s.txt" % (hostinfo))
        if outf is not None:
            child.logfile = outf
        t_start = time.time()           
        for i in reader:
            if len(i) == 1 or i[1] == '':
                prompt = os_prompt
            else:
                prompt = i[1]
            status, reason = exec_single_command(child, i[0].lstrip(), prompt)
            if status != 0:
                queue.put((hostinfo, 1, reason))
                print("%s: command '%s' failed" % (hostinfo,i[0].lstrip()))
                return
            print("%s: command '%s' executed successfully" % (hostinfo,i[0].lstrip()))
        t_stop = time.time()
        print("%s took %d sec(s) to complete all config" % (hostinfo, t_stop - t_start))
        child.close()
        if outf is not None:
            outf.close()
        queue.put((hostinfo, 0, "completed successfully"))

if __name__ == "__main__":

    ap = argparse.ArgumentParser(
        description="this program takes an device list input file and " + \
                    "execute the commands against the device",
        epilog = "python is a very cool language",
        prefix_chars='-'
        )

    ap.add_argument('--device_list',
        help="a csv file with the format of: device, " + \
        "os type, access protocol, config file", required=True)

    ap.add_argument('--version','-v',action="version",version='0.2')

    args = ap.parse_args()
    with open(args.device_list,'r') as in_f:
        t_start = time.time()
        reader = csv.reader(in_f)
        jobs = []
        user_id = raw_input("Username: ")
        user_pass = getpass.getpass("Password: ")
        #enable_pass = getpass.getpass("Enable password: ")
        enable_pass = user_pass

        #store process result
        q = Queue()
        
        for r in reader:
            # device name, device ip, os type, access protocol, config file
            d, os_t, ap, cf = r
            while len(jobs) > 30:
                for j in jobs:
                    if not j.is_alive():
                        jobs.remove(j)

            p = Process(target=auto_config, args=(q, d, ap, os_t,
                    user_id, user_pass, enable_pass, cf))
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
