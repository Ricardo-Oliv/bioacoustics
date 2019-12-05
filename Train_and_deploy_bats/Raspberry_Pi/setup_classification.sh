#!/bin/bash
# cd /home/pi/Desktop/
# bash test_01.sh

# ChosenDate=$(zenity --calendar --text "Choose a date" --title "How-To Geek Rota" --date-format="%A %d/%m/%y" --day 1 -- month 9 --year 2019); echo $ChosenDate
# zenity --file-selection --title "How-To Geek" --multiple --file-filter='*.mm *.png *.page *.sh *.txt'
# zenity --error --width 300 --text "Permission denied. Cannot write to the file."
# zenity --question --width 300 --text "Are you happy to proceed?"; echo $?
# (for i in $(seq 0 10 100); do echo $i; sleep 1; done) | zenity --progress --title "How-To Geek" -- auto-close
# zenity --info --text="This is an information box. We probably want to read an external file rather than type stuff her." --width=800 --height=400
# ans=$(zenity --width=800 --height=400 --list  --text "Is linux.byexamples.com helpful?" --radiolist  --column "Pick" --column "Opinion" TRUE Amazing FALSE Average FALSE "Difficult to follow" FALSE "Not helpful"); echo $ans

f_initial_question()
{
createNewSettings=1
# while [ $proceedStatus -gt 0 ]; do
zenity --question --width 300 --text="Do you want to proceed with your previous/default settings?" --ok-label="Yes" --cancel-label="No"
if [ $? = 0 ] ; then  # YES
  zenity --question --width 300 --text="Sure you want to start recording?" --ok-label="Yes" --cancel-label="No"
  if [ $? = 0 ] ; then
    # echo "YES TWO was selected"
    createNewSettings=0  # NO
  fi
  # echo "YES ONE was selected"
elif [ $createNewSettings -gt 0 ]; then  # NO
  # echo "NO ONE was selected"
  createNewSettings=1   # YES
  cp /home/pi/Desktop/configClassifier.txt /home/pi/Desktop/configClassifier.txt.bak
  rm /home/pi/Desktop/configClassifier.txt
  touch /home/pi/Desktop/configClassifier.txt
fi
  # echo "createNewSettings value is: "$createNewSettings
# done;
}


f_create_scale () 
{
	# line=1
    # Define command
    VALUE=`zenity --scale --title="Threshold" --text="Set detection threshold (default = 50):" --value=50 --min-value=0 --max-value=90 --step=5  --width=1200 --height=600`
    case $? in
        0) f_append_to_file;;
        1) echo "No value selected.";;
        -1) echo "An unexpected error has occurred.";;
    esac
    echo ".... Create scale finished"
}




f_bat_options_01 ()
{
  # line=1                        # The line in configClassifier.txt that's going to store option_02 info.
  # Display hardware listing for this computer

  # TempFile=$(mktemp)

  ListType=`zenity --width=400 --height=275 --list --radiolist \
     --title 'Classification Options' \
     --text 'Select the level of classification detail:' \
     --column 'Select' \
     --column 'classification option:' TRUE "Default_settings" FALSE "Bats_Order" FALSE "Bats_Genus" FALSE "Bats_Species" FALSE "More_options" `

  if [[ $? -eq 1 ]]; then

    # they pressed Cancel or closed the dialog window 
    zenity --error --title="Scan Declined" --width=200 \
       --text="Hardware scan skipped"
   # exit 1
 
  elif [ $ListType == "Default_settings" ]; then
    # they selected the short radio button 
    VALUE=1

  elif [ $ListType == "Bats_Order" ]; then
    # they selected the short radio button 
    VALUE=2
  
  elif [ $ListType == "Bats_Genus" ]; then
    # they selected the short radio button 
    VALUE=3
  
  elif [ $ListType == "Bats_Species" ]; then
    # they selected the short radio button 
    VALUE=4

  else
    # they selected the more options button 
    VALUE=5
  fi

  f_append_to_file
  echo ".... Bat options 01 finished"

}




