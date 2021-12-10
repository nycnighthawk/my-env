#!/usr/bin/env python

#Version: 0.1
#Copyright 2012 Han Chen
#All Rights Reserved

import argparse
import sys

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

def main(args):
    out = OutputWrapper()
    try:
        fh = open(args.file ,"r")
        
        uniq_set = {}
        line_num = 0

        for line in fh:
            line = line.rstrip()
            line_num += 1
            if line in uniq_set:
                out.writeln("line " + str(line_num) + " is identical to line " + \
                str(uniq_set[line]))
            else:
                uniq_set[line] = line_num

    except (IOError) as ioerror:
        out.writeln(ioerror)

if __name__ == "__main__":
    ap = argparse.ArgumentParser(
        description="check if a line is duplicate in the file",
        epilog = "Happy coding!",
        prefix_chars='-'
        )
    #add position mandatory argument
    ap.add_argument('file', help="file to be checked")

    ap.add_argument('--version','-v',action="version",version='%(prog)s 0.1')

    #default namespace return 
    args = ap.parse_args()
    main(args)
