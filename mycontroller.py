#!/usr/bin/env python3
import argparse
import os
import sys
from time import sleep

import grpc

# Import P4Runtime lib from parent utils dir
# Probably there's a better way of doing this.
sys.path.append(
    os.path.join(os.path.dirname(os.path.abspath(__file__)),
                 '../../utils/'))
import p4runtime_lib.bmv2
import p4runtime_lib.helper
from p4runtime_lib.error_utils import printGrpcError
from p4runtime_lib.switch import ShutdownAllSwitchConnections

SWITCH_TO_HOST_PORT = 1
SWITCH_TO_SWITCH_PORT = 2

def writeForwardingRule(p4info_helper, sw, ip_address, mask, mac_address, port):
    """
    Installs three rules:
    1) An tunnel ingress rule on the ingress switch in the ipv4_lpm table that
       encapsulates traffic into a tunnel with the specified ID
    2) A transit rule on the ingress switch that forwards traffic based on
       the specified ID
    3) An tunnel egress rule on the egress switch that decapsulates traffic
       with the specified ID and sends it to the host

    :param p4info_helper: the P4Info helper
    :param ingress_sw: the ingress switch connection
    :param egress_sw: the egress switch connection
    :param tunnel_id: the specified tunnel ID
    :param dst_eth_addr: the destination IP to match in the ingress rule
    :param dst_ip_addr: the destination Ethernet address to write in the
                        egress rule
    """
    # 1) Tunnel Ingress Rule
    table_entry = p4info_helper.buildTableEntry(
        table_name="MyIngress.ipv4_lpm",
        match_fields={
            "hdr.ipv4.dstAddr": (ip_address, mask)
        },
        action_name="MyIngress.ipv4_forward",
        action_params={
            "dstAddr": mac_address,
            "port": port
        })
    sw.WriteTableEntry(table_entry)
    print("Installed ingress forwarding rule on %s" % sw.name)


def readTableRules(p4info_helper, sw):
    """
    Reads the table entries from all tables on the switch.

    :param p4info_helper: the P4Info helper
    :param sw: the switch connection
    """
    print('\n----- Reading tables rules for %s -----' % sw.name)
    for response in sw.ReadTableEntries():
        for entity in response.entities:
            entry = entity.table_entry
            # TODO For extra credit, you can use the p4info_helper to translate
            #      the IDs in the entry to names
            print(entry)
            print('-----')


def printCounter(p4info_helper, sw, counter_name, index):
    """
    Reads the specified counter at the specified index from the switch. In our
    program, the index is the tunnel ID. If the index is 0, it will return all
    values from the counter.

    :param p4info_helper: the P4Info helper
    :param sw:  the switch connection
    :param counter_name: the name of the counter from the P4 program
    :param index: the counter index (in our case, the tunnel ID)
    """
    for response in sw.ReadCounters(p4info_helper.get_counters_id(counter_name), index):
        for entity in response.entities:
            counter = entity.counter_entry
            print("%s %s %d: %d packets (%d bytes)" % (
                sw.name, counter_name, index,
                counter.data.packet_count, counter.data.byte_count
            ))

def main(p4info_file_path, bmv2_file_path):
    # Instantiate a P4Runtime helper from the p4info file
    p4info_helper = p4runtime_lib.helper.P4InfoHelper(p4info_file_path)
    switch_list = []
    try:
        # Create a switch connection object for s1 and s2;
        # this is backed by a P4Runtime gRPC connection.
        # Also, dump all P4Runtime messages sent to switch to given txt files.
        for i in range(1, 8):
            s = p4runtime_lib.bmv2.Bmv2SwitchConnection(name=f's{i}',address=f'127.0.0.1:5005{i}',device_id=i-1,proto_dump_file=f'logs/s{i}-p4runtime-requests.txt')
            switch_list.append(s)

        # Send master arbitration update message to establish this controller as
        # master (required by P4Runtime before performing any other write operation)
        i = 1
        for s in switch_list:
            s.MasterArbitrationUpdate()
            s.SetForwardingPipelineConfig(p4info=p4info_helper.p4info,
                                       bmv2_json_file_path=bmv2_file_path)
            print(f'Installed P4 Program using SetForwardingPipelineConfig on s{i}')
            i += 1
        # Write the rules that tunnel traffic from h1 to h2
