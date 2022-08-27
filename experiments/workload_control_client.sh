#!/bin/bash
for i in {1..256}  
do 

iperf -c 10.0.1.5 -t 10 &
sleep 0.5
iperf -c 10.0.1.5 -t 10 &
sleep 0.5
iperf -c 10.0.1.5 -t 10 &
sleep 0.5
iperf -c 10.0.1.5 -t 10 &

sleep 0.5

done



echo 'DONE'

