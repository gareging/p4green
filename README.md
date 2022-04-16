# Implementing a Control Plane using P4Runtime

## Introduction

This code generates a data center topology with a core switch, two aggregation switches and 4 access switches and 9 hosts. 
Each access switch is connected to 2 hosts. A core switch is connected to one hosts (i.e. outside network).
RuntimeAPI calculates shortest paths to each host for each switch.
The P4 program includes and "arp_fool" action that returns a fake MAC address per each arp reply.
Switches work as routers - they have the routing tables set up, and their routing tables have the MAC addresses of the destination hosts.

To enable ecnp routing at the core switch, change the register switch_type[0] to 2.
