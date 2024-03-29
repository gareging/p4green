#!/usr/bin/env python3
import argparse
import os
import sys
from time import sleep
from host import Host, Link, Path, Switch, add_link
import json
import bmpy_utils as utils
import grpc
from  runtime_CLI import RuntimeAPI, load_json_config
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
HOST_SWITCHES = 4
AGGREG_SWITCHES = 3
CORE_SWITCHES = 1
ACCESS_SWITCH_TYPE = 0
AGGREG_SWITCH_TYPE = 1
CORE_SWITCH_TYPE = 2

def ecmpModeControlCLI(switches):
   print('ECMP control menu')
   sw_id = int(input('Enter switch ID:'))
   mode = int(input('Enter ECMP mode (0 or 1): '))
   modifyRegister(switches[sw_id-1], 'ecmp_mode', 0, mode)

def modifyRegister(sw, register_name, index, value):
    sw_port_shift = int(sw.name[1:])
    standard_client, mc_client = utils.thrift_connect('localhost', 9089+sw_port_shift, RuntimeAPI.get_thrift_services(1))
    load_json_config(standard_client, None)
    runtime_api = RuntimeAPI('SimplePre', standard_client, mc_client)
    runtime_api.do_register_write(f'{register_name} {index} {value}')

def readRegister(sw, register_name, index):
    sw_port_shift = int(sw.name[1:])
    standard_client, mc_client = utils.thrift_connect('localhost', 9089+sw_port_shift, RuntimeAPI.get_thrift_services(1))
    load_json_config(standard_client, None)
    runtime_api = RuntimeAPI('SimplePre', standard_client, mc_client)
    return runtime_api.do_register_read(f'{register_name} {index}')


def addMulticastingGroup(p4_info_helper, switches, links):
    for sw in switches[:4]:
        replicas = []
        for i in range(1, 3):
            replicas.append({'egress_port': i,  'instance': 1})
        multicast_entry = p4_info_helper.buildMulticastGroupEntry(1, replicas)
        sw.WritePREEntry(multicast_entry)
        print('Done writing PRE entry')

def writeForwardingRule(p4info_helper, sw, ip_address, mask, mac_address, port):
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

def writeSendToHostRule(p4info_helper, sw, host_id, mac_address, port, ip_address):
    table_entry = p4info_helper.buildTableEntry(
        table_name="MyIngress.host_info",
        match_fields={
            "meta.host_id": host_id
        },
        action_name="MyIngress.send_to_host",
        action_params={
            "dstAddr": mac_address,
            "port": port,
            "dstIPAddr": ip_address
        })
    sw.WriteTableEntry(table_entry)
    print("Installed send_to_host rule on %s" % sw.name)


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
    i = 0
    for response in sw.ReadCounters(p4info_helper.get_counters_id(counter_name), index):
        for entity in response.entities:
            counter = entity.counter_entry
            print("%i %s %s %d: %d packets (%d bytes)" % (i,
                sw.name, counter_name, index,
                counter.data.packet_count, counter.data.byte_count
            ))
            i += 1

def getCounterValues(p4info_helper, sw, counter_name, index):
    for response in sw.ReadCounters(p4info_helper.get_counters_id(counter_name), index):
        for entity in response.entities:
            counter = entity.counter_entry
            return counter.data.packet_count, counter.data.byte_count



def main(p4info_file_path, bmv2_file_path):
    # Instantiate a P4Runtime helper from the p4info file
    p4info_helper = p4runtime_lib.helper.P4InfoHelper(p4info_file_path)
    file = open('topology.json')
    json_data = json.load(file)
    hosts = []
    #print(type(json_data['hosts']))
    #print(json_data['hosts']['h1'])
    for hostid in json_data['hosts']:
       host_data = json_data['hosts'][hostid]
       ipmask = host_data['ip'].split('/')
       host = Host(name=hostid, ip=ipmask[0], mask=int(ipmask[1]), mac=host_data['mac'])
       hosts.append(host)
    #for host in hosts:
    #   print(host)
    #print(json_data)
    num_of_switches = len(json_data['switches'])
    print('Number of swistches:', num_of_switches)
    links = {}
    switches = []
    try:
        # Create a switch connection object for s1 and s2;
        # this is backed by a P4Runtime gRPC connection.
        # Also, dump all P4Runtime messages sent to switch to given txt files.
        for i in range(1, num_of_switches+1):
