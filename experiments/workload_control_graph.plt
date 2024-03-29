#!/usr/local/bin/gnuplot -persist
set size 3,1
set lmargin 12
set bmargin 4
set ylabel 'Load, KBytes' font 'Helvetica, 34' offset -2
set xlabel 'Time, hh' font 'Helvetica, 34'
set rmargin 5
set out 'Stat.png'
#set terminal postscript eps 22
set term png
#unset key
set xtics font 'Helvetica,28'
set ytics font 'Helvetica,28'
#set format y "%g%%"
set key above font 'Helvetica, 34'
set grid
#set yrange [0:110]
set xrange [0:24]
plot 'workload_control_log_filtered.txt' every 1 using ($1/25):($2/1000) with linespoints pi 5 pt 6  ps 2 title "Server 1"\
,'workload_control_log_filtered.txt' every 1 using ($1/25):($3/1000) with linespoints pi 5 pt 4 ps 2 title "Server 2"
#,'log4.txt' every 1 using ($1/13):($4/1000) with linespoints pi 5 pt 7 ps 2 title "Host 3"\
#,'log4.txt' every 1 using ($1/13):($5/1000) with linespoints pi 5 pt 65 ps 2 title "Host 4"
#,'log3.txt' every 5 using ($1/7):($6) with linespoints pi 5 pt 65 ps 2 title "Host 5"\
#,'log3.txt' every 5 using ($1/7):($7) with linespoints pi 5 pt 65 ps 2 title "Host 6"\
#,'log3.txt' every 5 using ($1/7):($8) with linespoints pi 5 pt 65 ps 2 title "Host 7"\
#,'log3.txt' every 5 using ($1/7):($9) with linespoints pi 5 pt 65 ps 2 title "Host 8"\
#,'4.69.184.193_FIFA_0.txt' every 1000 using ($1/10000):4 with linespoints title "Normal"  
set terminal postscript enhanced color eps 17 font 'Helvetica' lw 5
set out 'workload_control.eps'
rep