#        writeTunnelRules(p4info_helper, ingress_sw=s1, egress_sw=s2, tunnel_id=100,
#                         dst_eth_addr="08:00:00:00:02:22", dst_ip_addr="10.0.2.2")

        # Write the rules that tunnel traffic from h2 to h1
        writeForwardingRule(p4info_helper, sw=switch_list[0], ip_address="10.0.1.2", mask=32,
                            mac_address="08:00:00:00:02:22", port=2)
        writeForwardingRule(p4info_helper, sw=switch_list[0], ip_address="10.0.1.1", mask = 32,
                            mac_address="08:00:00:00:01:11", port=1)
        writeForwardingRule(p4info_helper, sw=switch_list[0], ip_address="10.0.0.0", mask=8,
                            mac_address="08:00:00:00:02:22", port=3)

        writeForwardingRule(p4info_helper, sw=switch_list[4], ip_address="10.0.1.0", mask=24,
                            mac_address="08:00:00:00:02:22", port=1)
        writeForwardingRule(p4info_helper, sw=switch_list[4], ip_address="10.0.2.0", mask=24,
                            mac_address="08:00:00:00:02:22", port=2)
        writeForwardingRule(p4info_helper, sw=switch_list[4], ip_address="10.0.0.0", mask=8,
                            mac_address="08:00:00:00:02:22", port=3)


        writeForwardingRule(p4info_helper, sw=switch_list[1], ip_address="10.0.2.1", mask=32,
                            mac_address="08:00:00:00:03:33", port=1)
        writeForwardingRule(p4info_helper, sw=switch_list[1], ip_address="10.0.2.2", mask=32,
                            mac_address="08:00:00:00:04:44", port=2)
        writeForwardingRule(p4info_helper, sw=switch_list[1], ip_address="10.0.0.0", mask=8,
                            mac_address="08:00:00:00:04:44", port=3)


        # TODO Uncomment the following two lines to read table entries from s1 and s2
        #readTableRules(p4info_helper, switch_list[0])
        # readTableRules(p4info_helper, s2)

        # Print the tunnel counters every 2 seconds
        while True:
            sleep(2)
            print('\n----- Reading tunnel counters -----')
#            printCounter(p4info_helper, s1, "MyIngress.ingressTunnelCounter", 100)
#            printCounter(p4info_helper, s2, "MyIngress.egressTunnelCounter", 100)
#            printCounter(p4info_helper, s2, "MyIngress.ingressTunnelCounter", 200)
#            printCounter(p4info_helper, s1, "MyIngress.egressTunnelCounter", 200)

    except KeyboardInterrupt:
        print(" Shutting down.")
    except grpc.RpcError as e:
        printGrpcError(e)

    ShutdownAllSwitchConnections()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='P4Runtime Controller')
    parser.add_argument('--p4info', help='p4info proto in text format from p4c',
                        type=str, action="store", required=False,
                        default='./build/forward.p4.p4info.txt')
    parser.add_argument('--bmv2-json', help='BMv2 JSON file from p4c',
                        type=str, action="store", required=False,
                        default='./build/forward.json')
    args = parser.parse_args()

    if not os.path.exists(args.p4info):
        parser.print_help()
        print("\np4info file not found: %s\nHave you run 'make'?" % args.p4info)
        parser.exit(1)
    if not os.path.exists(args.bmv2_json):
        parser.print_help()
        print("\nBMv2 JSON file not found: %s\nHave you run 'make'?" % args.bmv2_json)
        parser.exit(1)
    main(args.p4info, args.bmv2_json)
