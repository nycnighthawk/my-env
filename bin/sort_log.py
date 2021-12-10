#!/usr/bin/env python

import argparse
import sys
import re

class OutputWrapper(object):
    def __init__(self,*fileobject):
        self._fileobject = None
        if len(fileobject) == 1:
            self._fileobject = fileobject[0]

    def writeln(self,str):
        if self._fileobject != None:
            if type(str) == type(''):
                self._fileobject.write(str)
            else:
                self._fileobject.write(str.__str__())
            self._fileobject.write("\n")
        else:
            if type(str) == type(''):
                sys.stdout.write(str)
            else:
                sys.stdout.write(str.__str__())
            sys.stdout.write("\n")

    def write(self,str):
        if self._fileobject != None:
            if type(str) == type(''):
                self._fileobject.write(str)
            else:
                self._fileobject.write(str.__str__())
        else:
            if type(str) == type(''):
                sys.stdout.write(str)
            else:
                sys.stdout.write(str.__str__())

    def __del__(self):
        if self._fileobject is not None:
            self._fileobject.close()

    def setfileobject(self,fileobject):
        self._fileobject = fileobject

def main(infile):

    outs = OutputWrapper()

    ins = None

    try:
        ins = open(infile,'r')
    except:
        outs.writeln("Error opening file {}".format(infile))
        exit(1)
   
    ip_re = re.compile(r'\d+\.\d+\.\d+\.\d+')
    packet_count_re = re.compile(r'(\d+) *packet')
    access_log_re = re.compile(r'IPACCESSLOGP:')

    count = 0
    logs = []
    final_merged_logs = []

    while (True):
        count += 1 

        if (count % 1000000) != 0:
            line = ins.readline()
            if line == "":
                break
            line = line.rstrip("\n")
            ip1 = ip2 = packet_count = None
            match = access_log_re.search(line)
            if match is None:
                count -= 1
                continue
            match = ip_re.search(line,match.end(0))
            if match:
                ip1 = match.group(0)
            else:
                count -= 1
                continue
            match = ip_re.search(line,match.end(0))
            if match:
                ip2 = match.group(0)
            else:
                count -= 1
                continue
            match = packet_count_re.search(line,match.end(0))
            if match:
                packet_count = int(match.group(1))
            else:
                packet_count = 1
            logs.append((ip1,ip2,packet_count))
        else:
            count = 0
            logs = sorted(logs, key = ips_to_int)
            final_merged_logs = merge_sorted_log_entry(final_merged_logs,logs)
            logs = []
            
    ins.close()
    
    if len(logs) > 0:
        logs = sorted(logs, key = ips_to_int)
        final_merged_logs = merge_sorted_log_entry(final_merged_logs,logs)

    outs.writeln("Source,Destination,Hit Count")
    for i in final_merged_logs:
        outs.writeln("{},{},{}".format(i[0],i[1],i[2]))

def ips_to_int(log):
    oct1,oct2,oct3,oct4 = log[0].split('.')
    ip1 = (int(oct1)<<24) | (int(oct2)<<16) | (int(oct3)<<8) | int(oct4)
    oct1,oct2,oct3,oct4 = log[1].split('.')
    ip2 = (int(oct1)<<24) | (int(oct2)<<16) | (int(oct3)<<8) | int(oct4)
    return (ip1,ip2) 

def cmp_log_entry(entry1, entry2):
    t1 = ips_to_int(entry1)
    t2 = ips_to_int(entry2)
    if t1[0] == t2[0]:
        if t1[1] == t2[1]:
            return 0
        elif t1[1] < t2[1]:
            return -1
        else:
            return 1
    elif t1[0] < t2[0]:
        return -1
    else:
        return 1

def merge_sorted_log_entry(list1,list2):
    '''list2 must not be empty
    '''
    outs = OutputWrapper()
    final_list = []
    p1 = 0
    p2 = 0

    use_list1 = True
    use_list2 = True

    list1_length = len(list1)
    list2_length = len(list2)

    if list1_length > 0 and list2_length > 0:
        if cmp_log_entry(list1[0],list2[0]) < 0:
            final_list.append(list1[0])
            p1 = 1
        else:
            final_list.append(list2[0])
            p2 = 1
    elif list1_length > 0:
        final_list.append(list1[0])
        p1 = 1
    elif list2_length > 0:
        final_list.append(list2[0])
        p2 = 1
    else:
        return final_list

    while True:
        if p1 == list1_length:
            use_list1 = False
        if p2 == list2_length:
            use_list2 = False

        if use_list1 is False and use_list2 is False:
            break

        if use_list1 is True and use_list2 is True:
            cmp_result = cmp_log_entry(list1[p1],list2[p2])
            if cmp_result == 0:
                entry = (list1[p1][0],list1[p1][1],list1[p1][2]+list2[p2][2])
                p1 += 1
                p2 += 1
                if cmp_log_entry(final_list[-1],entry) == 0:
                    final_list[-1] = (entry[0],entry[1],entry[2] + final_list[-1][2])
                else:
                    final_list.append(entry)
                continue
            else:
                if cmp_result < 0:
                    if cmp_log_entry(final_list[-1],list1[p1]) == 0: 
                        final_list[-1] = (final_list[-1][0],final_list[-1][1],final_list[-1][2] + list1[p1][2])
                    else:
                        final_list.append(list1[p1])
                    p1 += 1
                    continue
                else:
                    if cmp_log_entry(final_list[-1],list2[p2]) == 0:
                        final_list[-1] = (final_list[-1][0],final_list[-1][1],final_list[-1][2] + list2[p2][2])
                    else:
                        final_list.append(list2[p2])
                    p2 += 1
                    continue
        elif use_list2 is True:
            if cmp_log_entry(final_list[-1],list2[p2]) == 0:
                final_list[-1] = (final_list[-1][0],final_list[-1][1],final_list[-1][2] + list2[p2][2])
            else:
                final_list.append(list2[p2])
            p2 += 1
            continue 
        elif use_list1 is True:
            for i in list1[p1:]:
                final_list.append(i)
            break

    return final_list

if __name__ == "__main__":
    ap = argparse.ArgumentParser(
        description="Sort acl log to unique source destination format",
        epilog = "showing at the end",
        prefix_chars='-+/'
        )
    #add position mandatory argument
    ap.add_argument('infile', help="")
    ap.add_argument('--version','-v',action="version",version='%(prog)s 0.1')

    #default namespace return 
    args = ap.parse_args()

    main(args.infile)
