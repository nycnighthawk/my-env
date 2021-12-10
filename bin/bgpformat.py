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

def formatoutput(str):
    field = []
    i = 0
    s = 0
    append_needed = False 
    while i < len(str):
        if str[i] == ' ' or str[i] == "\t" or str[i] == "\n":
            if append_needed is True:
                field.append(str[s:i])
                append_needed = False
            i += 1
        else:
            if append_needed is not True:
                s = i
                append_needed = True
            i += 1

    if append_needed is True:
        field.append(str[s:])

    s1 = "{:<3} {:<19} {:<16}".format(field[0],field[1],field[2])
    field = field[3:]
    s2 = " ".join(field)
    return s1 + s2

def main(args):

    outs = OutputWrapper()

    if args.output_file is not None:
        outs.setfileobject(open(args.output_file,'w'))

    re_next_hop = re.compile(r'^\s+152\.181\.109\.93')

    ins = open(args.bgp_capture_file,'r')

    line_prev = None

    for line in ins:
        re_next_hop_match = re_next_hop.match(line)

        if re_next_hop_match is not None:
            outs.write(formatoutput(line_prev.rstrip() + line))
            line_prev = None
        else:
            if line_prev is not None:
                outs.write(formatoutput(line_prev))
            line_prev = line

    if line_prev is not None:
        outs.write(formatoutput(line_prev))

if __name__ == "__main__":
    ap = argparse.ArgumentParser(
        description="format bgp output result",
        )
    #add position mandatory argument
    ap.add_argument('bgp_capture_file', help="'show ip bgp' output capture file")
    #add position optional argument
    ap.add_argument('output_file', nargs='?', help="output to be saved")

    
    args = ap.parse_args()

    main(args)
