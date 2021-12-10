#!/usr/bin/env python
# Copyright (C) 2013 Han Chen <hchen@metlife.com>
# All rights reserved. No warranty, explicit or implicit, provided

# device file format
# host or ip, os_type: ios|catos, protocol: telnet|ssh, config_file

# config_file format begins with optional control information
# all control information begin with #
# commands are one per line with optional expect string
# the command can take variable substitution
# comment can be entered by using ! in the beginning of the line
#
# #userid='userid'
# #userpassword='userpassword'
# command[,][expect string]

#command variable substitution
#{h} = host based on the device file
#{d} = current date in the format of yyyy-mm-dd

from multiprocessing import Process, Queue
import pexpect
import time
import argparse
import csv
import getpass
import socket
import datetime

def login_telnet(host, user_id, user_pass, enable_pass, shell_prompt):
    child = pexpect.spawn("telnet %s" % (host))
    reason = ""
    try:
        reason = "failed to match password prompt"
        child.expect_exact("word:")
        child.sendline(user_pass)
        reason = "failed to match shell prompt"
        index = child.expect_exact(shell_prompt)
        if index == 0:
            return (0,child)
        if len(child.buffer) < 3:
            reason = "failed to enter enable mode"
            child.sendline("enable")
            if enable_pass != '':
                child.expect_exact("word:")
                child.sendline(enable_pass)
            index = child.expect_exact(shell_prompt)
            if index == 0:
                return (0, child)
            else:
                return (1, reason)
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
        reason = "failed to match shell prompt"
        index = child.expect_exact(shell_prompt)
        if index == 0:
            return (0,child)
        if len(child.buffer) < 3:
            reason = "failed to enter enable mode"
            child.sendline("enable")
            if enable_pass != '':
                child.expect_exact("word:")
                child.sendline(enable_pass)
            index = child.expect_exact(shell_prompt)
            if index == 0:
                return (0, child)
            else:
                return (1, reason)
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

def auto_config(queue, hostinfo, prot, os_type, user_id, user_pass, enable_pass, 
                cmd_file, log=False):

    """ configure the device based on the configuration file
    """

    with open(cmd_file,'r') as in_f:
        # process the control information at the beginning of the cmd file

        cur_pos = 0
        ctl_info = {}
        while True:
            l = in_f.readline()
            if l[0] == '#':
                cur_pos = in_f.tell()
            else:
                in_f.seek(cur_pos)
                break
            l = l.rstrip()
            try:
                i = l.index('=')
            except:
                queue.put((hostinfo, 1, "invalid command file"))
                return
            ctl_info[l[1:i]]=l[i+1:]

        u_id = user_id
        u_password = user_pass

        if 'userid' in ctl_info:
            u_id = ctl_info['userid']
        if 'userpassword' in ctl_info:
            u_password = ctl_info['userpassword']

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
                status, child = login_telnet(host, u_id, u_password, enable_pass,
                    catos_prompt)
            elif prot == "ssh":
                status, child = login_ssh(host, u_id, u_password, enable_pass,
                    catos_prompt)
            os_prompt = '(enable)'
        elif os_type == "ios" or os_type == "nxos":
            if prot == "telnet":
                status, child = login_telnet(host, u_id, u_password, enable_pass,
                    ios_prompt)
            elif prot == "ssh":
                status, child = login_ssh(host, u_id, u_password, enable_pass,
                    ios_prompt)
            os_prompt = '#'
        else:
            queue.put((hostinfo, 1, "invalid os type"))
            return
        if log is True:
            f_out = open(hostinfo+".log","w")
            child.logfile = f_out

        t_stop = time.time()
        print("%s took %d sec(s) to login" % (hostinfo, t_stop - t_start))
        if status != 0:
            queue.put((hostinfo, 1, "failed to login %s: " % (child)))
            return

        child.delaybeforesend = 0.001

        reader = csv.reader(in_f)
        prompt = None

        t_start = time.time()           
        for i in reader:
            if len(i) == 1 or i[1] == '':
                prompt = os_prompt
                if i[0].startswith('!'):
                    continue
            else:
                prompt = i[1]
            #perform variable subsitution, currently, support single variable
            #subsitution with device name
            flag = False
            replace_flag = False
            cmd_buffer = []
            var = ''
            flag_suppress_output = False
            for c in i[0]:
                if c == '\\':
                    flag = True
                    continue
                if flag is True:
                    flag = False
                    cmd_buffer.append(c)
                else:
                    if c == '{':
                        replace_flag = True
                        continue
                    if replace_flag is True:
                        if c == 'h':
                            var = hostinfo
                            continue
                        elif c == 'd':
                            t = datetime.datetime.now()
                            var = "{}-{}-{}".format(t.year,t.month,t.day)
                            continue
                        elif c == 'u':
                            var = u_id
                            continue
                        elif c == 'p':
                            var = u_password
                            flag_suppress_output = True
                            continue
                        elif c != '}':
                            continue
                        cmd_buffer.append(var)
                        replace_flag = False
                    else:
                        cmd_buffer.append(c)
            cmd_to_send = ''.join(cmd_buffer)
            #status, reason = exec_single_command(child, i[0].lstrip(), prompt)
            status, reason = exec_single_command(child, cmd_to_send.lstrip(), prompt)

            if status != 0:
                queue.put((hostinfo, 1, reason))
                print("%s: command '%s' failed" % (hostinfo,cmd_to_send.lstrip()))
                return
            if flag_suppress_output is not True:
                print("%s: command '%s' executed successfully" % (hostinfo,cmd_to_send.lstrip()))
        t_stop = time.time()
        print("%s took %d sec(s) to complete all config" % (hostinfo, t_stop - t_start))
        child.close()

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
        enable_pass = getpass.getpass("Enable password: ")

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
