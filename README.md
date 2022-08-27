# Implementing a Control Plane using P4Runtime

## Introduction

This code generates a data center topology with a core switch, three aggregation switches, 4 access switches and 9 hosts. 
Each access switch is connected to 2 hosts. A core switch is connected to one host (i.e. outside network).
RuntimeAPI calculates shortest paths to each host for each switch and initializes all the registered.

The P4 program includes an "arp_fool"-type action that returns a fake MAC address per each arp reply.

Switches work as routers - they have the routing tables set up, and their routing tables have the MAC addresses of the destination hosts.
