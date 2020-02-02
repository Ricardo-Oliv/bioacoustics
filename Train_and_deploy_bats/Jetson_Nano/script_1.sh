#!/bin/bash
# $ cd /home/tegwyn/ultrasonic_classifier/ && bash script_1.sh
# Record 10 second chunks of audio on UltraMic384K, apply a 15K highpass filter, run the randomforest classifier. Repeat.
# lscpu
# arecord -l

RED='\e[41m'
BLUE='\e[44m'
GREEN='\033[0;32m'
CYAN='\e[36m'
MAGENTA='\e[45m'
GREY='\e[100m'
YELLOW='\e[93m'

NC='\033[0m' # No Color
BLINK='\e[5m'

amixer sset PCM 100%

# **** List of PLAYBACK Hardware Devices ****
# card 0: tegrahda [tegra-hda], device 3: HDMI 0 [HDMI 0]
aplay --device=hw:0,3 /home/tegwyn/ultrasonic_classifier/alert_sounds/Go_for_Deploy.wav
# aplay --device=hw:0,0 /home/tegwyn/ultrasonic_classifier/alert_sounds/Go_for_Deploy.wav

# sudo chmod 775 /home/tegwyn/ultrasonic_classifier/helpers/toggled_01.txt

cd /home/tegwyn/ultrasonic_classifier/

rm /home/tegwyn/ultrasonic_classifier/From_R_01.csv
rm Final_result.txt
rm Final_result_copy.txt
cd /home/tegwyn/ultrasonic_classifier/helpers/

