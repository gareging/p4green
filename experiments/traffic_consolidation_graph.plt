#!/usr/local/bin/gnuplot -persist
set size 3,1
set lmargin 12
set bmargin 4
set ylabel 'Load, KBytes' font 'Helvetica, 34' offset -1.5
set xlabel 'Time, hh' font 'Helvetica, 34'
set rmargin 5
set out 'Stat.png'
#set terminal postscript eps 22
set term png
#unset key
set xtics font 'Helvetica,28'
set ytics font 'Helvetica,28'
#set format y "%g%%"
set key above font 'Helvetica,34' maxrows 1
set grid
#set yrange [0:110]
set xrange [0:24]
plot 'traffic_consolidation_log_filtered.txt' every 10 using ($1/20+2.4):($5/1000) with linespoints pi 5 ps 2 title "Total"\
,'traffic_consolidation_log_filtered.txt' every 10 using ($1/20+2.4):($2/1000) with linespoints pi 5 pt 2  ps 2 title "Aggregation Switch 1"\
,'traffic_consolidation_log_filtered.txt' every 10 using ($1/20+2.4):($3/1000) with linespoints pi 5 pt 65 ps 2 title "Aggregation Switch 2"\
,'traffic_consolidation_log_filtered.txt' every 10 using ($1/20+2.4):($4/1000) with linespoints pi 5 pt 4 ps 2 title "Aggregation Switch 3"
set terminal postscript enhanced color eps 17 font 'Helvetica' lw 5
set out 'traffic_consolidation_graph.eps'
rep
