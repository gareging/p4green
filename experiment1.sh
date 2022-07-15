ping 10.0.1.1 -c 50
ping 10.0.1.1 -i 0.1 -c 100 &
ping 10.0.1.2 -i 0.1 -c 100 
ping 10.0.1.1 -i 0 -c 100 &
ping 10.0.1.2 -i 0 -c 100 &
iperf -c 10.0.1.5 -t 30 &
iperf -c 10.0.1.5 -t 30 
ping 10.0.1.1 -c 50
