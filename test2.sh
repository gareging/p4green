iperf -c 10.0.4.5 -t 45 -b 7000 -l 10 &
sleep 5
iperf -c 10.0.4.5 -t 40 -b 7000 -l 10 &
sleep 5
iperf -c 10.0.1.5 -t 35 -b 7000 -l 10 &
sleep 5
iperf -c 10.0.1.5 -t 30 -b 7000 -l 10 &
sleep 5
iperf -c 10.0.2.5 -t 25 -b 7000 -l 10 &
sleep 5
iperf -c 10.0.2.5 -t 20 -b 7000 -l 10 &
sleep 5
iperf -c 10.0.3.5 -t 15 -b 7000 -l 10 &
sleep 5
iperf -c 10.0.3.5 -t 10 -b 7000 -l 10 &
sleep 5
iperf -c 10.0.4.5 -t 5 -b 7000 -l 10 &
