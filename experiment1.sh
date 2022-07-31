# 1-5
ping 10.0.1.1 -c 50 -w 50
# 5-9
ping 10.0.1.1 -i 0.1 -c 200 -w 40 &
ping 10.0.1.2 -i 0.1 -c 200 -w 40 &
ping 10.0.2.1 -i 0.1 -c 200 -w 40 &
sleep 10
ping 10.0.2.2 -i 0.1 -c 200 -w 30 &
ping 10.0.3.1 -i 0.1 -c 200 -w 30 &
ping 10.0.3.2 -i 0.1 -c 200 -w 30 &
sleep 30
# 9-20
ping 10.0.2.1 -i 0.1 -c 600 -w 80 &
ping 10.0.2.2 -i 0.1 -c 600 -w 80 &
ping 10.0.3.1 -i 0.1 -c 600 -w 80 &
ping 10.0.3.2 -i 0.1 -c 600 -w 80 &
sleep 30
ping 10.0.1.1 -i 0 -c 600 -w 55 &
ping 10.0.1.2 -i 0 -c 600 -w 55 &
sleep 30
iperf -c 10.0.1.5 -t 30 &
iperf -c 10.0.1.5 -t 30 &
iperf -c 10.0.2.5 -t 30 &
iperf -c 10.0.4.5 -t 30 &
sleep 30 
ping 10.0.1.1 -i 0.1 -c 200 &
ping 10.0.1.2 -i 0.1 -c 200 &
ping 10.0.2.1 -i 0.1 -c 200 
sleep 20
ping 10.0.2.2 -i 0.1 -c 200 &
ping 10.0.3.1 -i 0.1 -c 200 &
ping 10.0.3.2 -i 0.1 -c 220 &
sleep 200
# 20-24
ping 10.0.1.1 -c 40