#rm stop.txt
rm start.txt
touch stop.txt
rm shutDown.txt
# rm /home/tegwyn/ultrasonic_classifier/temp/*
rm /home/tegwyn/ultrasonic_classifier/unknown_bat_audio/*
chunk_time=60                                     # Audio chunk time in seconds.
export iterations=200000                          # Number of audio chunks, exported as environmental variable.

#TODO Allow a variable for overall time to be used and then claculate iterations from it.
# 5 hours with 15 second chunks -> 5 x 60 x 4 -> iterations = 1200.

cd /home/tegwyn/ultrasonic_classifier/temp/
rm final.wav

printf "Iterations: $iterations\n"

export FILE=/home/tegwyn/ultrasonic_classifier/Final_result.txt

f_create_spectogram_or_graph ()
{
  # Create spectogram:
  ##############################################################################
  sleep 2
  value2=`cat /home/tegwyn/ultrasonic_classifier/helpers/toggled_02.txt`         # Options include 'text' and 'spectogram' and 'graph'. BEWARE: It's not actually from a toggled button any more!
  echo "script_1 reports: Value2 = "$value2
  if [ ${value2} = "spectogram" ]; then
    echo "script_1 reports: Spectogram now being created in python3 create_spectogram.py....."
    python3 /home/tegwyn/ultrasonic_classifier/create_spectogram.py &            # Creates a spectogram from filtered.wav which lives in 'unknown_bat_audio folder.
  elif [ ${value2} = "graph" ]; then
    echo "script_1 reports: Graph now being created in python3 create_barchart.py....."
    python3 /home/tegwyn/ultrasonic_classifier/create_barchart.py &              # Creates a barchart from filtered.wav which lives in 'unknown_bat_audio folder.
  fi
  ##############################################################################
}

f_main_loop ()
{
############################################################ Loop start
# counter=`cat /home/tegwyn/ultrasonic_classifier/helpers/counter.txt`
counter=0
chunk_time=`cat /home/tegwyn/ultrasonic_classifier/helpers/chunk_size_record.txt` 
# until [ $counter -gt ${iterations} ]
while true
do
    while [ -e "$1/home/tegwyn/ultrasonic_classifier/helpers/stop.txt" ]; do          # This loop will block the classifier and recorder whilst waiting for a 'stop.txt' file to appear in 'helpers' folder.
		printf "script_1 reports: ${RED}stop.txt${NC} file exists\n"
		sleep 2
		if [ -e "$1/home/tegwyn/ultrasonic_classifier/helpers/shutDown.txt" ]; then     # Waiting for a 'shutDown.txt' file to appear in 'helpers' folder.
		  echo "script_1 reports: shutDown.txt file exists"
		  sleep 10
		  sudo halt
		  #sleep 200
		  #exit does not seem to work!
		fi
		if [ -e "$1/home/tegwyn/ultrasonic_classifier/helpers/restart.txt" ]; then     # Waiting for a 'restart.txt' file to appear in 'helpers' folder.
		  echo "script_1 reports: restart.txt file exists"
		  rm /home/tegwyn/ultrasonic_classifier/helpers/restart.txt
		  sleep 4
		  exit
		fi
    done
  
	if [ -e "$1/home/tegwyn/ultrasonic_classifier/helpers/restart.txt" ]; then     # Waiting for a 'restart.txt' file to appear in 'helpers' folder.
		echo "script_1 reports: restart.txt file exists"
		exit
	fi

	value=`cat /home/tegwyn/ultrasonic_classifier/helpers/toggled_01.txt`      # Toggled options include 'record' and 'process'.

	if [ "$value" == "record" ]; then
		# echo "script_1 reports: Recording! ....."

		# counter=`cat /home/tegwyn/ultrasonic_classifier/helpers/counter.txt`
		export iter=$counter
		cd /home/tegwyn/ultrasonic_classifier/
		# iter2=$((iter-2))

		# printf "${GREEN}${BLINK}Script_1  reports: Now recording iteration ${iter} audio: ${NC}\n"
		printf "${GREEN}Script_1 chunk_time: ${chunk_time} ${NC}\n"
		# arecord -f S16 -r 384000 -d ${chunk_time} -c 1 --device=plughw:r0,0 /home/tegwyn/ultrasonic_classifier/temp/new_${iter}.wav &
		sh ./record_and_filter.sh
		#################################################
		# TODO: wait seems not to be working !!!!!
		# wait
		#################################################
		chunk_time=`cat /home/tegwyn/ultrasonic_classifier/helpers/chunk_size_record.txt`           # Update record audio chunk size in seconds
		# printf "${GREY}Update record audio chunk size in seconds = ${chunk_time}${NC}\n"
		# f_create_filtered_wav_file &
		f_create_spectogram_or_graph  &                                                             # Create spectogram or graph.

		value2=`cat /home/tegwyn/ultrasonic_classifier/helpers/toggled_02.txt`                       # Options include 'text' and 'spectogram'. It's not from a toggled button any more!
		##############################################################
		echo "Script_1 reports: Value2 = "$value2
		# if [ ${value2} = "text" ]; then
		  # sleep 1
		  sh ./script_2.sh &                                                          # Only run script_2 and classifier with no spectogram.
		# fi
		##############################################################
		printf "${GREEN}Iteration ${iter} audio finished ${NC}\n"
		# rm Final_result.txt
		bat_detected=0
		cd /home/tegwyn/ultrasonic_classifier/

		#printf "${GREEN}Counter before = ${counter} ${NC}\n"
		counter=$((counter + 1))
		#printf "${GREEN}Counter after = ${counter} ${NC}\n"

		# echo $counter > /home/tegwyn/ultrasonic_classifier/helpers/counter.txt
	elif [ "$value" == "process" ]; then
		# echo "script_1 reports: Processing! ...."
		printf "${GREEN}script_1 reports: Processing! .... ${NC}\n"
		sleep 2
		cd /home/tegwyn/ultrasonic_classifier/

		python3 process_audio_files.py             # Adding a '&' to this causes lock up!
		# Create_barchart is called within process_audio_files.py !!!!!

		# Does create_spectogram.py go here?
		# The following 3 lines tell the main while loop that processing has finished and to wait for next user task.
		cd /home/tegwyn/ultrasonic_classifier/helpers/
		rm start.txt
		touch stop.txt
	fi
  
done
############################################################ Loop end
}

cd /home/tegwyn/ultrasonic_classifier/
# taskset 0x1  python GUI.py &                                  # The GUI app is on its own thread, core 0x1.
f_main_loop &


exit

