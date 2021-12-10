#!/usr/bin/env python

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

class IPv4(object):
    def __init__(self, ipv4_addr=None):
        """Take a ipv4 string such as a.b.c.d, a.b.c.d/n
        """
        self._ipv4_addr = ipv4_addr
        if ipv4_addr is None:
            return

        if type("") != type(ipv4_addr):
            raise ValueError

        self._ip_add_val, self._ip_net_val, self._ip_broadcast_val, \
        self._pref_len, self._mask_val, self._inv_mask_val, \
        self._shift_factor, self._oct1, self._oct2, self._oct3, \
        self._oct4 = IPv4._toInternalForm(self._ipv4_addr)
    
    @staticmethod
    def _toInternalForm(ipv4_addr):
        if type("") != type(ipv4_addr):
            raise ValueError
        if '/' in ipv4_addr:
            ip, pref_len = ipv4_addr.split('/')
            pref_len = int(pref_len)
            if pref_len < 0 or pref_len > 32:
                raise ValueError
        else:
            ip = ipv4_addr
            pref_len = 32
        shift_factor = 32 - pref_len
        # 255.255.255.255 for initial mask value
        # actual mask value is calculated based on the pref_len
        MASK_CONST = 4294967295
        if shift_factor:
            mask_val = (MASK_CONST >> shift_factor) << shift_factor
        else:
            mask_val = MASK_CONST
        oct1, oct2, oct3, oct4 = ip.split('.')
        oct1 = int(oct1)
        oct2 = int(oct2)
        oct3 = int(oct3)
        oct4 = int(oct4)
        # special case for 0.0.0.0
        if oct1 == 0 and oct2 == 0 and oct3 == 0 and oct4 == 0:
            pass
        else:
            if oct1 <= 0 or oct1 > 255:
                raise ValueError
            if oct2 < 0 or oct2 > 255:
                raise ValueError
            if oct3 < 0 or oct3 > 255:
                raise ValueError
            if oct4 < 0 or oct4 > 255:
                raise ValueError
        ip_add_val = (oct1 << 24) | (oct2 << 16) | (oct3 << 8) | oct4
        ip_net_val = ip_add_val & mask_val
        ip_broadcast_val = (ip_add_val & mask_val) | (MASK_CONST >> pref_len)
        inv_mask_val = MASK_CONST - mask_val
        return ip_add_val, ip_net_val, ip_broadcast_val, pref_len, mask_val, \
        inv_mask_val, shift_factor, oct1, oct2, oct3, oct4

    @staticmethod
    def toInt(ipv4_addr):
        """Take a ipv4 string such as a.b.c.d, a.b.c.d/n, return the interger
           value of the ip address
        """
        return IPv4._toInternalForm(ipv4_addr)[0]
    
    @staticmethod
    def toIP(ipv4_int_val):
        """Take a ipv4 int value and convert to the form of a.b.c.d
        """
        return str(ipv4_int_val>>24) + "." + \
        str((ipv4_int_val & 0xFF0000) >> 16) + "." +\
        str((ipv4_int_val & 0xFF00) >> 8) + "." +\
        str(ipv4_int_val & 0xFF)

    @staticmethod
    def isRFC1918(ipv4_addr):
        """Take an ipv4 string such as a.b.c.d or a.b.c.d/n, return True or
           False if the IP belongs to RFC1918
        """
        # int value for 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
        RFC1918_SCOPE = (167772160, 2886729728, 3232235520)
        
        ip_net_val = IPv4._toInternalForm(ipv4_addr)[1]
        
        if (ip_net_val >> 24 << 24) == RFC1918_SCOPE[0] or \
        (ip_net_val >> 20 << 20) == RFC1918_SCOPE[1] or \
        (ip_net_val >> 16 << 16) == RFC1918_SCOPE[2]:
            return True
        return False
    
    @staticmethod
    def toInverseMaskForm(ipv4_addr):
        """Take an ipv4 string such as a.b.c.d or a.b.c.d/n, return
           a.b.c.d u.v.w.x where u.v.w.x is the inverse mask
        """
        ip_internal_form = IPv4._toInternalForm(ipv4_addr)
        inv_mask = str(ip_internal_form[5] >> 24) + "." + \
        str((ip_internal_form[5] & 0xFF0000) >> 16 ) + "." + \
        str((ip_internal_form[5] & 0xFF00) >> 8) + "." + \
        str(ip_internal_form[5] & 0xFF)
        ip = str(ip_internal_form[7]) + "." + \
        str(ip_internal_form[8]) + "." + str(ip_internal_form[9]) + "." + \
        str(ip_internal_form[10])
        
        return ip, inv_mask

def main(args):
    a = IPv4("2.3.4.5")
    print IPv4.toInt("255.255.255.0/24")

if __name__ == "__main__":
    ap = argparse.ArgumentParser(
        description="",
        epilog = "showing at the end",
        prefix_chars='-+'
        )
    #add position mandatory argument
    ap.add_argument('pos_arg', help="")
    #add position optional argument
    ap.add_argument('pos_opt', nargs='?', help="", default='default value')
    #add optional argument

    #argument variable will be 'd'
    ap.add_argument('-opt', '-o', dest='d', help="", action="append", required=False)
    #same as previous
    #ap.add_argument('-opt','-o','/o', dest='d',help="",nargs='+', required=True
    
    ap.add_argument('--version','-v',action="version",version='%(prog)s 2.0')

    #argument variable will be 't'
    ap.add_argument('-t',metavar='ttt',required=False)

    #default namespace return 
    args = ap.parse_args()
    main(args)
