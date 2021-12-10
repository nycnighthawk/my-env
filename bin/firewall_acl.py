#!/usr/bin/env python

import sys

class OutputWrapper(object):
    def __init__(self,*fileobject):
        self._fileobject = None
        if len(fileobject) == 1:
            self._fileobject = fileobject[0]

    def writeln(self,str):
        self.write(str)
        self.write("\n")

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

class OverlappingException(Exception):
    def __init__(self,msg):
        super(OverlappingException,self).__init__()
        self._msg = msg

    def __str__(self):
        return self._msg

class InvalidArgument(Exception):
    def __init__(self, msg):
        super(InvalidArgument, self).__init__()
        self._msg = msg

    def __str__(self):
        return self._msg

class CLI(object):
    EXIT = 0
    GLOBAL = 1
    RULE = 2
    def __init__(self):
        self._line_input = None
        self._mode = self.GLOBAL
        self._rule_number = None

    def run(self):
        
        while self._mode != self.EXIT:
            self.prompt()
            self.wait_for_input()
            self.process_input()
            self._mode = self.EXIT

    def prompt(self):
        if self._mode == self.GLOBAL:
            sys.stdout.write("> ")
        elif self._mode == self.RULE:
            sys.stdout.write("RULE {}>".format(self._rule_number))

    def wait_for_input(self):
        self._line_input = sys.stdin.readline().rstrip()

    def process_input(self):
        sys.stdout.write(self._line_input)

class Service(object):

    IP = 256
    TCP = 6
    UDP = 17

    PROTOCOL = {}
    PROTOCOL[6] = 'TCP'
    PROTOCOL[17] = 'UDP'
    PROTOCOL[256] = 'IP'

    def __init__(self,svc='tcp'):
        self._protocol = Service.TCP
        self._port1 = None
        self._port2 = None
        self._is_port_range_present = False

        self.add(svc)

    def add(self,svc='tcp'):
        if type(svc) == type(1):
            if svc > 0 and svc < 65536:
                self._port1 = svc
            else:
                raise InvalidArgument("Invalid Port specified!")
        elif type(svc) == type(''):
            svc = svc.lower()
            if svc == 'ip':
                self._protocol = Service.IP
            elif len(svc) >= 3:
                if svc[0:3] == 'tcp':
                    self._protocol = Service.TCP
                elif svc[0:3] == 'udp':
                    self._protocol = Service.UDP
                if len(svc) > 3:
                    if '/' != svc[3]:
                        raise InvalidArgument("Invalid protocol port format specified!")
                    if '-' in svc[4:]:
                        port = svc[4:].split('-')
                        if len(port) > 2:
                            raise InvalidArgument("cannot be multiple range")
                        try:
                            self._port1 = int(port[0])
                            self._port2 = int(port[1])
                            if self._port1 <= 0 or self._port1 > 65535:
                                raise ValueError
                            if self._port2 <= 0 or self._port2 > 65535:
                                raise ValueError
                            if self._port1 >= self._port2:
                                raise ValueError
                        except:
                            raise InvalidArgument("Invalid Port specified!")
                    else:   # just a pure port
                        try:
                            self._port1 = int(svc[4:])
                            if self._port1 <= 0 or self._port1 > 65535:
                                raise ValueError
                        except:
                            raise InvalidArgument("Invalid port specified!")

                    if self._port1 is not None and self._port2 is not None:
                        self._is_port_range_present = True
            else:   #svc length < 3 and is not 'ip'
                raise InvalidArgument("Unsupported protocol specified")
        else:
            raise InvalidArgument("Unsupported protocol specified")

    def getProtocol(self):
        return self._protocol

    def getPort1(self):
        return self._port1

    def getPort2(self):
        return self._port2

    def hasPortRange(self):
        return self._is_port_range_present

    @staticmethod
    def protocol_to_text(protocol):
        return Service.PROTOCOL.get(protocol) 

    def __str__(self):
        s = []
        s.append("protocol: {}".format(Service.protocol_to_text(self._protocol)))
        if self._is_port_range_present is True:
            s.append("\nPort range: {} - {}".format(self._port1,self._port2))
        else:
            if self._port1 is not None:
                s.append("\nPort: {}".format(self._port1))

        return "".join(s)

