#!/bin/bash
for i in 1 2 3 4 5 6 7 8  
do 

iperf -c 10.0.1.5 -t 11 &
iperf -c 10.0.2.5 -t 11 & 
iperf -c 10.0.3.5 -t 11 &
iperf -c 10.0.4.5 -t 11 &
sleep 10

iperf -c 10.0.1.5 -t 11 &
iperf -c 10.0.2.5 -t 11 & 
iperf -c 10.0.3.5 -t 11 &
iperf -c 10.0.4.5 -t 11 &
sleep 10

iperf -c 10.0.1.5 -t 11 &
iperf -c 10.0.2.5 -t 11 & 
iperf -c 10.0.3.5 -t 11 &
iperf -c 10.0.4.5 -t 11 &
sleep 10

iperf -c 10.0.1.5 -t 11 &
iperf -c 10.0.2.5 -t 11 & 
iperf -c 10.0.3.5 -t 11 &
iperf -c 10.0.4.5 -t 11 &
sleep 10

done



echo 'DONE'

