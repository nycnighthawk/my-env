#!/usr/bin/env python

import argparse
import re

class OutputWrapper(object):
    def __init__(self,*fileobject):
        self._fileobject = None
        if len(fileobject) == 1:
            self._fileobject = fileobject[0] 
       
    def write(self,str):
        if self._fileobject != None:
            if type(str) == type(''):
                self._fileobject.write(str)
            else:
                self._fileobject.write(str.__str__())
            self._fileobject.write("\n")
        else:
            print(str)

    def close(self):
        if self._fileobject != None:
            self._fileobject.close()

    def setfileobject(self,fileobject):
        self._fileobject = fileobject

def main(args):

    filein = None

    try:
        filein = open(args.asa_log,'r')
    except IOError as e:
        print e
        exit()

    line = filein.readline()
    src_ip_re = re.compile(r'vlan107/(\d+\.\d+\.\d+\.\d+)')
    dst_ip_re = re.compile(r'vlan807/(\d+\.\d+\.\d+\.\d+)')
    dst_port_re = re.compile(r'\((\d+)\)')

    outs = OutputWrapper()
    flow_table = {}

    while line != "":
        if "%ASA-6-106100" not in line:
            line = filein.readline()
            continue
        pos1 = line.find('permitted')
        if pos1 == -1:
            line = filein.readline()
            continue
        pos1 += 10
        pos2 = line.find(' ',pos1)
        prot = line[pos1:pos2]
        pos1 = pos2 + 1
        matcher = src_ip_re.match(line,pos1)
        src_ip = matcher.group(1)
        pos1 = line.find('vlan807',matcher.end())
        matcher = dst_ip_re.match(line,pos1)
        dst_ip = matcher.group(1)
        matcher = dst_port_re.match(line,matcher.end())
        dst_port = matcher.group(1)
        hash_key = src_ip+','+dst_ip+','+prot+','+dst_port
        if hash_key not in flow_table:
            flow_table[hash_key] = 1
            outs.write(hash_key)
        line = filein.readline()

    filein.close()

if __name__ == "__main__":
    ap = argparse.ArgumentParser(
        description="Process the ASA log and extract the hit using source, destination, prot, port format",
        )
    #add position mandatory argument
    ap.add_argument('asa_log', help="asa log file name")
    #add position optional argument
    ap.add_argument('csv_output', nargs='?', help="csv file to save the output")
    #add optional argument

    #default namespace return 
    args = ap.parse_args()

    main(args)