f_append_to_file ()
{
  line=1
  echo "You selected $VALUE."
  destdir=/home/pi/Desktop/configClassifier.txt

  if [ -f "$destdir" ]
  then 
    echo "Start append to file ...... "
    # ex -snc '$-'$line',$d|x' "$destdir"       # Something wrong with this line?
    echo "Next...... "
    ex -s -c ''$line'i|'$VALUE'' -c x configClassifier.txt
    # echo "$VALUE > "$destdir"
    # ex -snc '$-11,$d|x' "$destdir"
    # awk 'NR==3{print "Exp1"}NR==5{print "Exp2"}1' configClassifier.txt
    # sed -i '5s/true/false/' configClassifier.txt
    # sed -i '1ihelloworld' configClassifier.txt
    # sed -i ''$line' i'$VALUE'' "$destdir"
    # sed -i '3 cFalse' configClassifier.txt 
    # line=3
    # sed "${line} i abcd" configClassifier.txt 
    # var1="Hello"
    # var2="World!"
    # var3="!!!!!!!!"
    # logwrite="$var1\n$var2\n$var3"
    # echo -e "$logwrite"  >> configClassifier.txt
    # sed -i[SUFFIX], --in-place[=SUFFIX]

    echo "configClassifier was updated."
  fi
  echo "Now print out line 1:"
  sed -n 1p /home/pi/Desktop/configClassifier.txt
  echo "Now print out line 2:"
  sed -n 2p /home/pi/Desktop/configClassifier.txt
  echo "Now print out line 3:"
  sed -n 3p /home/pi/Desktop/configClassifier.txt
}


# Main function
# if [ $STATUS -ne 200 ] && [[ "$STRING" != "$VALUE" ]]; then
f_main () 
{
	f_initial_question
	# if [ $? = 0 ] ; then  # YES
	# echo "createNewSettings value 2 is: "$createNewSettings
	if [ $createNewSettings -eq 1 ]; then     # Set up variables
	  f_create_scale
	  f_bat_options_01
	  # f_read_hardware
      zenity --question --width 300 --text="Do you want to proceed with your new settings?" --ok-label="Yes" --cancel-label="No"
      if [ $? = 0 ] ; then  # YES
        zenity --question --width 300 --text="Sure you want to start recording?" --ok-label="Yes" --cancel-label="No"
        if [ $? = 0 ] ; then
        # echo "YES TWO was selected"
        # createNewSettings=0  # NO
        /home/pi/Desktop/deploy_classifier/bash_app
          zenity --question --width 300 --text="Do you want to stop recording?" --ok-label="Yes" --cancel-label="No"
          #if [ $? = 0 ] ; then
            # echo "YES TWO was selected"
            # createNewSettings=0  # NO
            #exit
          #fi
        fi
      fi
    else
      echo "No new settings were required!"
      exit
    fi
}
f_main
exit

# zenity --info --text="This is an information box." --width=1200 --height=400

# zenity --help












f_read_hardware ()
{
# Display hardware listing for this computer

TempFile=$(mktemp)

ListType=`zenity --width=400 --height=275 --list --radiolist \
     --title 'Classification Options' \
     --text 'Select the level of classification detail:' \
     --column 'Select' \
     --column 'classification option:' TRUE "Default_settings" FALSE "Bats_Order" FALSE "Bats_Genus" FALSE "Bats_Species" FALSE "More_options" `

if [[ $? -eq 1 ]]; then

  # they pressed Cancel or closed the dialog window 
  zenity --error --title="Scan Declined" --width=200 \
       --text="Hardware scan skipped"
  # exit 1
 
elif [ $ListType == "Default_settings" ]; then

  # they selected the short radio button 
  Flag="--short"

elif [ $ListType == "Bats_Order" ]; then

  # they selected the short radio button 
  Flag="--cpu"
  
elif [ $ListType == "Bats_Genus" ]; then

  # they selected the short radio button 
  Flag="--version"
  
elif [ $ListType == "Bats_Species" ]; then

  # they selected the short radio button 
  Flag="--version"

else

  # they selected the more options button 
  Flag="--version" 
fi

# search for hardware info with the appropriate value in $Flag
hwinfo $Flag | tee >(zenity --width=200 --height=100 \
     --title="Collating Information" --progress \
     --pulsate --text="Checking hardware..." \
     --auto-kill --auto-close) >${TempFile}
 
# Display the hardware info in a scrolling window
zenity --width=800 --height=600 \
     --title "Hardware Details" \
     --text-info --filename="${TempFile}"
 
# exit 0
}
