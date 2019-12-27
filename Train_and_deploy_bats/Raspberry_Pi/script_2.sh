#!/bin/bash

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

/opt/vc/bin/vcgencmd measure_temp

# echo $(($(date +%s%N)/1000000))
cd /home/pi/Desktop/deploy_classifier/temp/
sox new_${iter}.wav filtered.wav highpass 1k # highpass 15k highpass 15k highpass 15k highpass 15k highpass 15k highpass 15k 
cp filtered.wav /home/pi/Desktop/deploy_classifier/unknown_bat_audio/
cd /home/pi/Desktop/deploy_classifier/

python3 create_spectogram.py

# echo $(($(date +%s%N)/1000000))
printf "${BLUE}Now run iteration ${iter} classifier: ${NC}\n"

file='/home/pi/Desktop/deploy_classifier/helpers/combo_01.txt'

line=1
result=$(head -n $line /home/pi/Desktop/deploy_classifier/helpers/combo_01.txt | tail -1)
# echo $result

line=1
result=$(head -n $line /home/pi/Desktop/deploy_classifier/helpers/combo_01.txt | tail -1)
# echo $result

if [ ${result} = "UK_Bats" ]; then
  echo "UK_Bats was selected"
elif [ ${result} = "Rodents" ]; then
  echo "Rodents was selected"
elif [ ${result} = "Mechanical_Bearings" ]; then
  echo "Mechanical_Bearings was selected"
fi
choice1=$result

line=2
result=$(head -n $line /home/pi/Desktop/deploy_classifier/helpers/combo_01.txt | tail -1)
# echo $result

if [ ${result} = "Level1:_Species" ]; then
  echo "Level1:_Species was selected"
elif [ ${result} = "Level2:_Genera" ]; then
  echo "Level2:_Genera was selected"
elif [ ${result} = "Level3:_Order" ]; then
  echo "Level3:_Order was selected"
elif [ ${result} = "Bicycle_Wheel" ]; then
  echo "Bicycle_Wheel was selected"
fi
choice2=$result

line=3
result=$(head -n $line /home/pi/Desktop/deploy_classifier/helpers/combo_01.txt | tail -1)
# echo $result

if [ ${result} = "All_Calls" ]; then
  echo "All_Calls was selected"
elif [ ${result} = "Echolocation_Only" ]; then
  echo "Echolocation was selected"
elif [ ${result} = "Socials_Only" ]; then
  echo "Socials was selected"
elif [ ${result} = "NULL" ]; then
  echo "NULL was selected"
fi
choice3=$result

if [ ${choice1} = "UK_Bats" ] && [ ${choice2} = "Level1:_Species" ]; then
  Rscript Deploy_bats_pi.R
  echo "Level 1 was deployed"
elif [ ${choice1} = "UK_Bats" ] && [ ${choice2} = "Level2:_Genera" ]; then
  Rscript Deploy_bats_pi_Level2.R
  echo "Level 2 was deployed"
elif [ ${choice1} = "UK_Bats" ] && [ ${choice2} = "Level3:_Order" ]; then
  Rscript Deploy_bats_pi_Level3.R
  echo "Level 3 was deployed"
else
  echo "No valid combo box selection was made"
  sleep 5
fi

printf "${BLUE}Iteration ${iter} classifier has finished! ${NC}\n"

if [ -f "$FILE" ]; then
  bat_detected=1
  cd /home/pi/Desktop/deploy_classifier/

  exec 6< Final_result.txt
  read line1 <&6
  read line2 <&6
  # printf "${GREEN} $line2 ${NC}\n"
  batName=$(echo "$line2" | sed 's|[.",]||g')                                # remove some " characters
  # printf "${GREEN} $batName ${NC}\n"
  batName=$(printf '%s' "$batName" | sed 's/[0-9]//g')                       # remove digits
  batName=$(printf '%s' "$batName" | sed 's/ //g')                           # remove white spaces.
  batName=$(printf '%s' "$batName" | sed 's/[[:blank:]]//g')                 # remove tab spaces.

  batConfidence=$(echo "$line2" | sed 's/.*[[:blank:]]//') 
  # batConfidence2=$((10*$batConfidence))

  # batConfidence2=$(echo "scale=2; 100 * $batConfidence" | bc -l)
  batConfidence2=$(echo "scale=2; (100 * $batConfidence)+2" | bc -l)
  batConfidence3=$(echo "$batConfidence2" | sed 's/[.].*$//')

  # printf "${GREEN}Bat confidence2 value is: $batConfidence2 ${NC}\n"
  # printf "${GREEN}Bat confidence3 value is: $batConfidence3 ${NC}\n"

  # printf "${GREEN}Bat detected was a $batName ${NC}\n"
  exec 6<&-

  cd /home/pi/Desktop/deploy_classifier/temp/

  newName=$(date +%d-%m-%Y_%H:%M:%S)
  cp $FILE /home/pi/Desktop/deploy_classifier/Final_result_copy.txt

  newName2="${batConfidence3}%_${batName}_${newName}"
  # printf "${GREEN}New name:  ${newName2} ${NC}\n"
  mv new_${iter}.wav ${newName2}.wav

  cp ${newName2}.wav /home/pi/Desktop/deploy_classifier/detected_bat_audio/
  printf "${GREEN}Success: A ${batName} bat classification result was published for iteration no. ${iter}! ${NC}\n"

