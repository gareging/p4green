#!/bin/bash
for i in {1..32}  
do 

iperf -c 10.0.1.5 -t 10 &
sleep 0.5
iperf -c 10.0.1.5 -t 10 &
iperf -c 10.0.2.5 -t 10 &
sleep 0.5 
iperf -c 10.0.2.5 -t 10 &
iperf -c 10.0.3.5 -t 10 &
sleep 0.5
iperf -c 10.0.3.5 -t 10 &
iperf -c 10.0.4.5 -t 10 &
sleep 0.5
iperf -c 10.0.4.5 -t 10 &
sleep 8

done



echo 'DONE'

