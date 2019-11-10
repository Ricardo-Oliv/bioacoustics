#!/bin/bash

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# echo $(($(date +%s%N)/1000000))
cd /home/paddy/Desktop/deploy_classifier/temp/
sox new_${iter}.wav filtered.wav highpass 15k highpass 15k highpass 15k highpass 15k highpass 15k highpass 15k highpass 15k 
cp filtered.wav /home/paddy/Desktop/deploy_classifier/unknown_bat_audio/
cd /home/paddy/Desktop/deploy_classifier/
# echo $(($(date +%s%N)/1000000))
printf "${BLUE}Now run iteration ${iter} classifier: ${NC}\n"
Rscript Deploy_bats.R
printf "${BLUE}Iteration ${iter} classifier has finished! ${NC}\n"

if [ -f "$FILE" ]; then
  export bat_detected=1
  cd /home/paddy/Desktop/deploy_classifier/

  exec 6< Final_result.txt
  read line1 <&6
  read line2 <&6
  # printf "${GREEN} $line2 ${NC}\n"
  batName=$(echo "$line2" | sed 's|[.",]||g')                                # remove some characters
  # printf "${GREEN} $batName ${NC}\n"
  batName=$(printf '%s' "$batName" | sed 's/[0-9]//g')                       # remove digits
  batName=$(printf '%s' "$batName" | sed 's/ //g')                           # remove white spaces.
  batName=$(printf '%s' "$batName" | sed 's/[[:blank:]]//g')                 # remove tab spaces.
  # printf "${GREEN}Bat detected was a $batName ${NC}\n"
  exec 6<&-

  cd /home/paddy/Desktop/deploy_classifier/temp/
  newName=$(date +%F-%H:%M:%S)
  newName2="${batName}_${newName}"
  # printf "${GREEN}New name:  ${newName2} ${NC}\n"
  mv new_${iter}.wav ${newName2}.wav

  cp ${newName2}.wav /home/paddy/Desktop/deploy_classifier/detected_bat_audio/
  printf "${GREEN}Success: A ${batName} bat classification result was published for iteration no. ${iter}! ${NC}\n"

else
  printf "${GREEN}No classification result was published for iteration no. ${iter}! ${NC}\n"
  export bat_detected=0
fi

cd /home/paddy/Desktop/deploy_classifier/
