# THRESHOLD1: 1000 Bytes/s
# THRESHOLD2: 10000 Bytes/s

echo '1-5 low'
./send.py 10.0.${1}.0
sleep 50
echo '5-9 growing'
./send.py 10.0.${1}.40
sleep 20
./send.py 10.0.${1}.80
sleep 20
echo '9-15 peak'
./send.py 10.0.${1}.120
sleep 20
./send.py 10.0.${1}.160
sleep 20
./send.py 10.0.${1}.200
sleep 30
echo '16-20 decline'
./send.py 10.0.${1}.80
sleep 20
./send.py 10.0.${1}.20
sleep 20
echo '21-24 zero'
./send.py 10.0.${1}.0
sleep 20
./send.py 10.0.${1}.0
sleep 20
echo 'DONE'

while true
do
   ./send.py 10.0.${1}.0
   echo 'Press [CTRL+C] to stop'
   sleep 3
done

