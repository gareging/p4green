# THRESHOLD1: 1000 Bytes/s
# THRESHOLD2: 10000 Bytes/s

echo '1-5 low'
./send.py 10.0.${1}.0
sleep 50
echo '5-9 growing'
./send.py 10.0.${1}.10
sleep 10
./send.py 10.0.${1}.20
sleep 10
./send.py 10.0.${1}.50
sleep 10
./send.py 10.0.${1}.75
sleep 10
echo '9-15 peak'
./send.py 10.0.${1}.125
sleep 10
./send.py 10.0.${1}.235
sleep 10
./send.py 10.0.${1}.245
sleep 10
./send.py 10.0.${1}.255
sleep 10
./send.py 10.0.${1}.245
sleep 10
./send.py 10.0.${1}.235
sleep 10
./send.py 10.0.${1}.125
sleep 10
echo '16-20 decline'
./send.py 10.0.${1}.75
sleep 10
./send.py 10.0.${1}.50
sleep 10
./send.py 10.0.${1}.20
sleep 10
./send.py 10.0.${1}.10
sleep 10
echo '21-24 zero'
./send.py 10.0.${1}.0
sleep 10
./send.py 10.0.${1}.0
sleep 10
./send.py 10.0.${1}.0
sleep 10
./send.py 10.0.${1}.0
sleep 10
echo 'DONE'
