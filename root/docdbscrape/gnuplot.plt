set terminal png medium enhanced font '/usr/share/fonts/liberation/LiberationSans-Regular.ttf,10' size 800,600
set size square
set key left top
#set tics scale 2
set key spacing 1.5
set key box
set border
set grid
set title "DCC Activity"
set xlabel "Date" offset 0,1
set xtics rotate by -45
set mxtics 2
set mytics 2
set ylabel offset "N"
set format x "0%3.0f"
set xdata time
set timefmt "%Y%m%d"
set format x "%m/%d/%Y"
set output "/usr1/www/html/mediawiki-1.20.2/images/5/54/Docdbstats.png"
plot '/root/docdbscrape/DocDB-Total-Number-Of-Documents' using 1:2 t 'Total Number of DCC Documents' with linespoints,'/root/docdbscrape/DocDB-Total-Number-Of-Documents' using 1:6 t 'Actual Number of Files in DCC' with linespoints,'/root/docdbscrape/DocDB-Total-Number-Of-Documents' using 1:12 t 'Number of Active Authors' with linespoints
