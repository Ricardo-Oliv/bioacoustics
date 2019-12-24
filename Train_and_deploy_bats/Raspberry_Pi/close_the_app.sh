#!/bin/bash
# cd /home/pi/Desktop/deploy_classifier/ && bash restart_the_app.sh


killall -r run.sh
sleep 2
sh ./run.sh
