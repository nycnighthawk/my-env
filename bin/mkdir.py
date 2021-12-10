#!/bin/env python
import os
import sys

def mkdir(path, mkdir_func, dir_exists_func):
    """ recursive make directory
    """
    if path != './':
        path = path.replace('\\', '/')
        if path[0:2] == './':
            path = path[2:]
        dirs = ''
        for directory in path.split('/'):
            dirs += directory
            if dir_exists_func(dirs) is False:
                mkdir_func(dirs)
            dirs += '/'

if __name__ == "__main__":
    for i in sys.argv[1:]:
        mkdir(i, os.mkdir, os.path.isdir)
