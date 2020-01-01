#!/bin/bash
# cd /home/pi/Desktop/deploy_classifier/ && bash run.sh
# sudo chmod u+x run.sh

RED='\e[41m'
BLUE='\e[44m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BLINK='\e[5m'

pivoyager enable low-battery-shutdown

cd /home/pi/Desktop/deploy_classifier/

printf "${RED}${BLINK}Hello !!!!!${NC}\n"
# printf "${RED}Running from destop icon seems to kill run.sh !!!! Why ????${NC}\n"


# Kill some shells if they are still running from previous session:

f_service_check()
{
  if pgrep -f "$SERVICE" >/dev/null
	then
		echo "$SERVICE is running"
		kill $(pgrep -f $SERVICE)
		sleep 2
	else
		echo "$SERVICE is NOT running"
	fi
}

# script_1.sh

SERVICE="GUI.py"
f_service_check "$SERVICE"
SERVICE="create_spectogram.py"
f_service_check "$SERVICE"
SERVICE="script_1.sh"
f_service_check "$SERVICE"

SERVICE="GUI.py"
f_service_check "$SERVICE"
SERVICE="create_spectogram.py"
f_service_check "$SERVICE"
SERVICE="script_1.sh"
f_service_check "$SERVICE"

# kill $(pgrep -f 'script_1.sh')
# kill $(pgrep -f 'GUI.py')
# kill $(pgrep -f 'create_spectogram.py')

if [ -e "$1/home/pi/Desktop/deploy_classifier/helpers/close_app.txt" ]; then     # Check if there is a close_app.txt file from a previous session.
  echo "Run.sh reports: restart.txt file exists"
  rm /home/pi/Desktop/deploy_classifier/helpers/close_app.txt
  echo "Run.sh reports: restart.txt file was deleted!"
fi
  
# The following loop looks for a restart.txt file to exist and then restarts run.sh if it does exist.
# This is here to enable the GUI to change Gtk boxes etc in the vertical or horixontal panes etc.
f_main_loop ()
{
echo "while loop start"
while true
do
  # echo "while loop"
  if [ -e "$1/home/pi/Desktop/deploy_classifier/helpers/restart.txt" ]; then     # Waiting for a 'restart.txt' file to appear in 'helpers' folder.
    echo "Run.sh reports: restart.txt file exists"
    sleep 4
    rm /home/pi/Desktop/deploy_classifier/helpers/restart.txt
    process_name="python"
    # pkill -9 -x $process_name
    # ./$(basename $0) && exit
    kill $(pgrep -f 'GUI.py')
    # sleep 4
    # wait
    # python GUI.py &
    # trap 'pkill -P $$' SIGINT SIGTERM                         # Is this still in memory somehow?
    # for i in {1..10}; do
      # sleep 10 &
    # done
    # wait
  else 
    echo "restart.txt file does not exist"
    echo "base name = " $(basename $0)
  fi
  sleep 4
done
}

printf "${GREEN}Services have been checked and stopped.${NC}\n"
sleep 2
printf "${GREEN}Now try to run GUI.py ......${NC}\n"
python GUI.py &
bash ./script_1.sh &
printf "${GREEN}script_1 has been started.${NC}\n"
sleep 2

echo "while loop start"
while true
do
  # echo "while loop"
  if [ -e "$1/home/pi/Desktop/deploy_classifier/helpers/close_app.txt" ]; then     # Waiting for a 'close_app.txt' file to appear in 'helpers' folder.
    echo "Run.sh reports: close_app.txt file exists"
    exit
  # else
    # echo "close_app.txt file does not exist"
    # echo "base name = " $(basename $0)
  fi
  sleep 4
done

printf "${RED}Will not start the GUI !!!!${NC}\n"
sleep 5


# f_main_loop &       # Seems like killing stuff works better in bash_app !!!!


# ps -u pi       # Use this to see what shells are running under user = pi.
# ps -U root -u root -N
# ps -o pid,ppid,sess,cmd -u pi python
# ps -o pid,ppid,sess,cmd -U pi | grep 'GUI.py\|PID'
# ps -o ppid,cmd -U pi | grep 'GUI.py\|PID'
# ps -o ppid,cmd -U pi | grep 'run.sh\|PID'
# ps -o pid,cmd -U pi | grep 'run.sh\|PID'
# kill $(pgrep -f 'GUI.py')
# kill $(pgrep -f 'bash_app.sh')

# trap 'pkill -P $$' SIGINT SIGTERM
# for i in {1..10}; do
   # sleep 10 &
# done
# wait

# ppid = parent process id

# pkill -15 -P 8066

# The -g option tells killall to terminate the entire process group to which the specified process belongs.
# The -l option tells killall to list all known signal names. 
# $ killall -l
# HUP INT QUIT ILL TRAP ABRT BUS FPE KILL USR1 SEGV USR2 PIPE ALRM TERM STKFLT
# CHLD CONT STOP TSTP TTIN TTOU URG XCPU XFSZ VTALRM PROF WINCH POLL PWR SYS

# The -w option tells killall to wait for all designated processes to die.
# killall's basic syntax is:  killall [options] program_name(s)

# kill -9 bash_app
# killall -9 bash
# killall -9 python3
# pkill -9 app
# killall -9 python && killall -9 bash

# How to kill processes older than TIME
# Want to kill a process called vim that has been running for more than 24 hours? Try:
# killall -o 24h appName
# killall -o 24h vim

# s	seconds
# m	minutes
# h	hours
