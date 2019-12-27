#!/bin/bash
# cd /home/pi/Desktop/deploy_classifier/ && bash run.sh
# sudo chmod u+x run.sh
cd /home/pi/Desktop/deploy_classifier/
echo "Hello !!!"



# The following loop looks for a restart.txt file to exist and then restarts run.sh if it does exist.
# This is here to enable the GUI to change Gtk boxes etc in the vertical or horixontal panes etc.
f_main_loop ()
{
echo "while loop start"
while true
do
  # echo "while loop"
  if [ -e "$1/home/pi/Desktop/deploy_classifier/helpers/restart.txt" ]; then     # Waiting for a 'restart.txt' file to appear in 'helpers' folder.
    echo "restart.txt file exists"
    rm /home/pi/Desktop/deploy_classifier/helpers/restart.txt
    process_name="python"
    # pkill -9 -x $process_name
    # ./$(basename $0) && exit
    kill $(pgrep -f 'GUI.py')
  else 
    echo "restart.txt file does not exist"
    echo "base name = " $(basename $0)
  fi
  sleep 4
done
}

f_main_loop &
bash ./bash_app.sh &
python GUI.py $


# ps -u pi       # Use this to see what shells are running under user = pi.
# ps -U root -u root -N
# ps -o pid,ppid,sess,cmd -u pi python
# ps -o pid,ppid,sess,cmd -U pi | grep 'GUI.py\|PID'
# ps -o ppid,cmd -U pi | grep 'GUI.py\|PID'
# ps -o ppid,cmd -U pi | grep 'run.sh\|PID'
# ps -o pid,cmd -U pi | grep 'run.sh\|PID'
# kill $(pgrep -f 'GUI.py')

# ppid = parent process id

# pkill -15 -P 8066