#            s = p4runtime_lib.bmv2.Bmv2SwitchConnection(name=f's{i}',address=f'127.0.0.1:5005{i}',device_id=i-1,proto_dump_file=f'logs/s{i}-p4runtime-requests.txt')
            s = Switch(name=f's{i}',address=f'127.0.0.1:5005{i}',device_id=i-1,proto_dump_file=f'logs/s{i}-p4runtime-requests.txt')
            switches.append(s)

        for link_data in json_data['links']:
           obj1 = link_data[0]
           obj2 = link_data[1]
           if obj1[0] == 'h':
               obj1 = hosts[int(obj1[1])-1]
               srcport = None
           else:
               srcport = int(obj1[4])
               obj1 = switches[int(obj1[1])-1]

           if obj2[0] == 'h':
               obj2 = hosts[int(obj2[1])-1]
               dstport = None
           else:
               dstport = int(obj2[4])
               obj2 = switches[int(obj2[1])-1]

           #######START ecmp ONLY SWITCH##########
           # exclude s6 as an ecmp-only switch
           if obj1.name in ('s6','s7'):
              add_link(links, obj1, obj2, srcport, dstport)
              continue

           if obj2.name in ('s6','s7'):
              add_link(links, obj2, obj1, dstport, srcport)
              continue
           #######END ecmp ONLY SWITCH##########

           add_link(links, obj1, obj2, srcport, dstport)
           add_link(links, obj2, obj1, dstport, srcport)

        #for link in links[switches[0]]:
        #    print(link)
        #print('Total num of links of s6:', len(links[switches[4]]))
        paths = {}
        nhop = {}
        for s in switches:
            paths[s] = {}
            nhop[s] = {}
            for h in hosts:
               path_info = Path(links, s, h)
               paths[s][h] = path_info.path
               nhop[s][h] = (path_info.nhop, path_info.onehop)
        #print('Done with the shortest path algorithm')
        for s in paths:
            print(s.name, 'next hops:', nhop[s])
            #for h in paths[s]:
            #  print(f'Path from {s.name} to {h.name}')
            #  print_path(paths[s][h])
        # Send master arbitration update message to establish this controller as
        # master (required by P4Runtime before performing any other write operation)
        i = 1
        for s in switches:
            s.MasterArbitrationUpdate()
            s.SetForwardingPipelineConfig(p4info=p4info_helper.p4info,
                                       bmv2_json_file_path=bmv2_file_path)
            print(f'Installed P4 Program using SetForwardingPipelineConfig on s{i}')
            i += 1
            rules_installed = set()
            adjacent_host_count = 1
            for h in nhop[s]:
                # if it is a "one hop" path (i.e. it's an access switch for the host)
                if nhop[s][h][1]:
                    print(f'Installing on {s.name}: ip {h.ip} mask 32 mac_address {h.mac} port {nhop[s][h][0]}')
                    writeForwardingRule(p4info_helper, sw=s, ip_address=h.ip, mask=32, mac_address=h.mac, port=nhop[s][h][0])
                    writeSendToHostRule(p4info_helper, sw=s, host_id=adjacent_host_count, mac_address=h.mac, port=nhop[s][h][0], ip_address=h.ip)
                    adjacent_host_count += 1
                else:
                    if (h.mask_ip(), h.mask) not in rules_installed:
                        rules_installed.add((h.mask_ip(), h.mask))
                        print(f'Installing on {s.name}: ip {h.mask_ip()} mask {h.mask} mac_address 08:00:00:00:02:22 port {nhop[s][h][0]}')
                        writeForwardingRule(p4info_helper, sw=s, ip_address=h.mask_ip(), mask=h.mask, mac_address="08:00:00:00:02:22", port=nhop[s][h][0])

        addMulticastingGroup(p4info_helper, switches, links)
        aggreg_switch_start_id = HOST_SWITCHES
        aggreg_switch_end_id = aggreg_switch_start_id + AGGREG_SWITCHES - 1
        core_switch_id = HOST_SWITCHES + AGGREG_SWITCHES

        # vip: 10.0.1.5, 11.0.1.5, etc
        for i in range(0, aggreg_switch_start_id):
            modifyRegister(switches[i], 'virtual_ip_address', 0, 167772160 + 256*(i+1)+5)

        for i in range(aggreg_switch_start_id, aggreg_switch_end_id+1):
            # Change switch type to aggr for 4,5,6
            modifyRegister(switches[i], 'switch_type', 0, AGGREG_SWITCH_TYPE)

        # change core switch type
        modifyRegister(switches[core_switch_id], 'switch_type', 0, CORE_SWITCH_TYPE)

        # Turn on ecmp mode at core and access switches
        modifyRegister(switches[core_switch_id], 'ecmp_mode', 0, 1)

        for i in range(0, aggreg_switch_start_id):
            modifyRegister(switches[i], 'ecmp_mode', 0, 1)

        # Print the tunnel counters every 2 seconds
        counter_previous = [(0, 0) for i in range(len(switches))]
        ecmp_mode = [0 for i in range(len(switches))]
        ecmp_width = [AGGREG_SWITCHES for i in range(len(switches))]
        from datetime import datetime
        timestamp = int(datetime.now().timestamp())
        for i in range(len(switches)):
            modifyRegister(switches[i], 'epoch_length', 0, 1000000)
            modifyRegister(switches[i], 'packet_size_threshold1', 0, 0)
            modifyRegister(switches[i], 'packet_size_threshold2', 0, 10000)
            modifyRegister(switches[i], 'packet_size_threshold3', 0, 40000)


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
