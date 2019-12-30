#!/bin/bash
# cd /home/pi/Desktop/deploy_classifier/ && bash cpu_and_ram_log.sh

# kill $(pgrep -f 'script_1.sh')
# kill $(pgrep -f 'GUI.py')
# kill $(pgrep -f 'create_spectogram.py')

# psrecord $(bash) --interval 1 --duration 60 --plot /home/pi/Desktop/deploy_classifier/images/plot1.png &
# P1=$!
# psrecord $(python3) --interval 1 --duration 60 --plot /home/pi/Desktop/deploy_classifier/images/plot2.png &
# P2=$!
# wait $P1 $P2
# echo 'Done'


# psrecord $(pgrep python3) --interval 1 --duration 60 --plot /home/pi/Desktop/deploy_classifier/images/plot1.png
# psrecord $(pgrep r) --interval 1 --duration 60 --plot /home/pi/Desktop/deploy_classifier/images/plot1.png

# top -b -d $delay -p $pid | awk -v OFS="," '$1+0>0 {
# print strftime("%Y-%m-%d %H:%M:%S"),$1,$NF,$9,$10; fflush() }'

# while true
# do 
  # (echo "%CPU %MEM ARGS $(date)" && ps -e -o pcpu,pmem,args --sort=pcpu | cut -d" " -f1-5 | tail) >> /home/pi/Desktop/deploy_classifier/ps.log
  # sleep 1
    
# done

# psrecord $(pgrep -f 'run.sh') --interval 1 --duration 60 --log /home/pi/Desktop/deploy_classifier/activity.txt --include-children --plot /home/pi/Desktop/deploy_classifier/images/plot3.png
# psrecord 31679 --interval 1 --duration 60 --log /home/pi/Desktop/deploy_classifier/activity.txt --include-children --plot /home/pi/Desktop/deploy_classifier/images/plot3.png
# psrecord "/home/pi/Desktop/deploy_classifier/run.sh" --interval 1 --duration 60 --log /home/pi/Desktop/deploy_classifier/activity.txt --include-children --plot /home/pi/Desktop/deploy_classifier/images/plot4.png
psrecord "Rscript Deploy_bats_pi.R" --interval 0.1 --duration 60 --plot /home/pi/Desktop/deploy_classifier/images/plot5.png

