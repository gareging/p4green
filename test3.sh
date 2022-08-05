iperf -c 10.0.4.5 -t 100 -b 7000 -l 10 &
sleep 10
iperf -c 10.0.4.5 -t 90 -b 7000 -l 10 &
sleep 10
iperf -c 10.0.1.5 -t 80 -b 7000 -l 10 &
sleep 10
iperf -c 10.0.1.5 -t 70 -b 7000 -l 10 &
sleep 10
iperf -c 10.0.2.5 -t 60 -b 7000 -l 10 &
sleep 10
iperf -c 10.0.2.5 -t 50 -b 7000 -l 10 &
sleep 10
iperf -c 10.0.3.5 -t 40 -b 7000 -l 10 &
sleep 10
iperf -c 10.0.3.5 -t 30 -b 7000 -l 10 &
sleep 10
iperf -c 10.0.4.5 -t 20 -b 7000 -l 10 &
sleep 10
iperf -c 10.0.4.5 -t 10 -b 7000 -l 10 &
sleep 10
iperf -c 10.0.4.5 -t 10 -b 3000 -l 10 &
sleep 10
