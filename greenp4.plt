#!/usr/local/bin/gnuplot -persist
#set logscale y
set lmargin 12
set bmargin 4
set ylabel 'Traffic' font 'Helvetica, 34'
set xlabel 'Time' font 'Helvetica, 34'
set out 'Stat.png'
set rmargin 5
#set terminal postscript eps 22
set term png
#unset key
set xtics font 'Helvetica,28'
set ytics font 'Helvetica, 28'

set key above font 'Helvetica, 24'
set grid
#set yrange [0:3500]
set xrange [0:24]
plot 'log.txt' every 1 using ($1/20):5 with linespoints pi 8000 ps 1.5 title "Total"\
,'log.txt' every 1 using ($1/20):2 with linespoints pt 2  pi 8000 ps 1.5 title "Switch 1"\
,'log.txt' every 1 using ($1/20):3 with linespoints pt 65 pi 8000 ps 1.5 title "Switch 2"\
,'log.txt' every 1 using ($1/20):4 with linespoints pt 65 pi 8000 ps 1.5 title "Switch 3"
#,'4.69.184.193_FIFA_0.txt' every 1000 using ($1/10000):4 with linespoints title "Normal"  
set terminal postscript enhanced color eps 17 font 'Helvetica' lw 5
set out 'Traffic0.eps'
rep
