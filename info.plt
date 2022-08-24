#!/usr/local/bin/gnuplot -persist
set boxwidth 0.7
set lmargin 12
set bmargin 4
#set style histogram cluster gap 1
set ylabel 'Reported index' font 'Helvetica, 26'
set xlabel 'Time, hh' font 'Helvetica, 26'
set rmargin 5
set out 'Stat.png'
#set terminal postscript eps 22
set term png
#unset key
set xtics font 'Helvetica,20'
set ytics font 'Helvetica,20'
#set format y "%g%%"
set key above font 'Helvetica, 26'
set grid
set yrange [-10:230]
set xrange [0:24]
#set style fill transparent solid 0.2
set style data boxes
plot 'info.txt' every 1 using ($1):($2) with boxes fill pattern 1  title "Server 1"\
,'info.txt' every 1 using ($3-0.8):($2) with boxes fill pattern 4 title "Server 2"
#plot 'info.txt' every 1 using ($1):($2) linetype rgb  'red' title "Server 1"\
#,'info.txt' every 1 using ($1+5):($2)  linetype rgb 'blue' title "Server 2"
#,'log4.txt' every 1 using ($1/13):($4/1000) with linespoints pi 5 pt 7 ps 2 title "Host 3"\
#,'log4.txt' every 1 using ($1/13):($5/1000) with linespoints pi 5 pt 65 ps 2 title "Host 4"
#,'log3.txt' every 5 using ($1/7):($6) with linespoints pi 5 pt 65 ps 2 title "Host 5"\
#,'log3.txt' every 5 using ($1/7):($7) with linespoints pi 5 pt 65 ps 2 title "Host 6"\
#,'log3.txt' every 5 using ($1/7):($8) with linespoints pi 5 pt 65 ps 2 title "Host 7"\
#,'log3.txt' every 5 using ($1/7):($9) with linespoints pi 5 pt 65 ps 2 title "Host 8"\
#,'4.69.184.193_FIFA_0.txt' every 1000 using ($1/10000):4 with linespoints title "Normal"  
set terminal postscript enhanced color eps 17 font 'Helvetica' lw 5
set out 'info.eps'
rep
