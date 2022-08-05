# THRESHOLD1: 1000 Bytes/s
# THRESHOLD2: 10000 Bytes/s

echo '1-5 low'
iperf -c 10.0.1.5 -t 40 &
iperf -c 10.0.2.5 -t 40 & 
iperf -c 10.0.3.5 -t 40 &
iperf -c 10.0.4.5 -t 40 &
sleep 160
echo '5-9 growing'
iperf -c 10.0.1.5 -t 45  &
sleep 5
iperf -c 10.0.1.5 -t 40  &
sleep 5
iperf -c 10.0.2.5 -t 35  &
sleep 5
iperf -c 10.0.2.5 -t 30  &
sleep 5
iperf -c 10.0.3.5 -t 25  &
sleep 5
iperf -c 10.0.3.5 -t 20  &
sleep 5
iperf -c 10.0.4.5 -t 15  &
sleep 5
iperf -c 10.0.4.5 -t 10  &
echo '9-20 peak'
iperf -c 10.0.1.5 -t 100  &
sleep 10
iperf -c 10.0.1.5 -t 90  &
sleep 10
iperf -c 10.0.2.5 -t 80  &
sleep 10
iperf -c 10.0.2.5 -t 70  &
sleep 10
iperf -c 10.0.3.5 -t 60  &
sleep 10
iperf -c 10.0.3.5 -t 50  &
sleep 10
iperf -c 10.0.4.5 -t 40  &
sleep 10
iperf -c 10.0.4.5 -t 35  &
sleep 10
iperf -c 10.0.5.5 -t 30  &
sleep 10
iperf -c 10.0.5.5 -t 30  &
echo '20-24 lowering'
# 1-5 low
iperf -c 10.0.1.5 -t 40  &
iperf -c 10.0.1.5 -t 40  &
iperf -c 10.0.2.5 -t 40  &
iperf -c 10.0.2.5 -t 40  &
iperf -c 10.0.3.5 -t 40  &
iperf -c 10.0.3.5 -t 40  &
iperf -c 10.0.4.5 -t 40  &
iperf -c 10.0.4.5 -t 40  
echo 'DONE'

