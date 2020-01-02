#!/bin/bash
# $ cd /home/pi/Desktop/deploy_classifier/ && bash script_1.sh
# Record 10 second chunks of audio on UltraMic384K, apply a 15K highpass filter, run the randomforest classifier. Repeat.
# lscpu
# arecord -l

RED='\e[41m'
BLUE='\e[44m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BLINK='\e[5m'

amixer sset PCM 100%
aplay --device=hw:0,0 /home/pi/Desktop/deploy_classifier/alert_sounds/Go_for_Deploy.wav

sudo chmod 775 /home/pi/Desktop/deploy_classifier/helpers/toggled_01.txt

cd /home/pi/Desktop/deploy_classifier/

sh ./battery_info.sh &                                                        # Get battery information.
rm Final_result.txt
rm Final_result_copy.txt
cd /home/pi/Desktop/deploy_classifier/helpers/
#touch counter.txt
#echo 0 > /home/pi/Desktop/deploy_classifier/helpers/counter.txt

#rm stop.txt
rm start.txt
touch stop.txt
rm shutDown.txt
# touch running.txt                               # Create 'running.txt' to let other programs know that the script is running.
# rm /home/pi/Desktop/deploy_classifier/temp/*
rm /home/pi/Desktop/deploy_classifier/unknown_bat_audio/*
chunk_time=20                                     # Audio chunk time in seconds.
export iterations=200000                          # Number of audio chunks, exported as environmental variable.

#TODO Allow a variable for overall time to be used and then claculate iterations from it.
# 5 hours with 15 second chunks -> 5 x 60 x 4 -> iterations = 1200.

cd /home/pi/Desktop/deploy_classifier/temp/
rm final.wav

printf "Iterations: $iterations\n"

export FILE=/home/pi/Desktop/deploy_classifier/Final_result.txt

f_create_filtered_wav_file ()
{
  echo "Bash_app reports: ... Now creating filtered.wav file ..... "
  cd /home/pi/Desktop/deploy_classifier/temp/
  sox new_${iter}.wav filtered.wav highpass 1k # highpass 15k highpass 15k highpass 15k highpass 15k highpass 15k highpass 15k 
  cp filtered.wav /home/pi/Desktop/deploy_classifier/unknown_bat_audio/
}

f_create_spectogram ()
{
  # Create spectogram:
  ##############################################################################
  sleep 2
  value2=`cat /home/pi/Desktop/deploy_classifier/helpers/toggled_02.txt`         # Options include 'text' and 'spectogram'. It's not from a toggled button any more!
  echo "bash_app reports: Value2 = "$value2
  if [ ${value2} = "spectogram" ]; then
    echo "bash_app reports: Spectogram now being created in python3 create_spectogram.py....."
    python3 /home/pi/Desktop/deploy_classifier/create_spectogram.py &            # Creates a spectogram from filtered.wav which lives in 'unknown_bat_audio folder.
  # else taskset 0x3 sh ./script_2.sh &                                          # Only run script_2 and classifier with no spectogram.
  fi
  ##############################################################################
}

f_main_loop ()
{
############################################################ Loop start
# counter=`cat /home/pi/Desktop/deploy_classifier/helpers/counter.txt`
counter=0
until [ $counter -gt ${iterations} ]
do
	while [ -e "$1/home/pi/Desktop/deploy_classifier/helpers/stop.txt" ]; do          # This loop will block the classifier and recorder whilst waiting for a 'stop.txt' file to appear in 'helpers' folder.
    printf "bash_app reports: ${RED}stop.txt${NC} file exists\n"
    sleep 2
    sh ./battery_info.sh                                                            # Get battery information.
    if [ -e "$1/home/pi/Desktop/deploy_classifier/helpers/shutDown.txt" ]; then     # Waiting for a 'shutDown.txt' file to appear in 'helpers' folder.
      echo "bash_app reports: shutDown.txt file exists"
      sleep 10
      sudo halt
      #sleep 200
      #exit does not seem to work!
    fi
    if [ -e "$1/home/pi/Desktop/deploy_classifier/helpers/restart.txt" ]; then     # Waiting for a 'restart.txt' file to appear in 'helpers' folder.
      echo "bash_app reports: restart.txt file exists"
      rm /home/pi/Desktop/deploy_classifier/helpers/restart.txt
      sleep 4
      exit
    fi
	done
  
  if [ -e "$1/home/pi/Desktop/deploy_classifier/helpers/restart.txt" ]; then     # Waiting for a 'restart.txt' file to appear in 'helpers' folder.
    echo "bash_app reports: restart.txt file exists"
    exit
  fi
    
  value=`cat /home/pi/Desktop/deploy_classifier/helpers/toggled_01.txt`      # Toggled options include 'record' and 'process'.
  
  if [ "$value" == "record" ]; then
    echo "bash_app reports: Recording! ....."
  
    # counter=`cat /home/pi/Desktop/deploy_classifier/helpers/counter.txt`
    export iter=$counter
    cd /home/pi/Desktop/deploy_classifier/
    iter2=$((iter-2))

    printf "${GREEN}${BLINK}bash_app reports: Now recording iteration ${iter} audio: ${NC}\n"
    taskset 0x2 arecord -f S16 -r 384000 -d ${chunk_time} -c 1 --device=plughw:r0,0 /home/pi/Desktop/deploy_classifier/temp/new_${iter}.wav &
#################################################
    wait
#################################################
    sh ./battery_info.sh &                                                        # Get battery information.
    f_create_filtered_wav_file &
    f_create_spectogram &                                                         # Create spectogram - or do classification.
    
    value2=`cat /home/pi/Desktop/deploy_classifier/helpers/toggled_02.txt`        # Options include 'text' and 'spectogram'. It's not from a toggled button any more!
    echo "bash_app reports: Value2 = "$value2
    if [ ${value2} = "text" ]; then
      sleep 1
      sh ./script_2.sh &                                                          # Only run script_2 and classifier with no spectogram.
    fi

    printf "${GREEN}Iteration ${iter} audio finished ${NC}\n"
    # rm Final_result.txt
    bat_detected=0
    cd /home/pi/Desktop/deploy_classifier/
    
    #printf "${GREEN}Counter before = ${counter} ${NC}\n"
    counter=$((counter + 1))
    #printf "${GREEN}Counter after = ${counter} ${NC}\n"

    # echo $counter > /home/pi/Desktop/deploy_classifier/helpers/counter.txt
  elif [ "$value" == "process" ]; then
    echo "bash_app reports: Processing! ...."
    sleep 2
    cd /home/pi/Desktop/deploy_classifier/
    python3 process_audio_files.py             # Adding a '&' to this causes lock up!
    # Does create_spectogram.py go here?
    # Why are the following 3 lines here?
    cd /home/pi/Desktop/deploy_classifier/helpers/
    rm start.txt
    touch stop.txt
  fi
  
done
############################################################ Loop end
}

cd /home/pi/Desktop/deploy_classifier/
# taskset 0x1  python GUI.py &                                  # The GUI app is on its own thread, core 0x1.
f_main_loop &


exit



export iter=$counter
cd /home/pi/Desktop/deploy_classifier/
printf "${RED}Now recording iteration ${iter} audio: ${NC}\n"
arecord -f S16 -r 384000 -d ${chunk_time} -c 1 --device=plughw:r0,0 /home/pi/Desktop/deploy_classifier/temp/new_${iter}.wav &
wait
printf "${RED}Iteration ${iter} audio finished ${NC}\n"
cd /home/pi/Desktop/deploy_classifier/temp/
sox new_${iter}.wav filtered.wav highpass 15k highpass 15k highpass 15k highpass 15k highpass 15k highpass 15k highpass 15k
cp filtered.wav /home/pi/Desktop/deploy_classifier/unknown_bat_audio/
cd /home/pi/Desktop/deploy_classifier/
printf "${BLUE}Now run iteration ${iter} classifier: ${NC}\n"
printf "Iteration: $iter\n"
Rscript Deploy_bats_pi.R
printf "${BLUE}Iteration ${iter} classifier has finished! ${NC}\n"
#iter2=$((iter-0))
if [ -f "$FILE" ]; then
  bat_detected=1
  cd /home/pi/Desktop/deploy_classifier/temp/
  cp new_${iter}.wav /home/pi/Desktop/deploy_classifier/detected_bat_audio/
  printf "${GREEN}Success: A bat classification result was published for iteration no. ${iter}! ${NC}\n"
else
  printf "${GREEN}No classification result was published for iteration no. ${iter2}! ${NC}\n"
fi

# TODO currently the last classification is not renamed to the bat name and timestamp so will get overwritten in the 'detected bats' folder.

#cd /home/pi/Desktop/deploy_classifier/
#rm Final_result.txt

#cd /home/pi/Desktop/deploy_classifier/temp/
#counter=0
#cp new_0.wav temp.wav
################################################################################

#iterations2=$((iterations+1))
#until [ $counter -gt ${iterations2} ]
#do
#  iter=$counter
#  printf "Iteration: $iter\n"
#  sox new_${iter}.wav temp.wav final.wav                      # Add first and second wav to third.
#  cp final.wav temp.wav
#  ((counter++))
#done

echo 'END'

f_test ()
{
  echo 'Testing this function'
}


f_classifier ()
{

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
# echo $(($(date +%s%N)/1000000))
printf "${BLUE}Now run iteration ${iter} classifier: ${NC}\n"
Rscript Deploy_bats_pi.R
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

}
