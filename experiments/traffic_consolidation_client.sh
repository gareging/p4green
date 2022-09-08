# THRESHOLD1: 10000 Bytes/s
# THRESHOLD2: 40000 Bytes/s

# 1-5 low
iperf -c 10.0.1.5 -t 40 -b 900 -l 10 &
iperf -c 10.0.1.5 -t 40 -b 900 -l 10 &
iperf -c 10.0.2.5 -t 40 -b 900 -l 10 &
iperf -c 10.0.2.5 -t 40 -b 900 -l 10 &
iperf -c 10.0.3.5 -t 40 -b 900 -l 10 &
iperf -c 10.0.3.5 -t 40 -b 900 -l 10 &
iperf -c 10.0.4.5 -t 40 -b 900 -l 10 &
iperf -c 10.0.4.5 -t 40 -b 900 -l 10 &
sleep 35
# 5-9 growing
iperf -c 10.0.1.5 -t 45 -b 2500 -l 10 &
iperf -c 10.0.1.5 -t 45 -b 2500 -l 10 &
sleep 5
iperf -c 10.0.2.5 -t 40 -b 2500 -l 10 &
iperf -c 10.0.2.5 -t 40 -b 2500 -l 10 &
sleep 5
iperf -c 10.0.3.5 -t 35 -b 2500 -l 10 &
iperf -c 10.0.3.5 -t 35 -b 2500 -l 10 &
sleep 5
iperf -c 10.0.4.5 -t 30 -b 2500 -l 10 &
iperf -c 10.0.4.5 -t 30 -b 2500 -l 10 &
sleep 5
iperf -c 10.0.1.5 -t 25 -b 2500 -l 10 &
iperf -c 10.0.1.5 -t 25 -b 2500 -l 10 &
sleep 5
iperf -c 10.0.2.5 -t 20 -b 2500 -l 10 &
iperf -c 10.0.2.5 -t 20 -b 2500 -l 10 &
sleep 5
iperf -c 10.0.3.5 -t 15 -b 2500 -l 10 &
iperf -c 10.0.3.5 -t 15 -b 2500 -l 10 &
sleep 5
iperf -c 10.0.4.5 -t 10 -b 7500 -l 10 &
iperf -c 10.0.4.5 -t 10 -b 7500 -l 10 &
sleep 5
iperf -c 10.0.1.5 -t 5 -b 7500 -l 10 &
iperf -c 10.0.1.5 -t 5 -b 7500 -l 10 &
# 9-20 peak
iperf -c 10.0.2.5 -t 100 -b 7500 -l 10 &
iperf -c 10.0.2.5 -t 100 -b 7500 -l 10 &
sleep 10
iperf -c 10.0.3.5 -t 80 -b 7500 -l 10 &
iperf -c 10.0.3.5 -t 80 -b 7500 -l 10 &
sleep 10
iperf -c 10.0.4.5 -t 70 -b 7500 -l 10 &
iperf -c 10.0.4.5 -t 70 -b 7500 -l 10 &
sleep 10
iperf -c 10.0.1.5 -t 60 -b 7500 -l 10 &
iperf -c 10.0.1.5 -t 60 -b 7500 -l 10 &
sleep 10
iperf -c 10.0.2.5 -t 50 -b 7500 -l 10 &
iperf -c 10.0.2.5 -t 50 -b 7500 -l 10 &
sleep 10
iperf -c 10.0.3.5 -t 40 -b 7500 -l 10 &
iperf -c 10.0.3.5 -t 40 -b 7500 -l 10 &
sleep 10
iperf -c 10.0.4.5 -t 30 -b 7500 -l 10 &
iperf -c 10.0.4.5 -t 30 -b 7500 -l 10 &
sleep 10
iperf -c 10.0.1.5 -t 20 -b 7500 -l 10 &
iperf -c 10.0.1.5 -t 20 -b 7500 -l 10 &
sleep 10
iperf -c 10.0.2.5 -t 10 -b 7500 -l 10 &
iperf -c 10.0.2.5 -t 10 -b 7500 -l 10 &
sleep 10
iperf -c 10.0.3.5 -t 10 -b 7500 -l 10 &
iperf -c 10.0.3.5 -t 10 -b 7500 -l 10 &
sleep 10
iperf -c 10.0.4.5 -t 10 -b 2500 -l 10 &
iperf -c 10.0.4.5 -t 10 -b 2500 -l 10 &
sleep 10
# 20-24 lowering
# 1-5 low
iperf -c 10.0.1.5 -t 40 -b 1000 -l 10 &
iperf -c 10.0.1.5 -t 40 -b 1000 -l 10 &
iperf -c 10.0.2.5 -t 40 -b 1000 -l 10 &
iperf -c 10.0.2.5 -t 40 -b 1000 -l 10 &
iperf -c 10.0.3.5 -t 40 -b 1000 -l 10 &
iperf -c 10.0.3.5 -t 40 -b 1000 -l 10 
iperf -c 10.0.4.5 -t 40 -b 1000 -l 10 &
iperf -c 10.0.4.5 -t 40 -b 1000 -l 10 
sleep 40
echo 'DONE'

