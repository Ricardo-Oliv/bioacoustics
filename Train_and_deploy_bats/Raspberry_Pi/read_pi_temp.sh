 #!/bin/bash
# $ cd /home/pi/Desktop/deploy_classifier/ && bash read_pi_temp.sh
 
 
# /opt/vc/bin/vcgencmd measure_temp


RED='\e[41m'
BLUE='\e[44m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BLINK='\e[5m'

f_temperature()
{
  pi_temp="   CPU "$(/opt/vc/bin/vcgencmd measure_temp)
  printf "Pi temperature = ${BLUE}${pi_temp}${NC}\n"
  echo -n "$pi_temp" >> /home/pi/Desktop/deploy_classifier/helpers/battery_info.txt        # The >> indictaes append data.
}

# while true
  # do
  f_temperature
  # sleep 5
  # done