else
  printf "${GREEN}No classification result was published for iteration no. ${iter}! ${NC}\n"
  bat_detected=0
  batConfidence3=0
fi

# printf "${GREEN}Bat confidence 3 value is: $batConfidence3 ${NC}\n"

# arecord -f S16 -r 384000 -d ${chunk_time} -c 1 --device=plughw:r0,0 /home/pi/Desktop/deploy_classifier/temp/new_${iter}.wav
# card 0: ALSA [bcm2835 ALSA], device 1: bcm2835 IEC958/HDMI [bcm2835 IEC958/HDMI]
# aplay /home/pi/Desktop/deploy_classifier/alert_sounds/keys.wav
# aplay --device=hw:0,0 keys.wav

# cd /home/pi/Desktop/deploy_classifier/alert_sounds/
# aplay --device=hw:0,0 /home/pi/Desktop/deploy_classifier/alert_sounds/keys.wav       # Currently sets to HDMI for testing.
# Simple mixer control 'PCM',0
#  Capabilities: pvolume pvolume-joined pswitch pswitch-joined
#  Playback channels: Mono
#  Limits: Playback -10239 - 400
#  Mono: Playback -1999 [77%] [-19.99dB] [on]

# amixer sset PCM 100%

conf=50

if [ $batConfidence3 -gt $conf ]; then
  if [ ${batName} = "HOUSE_KEYS" ]; then
    aplay --device=hw:0,0 /home/pi/Desktop/deploy_classifier/alert_sounds/keys.wav
  elif [ ${batName} = "NOCTULA" ]; then
    aplay --device=hw:0,0 /home/pi/Desktop/deploy_classifier/alert_sounds/noctule.wav
  elif [ ${batName} = "NATTERERI" ]; then
    aplay --device=hw:0,0 /home/pi/Desktop/deploy_classifier/alert_sounds/nattereri.wav
  elif [ ${batName} = "PLECOTUS" ]; then
    aplay --device=hw:0,0 /home/pi/Desktop/deploy_classifier/alert_sounds/plecotus.wav
  elif [ ${batName} = "NATTERERI" ]; then
    aplay --device=hw:0,0 /home/pi/Desktop/deploy_classifier/alert_sounds/nattereri.wav
  elif [ ${batName} = "C_PIP" ]; then
    aplay --device=hw:0,0 /home/pi/Desktop/deploy_classifier/alert_sounds/c_pip.wav
  elif [ ${batName} = "S_PIP" ]; then
    aplay --device=hw:0,0 /home/pi/Desktop/deploy_classifier/alert_sounds/s_pip.wav
  fi
fi

# printf "${GREEN}Is there still a  ./script_2.sh: 79: [: -gt: unexpected operator error? ${NC}\n"
directory_to_search_inside="/home/pi/Desktop/deploy_classifier/detected_bat_audio"
file_count=$( set -- $directory_to_search_inside/* ; echo $#)
# printf "$file_count \n"
# printf "${GREEN}File count in detected_bat_audio directory: $file_count  ${NC}\n"

if [ $bat_detected -gt 0 ]; then
  # printf "${GREEN}Bat_detected value: ${bat_detected} ${NC}\n"
  cd /home/pi/Desktop/deploy_classifier/temp/
  ls -t | tail -n +4 | xargs rm                   # Delete all files except for the three newest.
  # printf "${GREEN}Was there an rm missing operand error? deleting from temp ${NC}\n"
  if  [ $file_count -gt 100 ]; then
    cd /home/pi/Desktop/deploy_classifier/detected_bat_audio/
    ls|sort -V -r | tail -n +100 | xargs rm         # Delete all files except for the best 500.
    # printf "${GREEN}Was there an rm missing operand error? deleting from detected_bats${NC}\n"
    # TODO above error is probably caused by rm not finding the prescribed files ie there are less than 500 files in the detected_bat_audio directory.
  fi
fi

cd /home/pi/Desktop/deploy_classifier/


