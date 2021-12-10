#!/usr/bin/env python

# Copyright (c) 2013 
# Author: Han Chen <hchen@metlife.com>
# All Rights Reserved
# Version: 0.1

import argparse
import sys
import re
from lxml import etree
from copy import deepcopy

def getNode1(node, tag):
    ''' return the node with the specific tag via depth first search
        if not found, return None

        return: node in the xml tree
    '''
    if type(tag) != type(''):
        raise ValueError('expect string in tag value')
    nodes = [node]

    while True:
        n = nodes.pop(0)
        if len(n) > 0:
            tmp = []
            for child in n:
                if child.tag == tag:
                    return child
                tmp.append(child)
            nodes = tmp + nodes
    return None

def getNode2(node, tag):
    ''' return the node with the specific tag by searching the immediate children
        if not found, return None

        return: node in the xml tree
    '''
    if type(tag) != type(''):
        raise ValueError('expect string in tag value')

    for child in node:
        if child.tag == tag:
            return child
    return None
        
def main(args):
    if args.t is True:
        global debug_level
        debug_level = 1

    with open(args.xml_file,'r') as fin:
        parser = etree.XMLParser(remove_blank_text=True)
        node = root = etree.parse(fin, parser).getroot()
        canStart = False
        while True:
            for element in node:
                if element.tag == 'devices':
                    node = element
                    break
                if element.tag == 'entry':
                    node = element
                    break
                if element.tag == 'network':
                    node = element
                    break
                if element.tag == 'virtual-router':
                    canStart = True
                    node = element
                    break
            if canStart:
                break
        i = 0
        virtual_router_node = node
        node = getNode2(virtual_router_node,'entry')
        node = getNode2(node,'routing-table')
        node = getNode2(node,'ip')
        node = getNode2(node,'static-route')
        for element in node:
            name = element.get('name')
            next_hop = getNode2(getNode2(element,'nexthop'),'ip-address').text
            dest = getNode2(element,'destination').text
            print('{},{}'.format(dest, next_hop))

if __name__ == "__main__":
    ap = argparse.ArgumentParser(
        description="update firewall policy based on ftp and db ports",
        epilog = "Happy coding!",
        prefix_chars='-'
        )
    #add position mandatory argument
    ap.add_argument('xml_file', help="Palo Alto Firewall xml configuration")

    ap.add_argument('--version','-v',action="version",version='%(prog)s 0.1')
    ap.add_argument('-t', action='store_true', help="print summary")

    #default namespace return 
    args = ap.parse_args()
    main(args)