class IPv4(object):
    def __init__(self,ip=''):
        self._prefix = 0
        self._address = 0
        self._isNetwork = True
        self.add(ip)

    def add(self,ip=''):
        tmp = None
        if ip == '':
            self._address = 0
            self._prefix = 0
            return
        try:
            self._address, self._prefix = IPv4.to_address_prefix_pair(ip)
            self._address = IPv4.ip_to_int(self._address)
        except:
            raise InvalidArgument("Invalid IP specified!")
        if self._prefix == 32:
            self._isNetwork = False
  
    def getAddress(self):
        return IPv4.int_to_ip(self._address)

    def getPrefix(self):
        return self._prefix

    def getMask(self):
        return IPv4.prefix_to_mask(self._prefix)

    def isNetwork(self):
        return self._isNetwork

    def __eq__(self, ipv4):
        if isinstance(ipv4,IPv4) is False:
            raise ValueError
        if ipv4._prefix != self._prefix:
            return False
        if ipv4._address != self._address:
            return False
        return True

    def __neq__(self, ipv4):
        return not self.__eq__(ipv4)

    def __str__(self):
        s = []
        return "{}/{}".format(IPv4.int_to_ip(self._address),self._prefix)

    @staticmethod
    def prefix_to_mask(prefix):
        if prefix < 0 or prefix > 32:
            raise ValueError
        mask = 4294967295 >> (32 - prefix) << (32 - prefix)
        return IPv4.int_to_ip(mask)

    @staticmethod
    def mask_to_prefix(mask):
        i = IPv4.ip_to_int(mask)
        count = 0
        mask = 2147483648   #128.0.0.0
        while True:
            if (i & mask) != 0:
                count += 1
                mask = mask >> 1
            else:
                if mask > 1 and (i & (mask - 1)) != 0:
                    raise ValueError
                return count

    @staticmethod
    def to_network(ip, prefix):
        mask = 4294967295 >> (32 - prefix) << (32 - prefix)
        return IPv4.ip_to_int(ip) & mask

    @staticmethod
    def to_address_prefix_pair(address):
        tmp = None
        prefix = 32
        ip = address
        if '/' in address:
            tmp = address.split('/')
            if len(tmp) > 2:
                raise ValueError
            ip = tmp[0]
            prefix = int(tmp[1])
            if prefix < 0 or prefix > 32:
                raise ValueError
        return (ip,prefix)

    @staticmethod
    def is_subnet(address1,address2):
        ip1, prefix1 = IPv4.to_address_prefix_pair(address1)
        ip2, prefix2 = IPv4.to_address_prefix_pair(address2) 

        if prefix1 < prefix2:
            return False
        if prefix1 == prefix2:
            if ip1 == ip2:
                return True
            return False
        if IPv4.to_network(ip1,prefix2) == IPv4.to_network(ip2,prefix2):
            return True
        return False

    @staticmethod
    def ip_to_int(address):
        octate = address.split('.')
        if len(octate) != 4:
            raise ValueError
        octate[0] = int(octate[0])
        octate[1] = int(octate[1])
        octate[2] = int(octate[2])
        octate[3] = int(octate[3])
        if octate[0] < 0 or octate[0] > 255:
            raise ValueError
        if octate[1] < 0 or octate[1] > 255:
            raise ValueError
        if octate[2] < 0 or octate[2] > 255:
            raise ValueError
        if octate[3] < 0 or octate[3] > 255:
            raise ValueError

        address = octate[0]<<24 | octate[1]<<16 | octate[2]<<8 | octate[3]
        return address

    @staticmethod
    def int_to_ip(address):
        if address < 0 or address > 4294967295:
            raise ValueError
        octate4 = address & 255
        octate3 = (address & 65280) >> 8
        octate2 = (address & 16711680) >> 16
        octate1 = (address & 4278190080) >> 24
        return "{}.{}.{}.{}".format(octate1,octate2,octate3,octate4)

class Rule(object):
    PERMIT = 1
    DENY = 2

    def __init__(self):
        self._source = []
        self._destination = []
        self._service = []
        self._action = Rule.PERMIT

    def setAction(self,action):
        self._action = action

    def addSource(self, ip):
        self._addAddress(self._source, ip)

    def removeSource(self, ip):
        self._removeAddress(self._source, ip)

    def addDestination(self, ip):
        self._addAddress(self._destination, ip)

    def removeDestination(self, ip):
        self._removeAddress(self._destination, ip)

    def addService(self, svc):
        pass

    def removeService(self, svc):
        pass

    def _addAddress(self, target, ip):
        ip_considered = IPv4(ip)

        overlapped_source = []
        for i in target:
            if IPv4.is_subnet(i.__str__(), ip_considered.__str__()) is True:
                overlapped_source.append(i)
            elif IPv4.is_subnet(ip_considered.__str__(),i.__str__()) is True:
                raise OverlappingException("{} is a subnet of existing address {}".format(ip_considered.__str__(),i.__str__()))

        if len(overlapped_source) > 0:
            s = []
            for i in overlapped_source:
                s.append("{} ".format(i.__str__()))
            raise OverlappingException("existing address: {} belongs to address '{}' being added".format("".join(s),ip_considered.__str__()))

        target.append(ip_considered)

    def _removeAddress(self, target, ip):
        ip_considered = IPv4(ip)

        i = 0
        length = len(target)
        while i < length:
            if target[i] == ip_considered:
                del(target[i])
                return
            i += 1

    def getSource(self):
        return self._source

    def getDestination(self):
        return self._destination

if __name__ == "__main__":
    #cli = CLI()
    #cli.run()
    out = OutputWrapper()
   
    r = Rule()
    r.addSource('1.1.1.1/32')
    r.removeSource('1.1.1.1/32')
    r.addSource('1.1.1.2/32')
    r.addDestination('1.1.1.0/24')
    r.addDestination('1.1.2.1')

    for i in r.getSource():
        out.writeln(i)

    for i in r.getDestination():
        out.writeln(i)
