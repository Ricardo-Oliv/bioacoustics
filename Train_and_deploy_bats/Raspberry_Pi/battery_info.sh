#!/bin/bash
# cd /home/pi/Desktop/deploy_classifier/ && bash battery_info.sh
# cd /home/pi/Desktop/deploy_classifier/ && chmod 775 battery_info.sh

RED='\e[41m'
BLUE='\e[44m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BLINK='\e[5m'

f_read_line()
{
  battery=$(pivoyager status)
  printf "${BLUE}${battery}${NC}\n"

  var=`echo "${battery}" | head -3 | tail -1`
    
  printf "${RED}${var}${NC}\n"

  echo -n "$var" > /home/pi/Desktop/deploy_classifier/helpers/battery_info.txt   # Overwrite file with new variable.
  
  # echo ""
}

# while true
  # do
  # pivoyager status
  f_read_line
  # sleep 5
  # done
  
