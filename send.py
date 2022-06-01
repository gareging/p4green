#!/usr/bin/env python3
import argparse
import sys
import socket
import random
import struct
#import netaddr

from scapy.all import sendp, send, get_if_list, get_if_hwaddr
from scapy.all import Packet
from scapy.all import Ether, IP, UDP, IPOption

def get_if():
    ifs=get_if_list()
    iface=None # "h1-eth0"
    for i in get_if_list():
        if "eth0" in i:
            iface=i
            break;
    if not iface:
        print('Cannot find eth0 interface')
        exit(1)
    return iface

def main():

    if len(sys.argv)<2:
        print ('pass 1 arguments: <destination>')
        exit(1)

    addr = socket.gethostbyname(sys.argv[1])
    iface = get_if()

    print('sending on interface %s to %s' % (iface, str(addr)))
    #binary_attacker = ''.join([bin(int(x)+256)[3:] for x in sys.argv[2].split('.')])
    #opt = [IPOption('%s%s'%('\x86\x20', str(int(netaddr.IPAddress(sys.argv[2])))))]
    #opt = [IPOption('%s%d'%('\x86\x20', int(netaddr.IPAddress(sys.argv[2]))))]
    #opt = [IPOption('%s'%(str(int(netaddr.IPAddress(sys.argv[2])))))]
    #opt = [IPOption('%s%s'%('\x86\x20', binary_attacker))]
    #opt = [binary_attacker]
    pkt =  Ether(src=get_if_hwaddr(iface), dst='ff:ff:ff:ff:ff:ff') / IP(dst=addr, proto=0x8F) #/ UDP(dport=4321, sport=1234) # / sys.argv[2]
    pkt.show2()
#    while (1):
    sendp(pkt, iface=iface, verbose=False)


if __name__ == '__main__':
    main()
