#!/usr/bin/env python

__all__ = ['IPv4']
class IPv4(object):
    MASK_CONST = 4294967295
    MAX_PREFIX_LEN = 32
    def __init__(self, ipv4):
        """Take a ipv4 string such as a.b.c.d, a.b.c.d/n
        """
        if type((1,)) == type(ipv4) or type([1,]) == type(ipv4):
            self._ipv4_addr_val = IPv4.toInt(ipv4[0])
            self._ipv4_mask_val = IPv4.toInt(ipv4[1])
            self._ipv4_addr = IPv4.toOctates(self.ipv4_addr_val)
            self._ipv4_mask = IPv4.toOctates(self._ipv4_mask_val)
            self._ipv4_pref_len = IPv4.toPrefix(self._ipv4_mask)
            self._ipv4_net_val = self._ipv4_addr_val & self._ipv4_mask_val
            self._ipv4_net = IPv4.toOctates(self._ipv4_net_val)
            self._ipv4_broadcast_val = (self._ipv4_addr_val & self._ipv4_mask_val) \
            | (IPv4.MASK_CONST >> self._ipv4_pref_len)
            self._ipv4_broadcast = IPv4.toOctates(self._ipv4_broadcast_val)
            self._ipv4_invmask_val = IPv4.MASK_CONST - self._ipv4_mask_val
            self._ipv4_invmask = IPv4.toOctates(self._ipv4_invmask_val)
        elif type("") == type(ipv4):
            if '/' not in ipv4:
                self._ipv4_pref_len = 32
                self._ipv4_addr_val = IPv4.toInt(ipv4)
                self._ipv4_addr = IPv4.toOctates(self._ipv4_addr_val)
                self._ipv4_mask_val = IPv4.prefixToInt(self._ipv4_pref_len)
                self._ipv4_net_val = self._ipv4_addr_val & self._ipv4_mask_val
                self._ipv4_net = IPv4.toOctates(self._ipv4_net_val)
                self._ipv4_broadcast_val = (self._ipv4_addr_val & self._ipv4_mask_val) \
                | (IPv4.MASK_CONST >> self._ipv4_pref_len)
                self._ipv4_broadcast = IPv4.toOctates(self._ipv4_broadcast_val)
                self._ipv4_invmask_val = IPv4.MASK_CONST - self._ipv4_mask_val
                self._ipv4_mask = IPv4.toOctates(self._ipv4_mask_val)
                self._ipv4_invmask = IPv4.toOctates(self._ipv4_invmask_val)
            else:
                self._ipv4_pref_len = int(ipv4[ipv4.index('/')+1:])
                self._ipv4_addr = ipv4[:ipv4.index('/')]
                self._ipv4_addr_val = IPv4.toInt(self._ipv4_addr)
                self._ipv4_mask_val = IPv4.prefixToInt(self._ipv4_pref_len)
                self._ipv4_net_val = self._ipv4_addr_val & self._ipv4_mask_val
                self._ipv4_net = IPv4.toOctates(self._ipv4_net_val)
                self._ipv4_broadcast_val = (self._ipv4_addr_val & self._ipv4_mask_val) \
                | (IPv4.MASK_CONST >> self._ipv4_pref_len)
                self._ipv4_broadcast = IPv4.toOctates(self._ipv4_broadcast_val)
                self._ipv4_invmask_val = IPv4.MASK_CONST - self._ipv4_mask_val
                self._ipv4_mask = IPv4.toOctates(self._ipv4_mask_val)
                self._ipv4_invmask = IPv4.toOctates(self._ipv4_invmask_val)
        else:
            raise ValueError

    @property
    def ipv4_addr(self):
        return self._ipv4_addr

    @property
    def ipv4_addr_val(self):
        return self._ipv4_addr_val

    @property
    def ipv4_mask(self):
        return self._ipv4_mask
    
    @property
    def ipv4_net(self):
        return self._ipv4_net

    @property
    def ipv4_invmask(self):
        return self._ipv4_invmask

    @property
    def ipv4_broadcast(self):
        return self._ipv4_broadcast

    @property
    def ipv4_pref_len(self):
        return self._ipv4_pref_len

    @property
    def ipv4_net_val(self):
        return self._ipv4_net_val

    def __str__(self):
        return "\n".join((self.ipv4_addr,self.ipv4_mask,self.ipv4_net,self.ipv4_broadcast,self.ipv4_invmask))

    @staticmethod
    def toPrefix(mask):
        """ a valid ipv4 mask, return the prefix length
        """
        mask_val = IPv4.toInt(mask)
        p_len = 0
        for i in xrange(IPv4.MAX_PREFIX_LEN):
            if (mask_val & 1) != 0:
                p_len += 1
            elif p_len != 0 and mask_val != 0:
                raise ValueError('not a valid mask: {}'.format(mask))
            mask_val = mask_val >> 1
        return p_len

    @staticmethod
    def prefixToInt(prefix):
        """ Take a prefix /n or n and return the integer value
        """
        p_len = None
        if type(prefix) == type(1):
            if prefix < 0 or prefix > 32:
                raise ValueError('prefix must be between 0 and 32: {}'.format(prefix))
            p_len = prefix
        elif type(prefix) == type(''):
            if '/' in prefix:
                p_len = int(prefix[prefix.index('/')+1:])
                if p_len < 0 or p_len > 32:
                    raise ValueError('prefix must be between 0 and 32: {}'.format(prefix))
            else:
                raise ValueError('not a valid prefix: {}'.format(prefix))

        shift_factor = 32 - p_len
        # 255.255.255.255 for initial mask value
        # actual mask value is calculated based on the pref_len
        MASK_CONST = 4294967295
        mask_val = None
        if shift_factor:
            mask_val = (MASK_CONST >> shift_factor) << shift_factor
        else:
            mask_val = MASK_CONST
        return mask_val

    @staticmethod
    def toInt(ipv4_addr):
        """ Take a ipv4 address a.b.c.d return the integer
        """
        oct1, oct2, oct3, oct4 = ipv4_addr.split('.')
        oct1 = int(oct1)
        oct2 = int(oct2)
        oct3 = int(oct3)
        oct4 = int(oct4)
        # special case for 0.0.0.0
        if oct1 == 0 and oct2 == 0 and oct3 == 0 and oct4 == 0:
            pass
        else:
            if oct1 <= 0 or oct1 > 255:
                raise ValueError('each octate must be between 0 and 255: {}'.format(ipv4_addr))
            if oct2 < 0 or oct2 > 255:
                raise ValueError('each octate must be between 0 and 255: {}'.format(ipv4_addr))
            if oct3 < 0 or oct3 > 255:
                raise ValueError('each octate must be between 0 and 255: {}'.format(ipv4_addr))
            if oct4 < 0 or oct4 > 255:
                raise ValueError('each octate must be between 0 and 255: {}'.format(ipv4_addr))
        ip_val = (oct1 << 24) | (oct2 << 16) | (oct3 << 8) | oct4
        return ip_val

    
    @staticmethod
    def toOctates(ip_val):
        """Take a ipv4 int value and convert to the form of a.b.c.d
        """
        return str(ip_val>>24) + "." + \
        str((ip_val & 0xFF0000) >> 16) + "." +\
        str((ip_val & 0xFF00) >> 8) + "." +\
        str(ip_val & 0xFF)

    @staticmethod
    def isRFC1918(ipv4_addr):
        """Take an ipv4 string such as a.b.c.d or a.b.c.d/n, return True or
           False if the IP belongs to RFC1918
        """
        # int value for 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
        RFC1918_SCOPE = (167772160, 2886729728, 3232235520)
        
        ip_val = IPv4.toInt(ipv4_addr)
        
        if (ip_val >> 24 << 24) == RFC1918_SCOPE[0] or \
        (ip_val >> 20 << 20) == RFC1918_SCOPE[1] or \
        (ip_val >> 16 << 16) == RFC1918_SCOPE[2]:
            return True
        return False

    @staticmethod
    def leastbits(num, size, bits):
        """ take a number, return the least significant bits
            precondition: @num must be integer, @size must be big enough to
            hold the @num in binary format, @size must be integer as well
            and @bits must be integer, @bits <= @size
            param@num:   an integer to process
            param@size:  the size in binary bits for the @num
            param@bits:  number of bits to return
            postcondition: none
        """
        mask = 1
        for i in range(bits - 1):
            mask = ((mask<<1) | 1)
        return num & mask

    @staticmethod
    def mostbits(num, size, bits):
        """ take a number, return the most significant bits
            precondition: @num must be integer, @size must be big enough to
            hold the @num in binary format, @size must be integer as well
            and @bits must be integer, @bits <= @size
            param@num:   an integer to process
            param@size:  the size in binary bits for the @num
            param@bits:  number of bits to return
            postcondition: none
        """
        for i in range (size - bits):
            n >>= 1 
        
        return n

    @staticmethod
    def extract(num, bit_start, bit_end):
        """ take a number and extract the bit range
        """
        mask = 1
        for i in range(bit_end):
            mask = ((mask<<1) | 1)
        n = num & mask
        for i in range(bit_start):
            n >>= 1
        return n
