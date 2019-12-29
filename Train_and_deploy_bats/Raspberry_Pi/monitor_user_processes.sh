#!/bin/bash
# cd /home/pi/Desktop/deploy_classifier/ && bash monitor_user_processes.sh
# cd /home/pi/Desktop/deploy_classifier/ && chmod 775 monitor_user_processes.sh

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

gnome-terminal --geometry 73x31+100+300

while true
do
  printf "${GREEN}Print out of processes running: ${NC}\n"
  # echo "Print out processes running:"
  # ps -u pi
  ps -u pi -o %cpu,%mem,cmd
  echo ""
  echo ""
  sleep 1
done
