#!/usr/local/bin/gnuplot -persist
#set logscale y
set style data histograms
set style histogram rowstacked
set boxwidth 1 relative
set style fill solid 1.0 border -1
set lmargin 12
set bmargin 4
set ylabel 'Load' font 'Helvetica, 34' offset -1.5
set xlabel 'Time' font 'Helvetica, 34'
set out 'Stat.png'
set rmargin 5
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
plot 'log2.txt' every 10 using ($1/20+3):($5/555) title "Total"\
#,'log2.txt' every 20 using ($1/20+3):($2/555) title "Switch 1"\
#,'log2.txt' every 20 using ($1/20+3):($3/555) title "Switch 2"\
#,'log2.txt' every 20 using ($1/20+3):($4/555) title "Switch 3"
#,'4.69.184.193_FIFA_0.txt' every 1000 using ($1/10000):4 with linespoints title "Normal"  
set terminal postscript enhanced color eps 17 font 'Helvetica' lw 5
set out 'Stack.eps'
rep
