# THRESHOLD1: 1000 Bytes/s
# THRESHOLD2: 10000 Bytes/s

echo '1-5 low'
iperf -c 10.0.1.5 -t 40 -b 100 -l 10 &
iperf -c 10.0.1.5 -t 40 -b 100 -l 10 &
iperf -c 10.0.2.5 -t 40 -b 100 -l 10 &
iperf -c 10.0.2.5 -t 40 -b 100 -l 10 &
iperf -c 10.0.3.5 -t 40 -b 100 -l 10 &
iperf -c 10.0.3.5 -t 40 -b 100 -l 10 &
sleep 35
echo '5-9 growing'
iperf -c 10.0.4.5 -t 45 -b 700 -l 10 &
sleep 5
iperf -c 10.0.4.5 -t 40 -b 700 -l 10 &
sleep 5
iperf -c 10.0.1.5 -t 35 -b 700 -l 10 &
sleep 5
iperf -c 10.0.1.5 -t 30 -b 700 -l 10 &
sleep 5
iperf -c 10.0.2.5 -t 25 -b 700 -l 10 &
sleep 5
iperf -c 10.0.2.5 -t 20 -b 700 -l 10 &
sleep 5
iperf -c 10.0.3.5 -t 15 -b 700 -l 10 &
sleep 5
iperf -c 10.0.3.5 -t 10 -b 700 -l 10 &
sleep 5
iperf -c 10.0.4.5 -t 5 -b 700 -l 10 &
echo '9-20 peak'
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
iperf -c 10.0.3.5 -t 35 -b 5000 -l 10 &
sleep 10
iperf -c 10.0.4.5 -t 30 -b 5000 -l 10 &
sleep 10
iperf -c 10.0.4.5 -t 30 -b 5000 -l 10 &
iperf -c 10.0.1.5 -t 30 -b 5000 -l 10 &
iperf -c 10.0.2.5 -t 25 -b 5000 -l 10 &
sleep 10
iperf -c 10.0.4.5 -t 20 -b 5000 -l 10 &
sleep 10
echo '20-24 lowering'
# 1-5 low
iperf -c 10.0.1.5 -t 40 -b 100 -l 10 &
iperf -c 10.0.1.5 -t 40 -b 100 -l 10 &
iperf -c 10.0.2.5 -t 40 -b 100 -l 10 &
iperf -c 10.0.2.5 -t 40 -b 100 -l 10 &
iperf -c 10.0.3.5 -t 40 -b 100 -l 10 &
iperf -c 10.0.3.5 -t 40 -b 100 -l 10 
echo 'DONE'

