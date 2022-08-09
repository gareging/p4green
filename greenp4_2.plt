#!/usr/local/bin/gnuplot -persist
set size 3,1
set lmargin 12
set bmargin 4
set ylabel 'Load' font 'Helvetica, 34' offset -1.5
set xlabel 'Time' font 'Helvetica, 34'
set rmargin 5
set out 'Stat.png'
#set terminal postscript eps 22
set term png
#unset key
set xtics font 'Helvetica,28'
set ytics font 'Helvetica, 28'
set format y "%g%%"
set key above font 'Helvetica, 24'
set grid
set yrange [0:110]
set xrange [0:24]
plot 'log2.txt' every 10 using ($1/20+2.4):($5/555) with linespoints pi 5 ps 2 title "Total"\
,'log2.txt' every 10 using ($1/20+2.4):($2/555) with linespoints pi 5 pt 2  ps 2 title "Aggregation Switch 1"\
,'log2.txt' every 10 using ($1/20+2.4):($3/555) with linespoints pi 5 pt 65 ps 2 title "Aggregation Switch 2"\
,'log2.txt' every 10 using ($1/20+2.4):($4/555) with linespoints pi 5 pt 4 ps 2 title "Aggregation Switch 3"
#,'4.69.184.193_FIFA_0.txt' every 1000 using ($1/10000):4 with linespoints title "Normal"  
set terminal postscript enhanced color eps 17 font 'Helvetica' lw 5
set out 'Traffic.eps'
rep
