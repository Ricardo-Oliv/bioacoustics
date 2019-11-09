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
