#!/usr/bin/env python

import argparse
import sys

class NameSpace(object):
    pass

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

    pass

if __name__ == "__main__":
    t = NameSpace()
    ap = argparse.ArgumentParser(
        description="",
        epilog = "showing at the end",
        prefix_chars='-+/'
        )
    #add position mandatory argument
    ap.add_argument('pos_arg', help="")
    #add position optional argument
    ap.add_argument('pos_opt', nargs='?', help="", default='default value')
    #add optional argument

    #argument variable will be 'd'
    ap.add_argument('-opt','-o','/o', dest='d', help="", action="append", required=True)
    #same as previous
    #ap.add_argument('-opt','-o','/o', dest='d',help="",nargs='+', required=True
    
    ap.add_argument('--version','-v',action="version",version='%(prog)s 2.0')

    #argument variable will be 't'
    ap.add_argument('-t',metavar='ttt',required=True)

    #default namespace return 
    args = ap.parse_args()

    print args.pos_arg
    print args.d
    print args.pos_opt


    #parse to a namespace object t
    ap.parse_args(namespace=t)

