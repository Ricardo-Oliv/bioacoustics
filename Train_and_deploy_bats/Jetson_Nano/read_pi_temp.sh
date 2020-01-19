 #!/bin/bash
# $ cd /home/tegwyn/ultrasonic_classifier/ && bash read_pi_temp.sh
 
 
# /opt/vc/bin/vcgencmd measure_temp
# cat /sys/class/thermal/thermal_zone*/temp

RED='\e[41m'
BLUE='\e[44m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BLINK='\e[5m'

f_temperature()
{
  temps=/sys/class/thermal/thermal_zone*/temp
  line=2
  result=$(head -n $line $temps | tail -1)
  pi_temp="   CPU "$result
  # pi_temp="   CPU "$(cat /sys/class/thermal/thermal_zone*/temp)
  printf "Pi temperature = ${BLUE}${pi_temp}${NC}\n"
  printf "Was that the right line?\n"
  echo -n "$pi_temp" >> /home/tegwyn/ultrasonic_classifier/helpers/battery_info.txt        # The >> indictaes append data.
  # paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'
}

# while true
  # do
  f_temperature
  # sleep 5
  # done
