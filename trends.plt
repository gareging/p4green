#!/usr/local/bin/gnuplot -persist
set size 1,1
set lmargin 12
set bmargin 4
set ylabel 'Energy consumption trends' font 'Helvetica, 34' offset -2.5
set xlabel 'Year' font 'Helvetica, 34'
set rmargin 5
set out 'Stat.png'
#set terminal postscript eps 22
set term png
#unset key
set xtics font 'Helvetica,28' (2022, 2024, 2026, 2028, 2030)
set ytics font 'Helvetica, 28'
set format y "%g%%"
set key top left font 'Helvetica, 24'
set grid
set yrange [-30:90]
#set xrange [0:24]
plot 'energy_trends.txt' every 1 using 1:2 with linespoints pt 1  ps 2 title "Non-IT Infrastructure"\
,'energy_trends.txt' every 1 using 1:3 with linespoints pt 2 ps 2 title "Network"\
,'energy_trends.txt' every 1 using 1:4 with linespoints pt 3 ps 2 title "Storage"\
,'energy_trends.txt' every 1 using 1:5 with linespoints pt 4 ps 2 title "Servers"
#,'log4.txt' every 1 using ($1/13):($4/1000) with linespoints pi 5 pt 7 ps 2 title "Host 3"\
#,'log4.txt' every 1 using ($1/13):($5/1000) with linespoints pi 5 pt 65 ps 2 title "Host 4"
#,'log3.txt' every 5 using ($1/7):($6) with linespoints pi 5 pt 65 ps 2 title "Host 5"\
#,'log3.txt' every 5 using ($1/7):($7) with linespoints pi 5 pt 65 ps 2 title "Host 6"\
#,'log3.txt' every 5 using ($1/7):($8) with linespoints pi 5 pt 65 ps 2 title "Host 7"\
#,'log3.txt' every 5 using ($1/7):($9) with linespoints pi 5 pt 65 ps 2 title "Host 8"\
#,'4.69.184.193_FIFA_0.txt' every 1000 using ($1/10000):4 with linespoints title "Normal"  
set terminal postscript enhanced color eps 17 font 'Helvetica' lw 5
set out 'energy_trends.eps'
rep
