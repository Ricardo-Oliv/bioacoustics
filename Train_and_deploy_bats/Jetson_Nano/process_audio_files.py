# cd /home/tegwyn/ultrasonic_classifier/ && python3 process_audio_files.py
# python3 process_audio_files.py
# cd /home/tegwyn/ultrasonic_classifier/ && chmod 775 process_audio_files.py

import subprocess
from pathlib import Path
from pydub import AudioSegment
from pydub.utils import make_chunks
import os
import datetime
import re
import time
import colorama
from colorama import Fore, Back, Style
import sys

end = "\n"
RED = "\x1b[1;31m"
BLUE='\e[44m'
F_LightGreen = "\x1b[92m"
F_Green = "\x1b[32m"
F_LightBlue = "\x1b[94m"
B_White = "\x1b[107m"
NC = "\x1b[0m" # No Color
Blink = "\x1b[5m"

# file = "/home/tegwyn/ultrasonic_classifier/my_audio/noctula_Oct_31_2019_01.wav"
file = "/home/tegwyn/ultrasonic_classifier/my_audio/11_oct_2019_01.wav"                # 110 Mb
file2 = "/home/tegwyn/ultrasonic_classifier/Final_result.txt"
file3 = "/home/tegwyn/ultrasonic_classifier/Final_result_copy.txt"
file4='/home/tegwyn/ultrasonic_classifier/helpers/combo_01.txt'
file5 = "/home/tegwyn/ultrasonic_classifier/helpers/toggled_02.txt"                    # text or spectigram or graph.
folder1 = "/home/tegwyn/ultrasonic_classifier/"
folder2 = "/home/tegwyn/ultrasonic_classifier/processed_audio/"
folder3 = "/home/tegwyn/ultrasonic_classifier/unknown_bat_audio/"
folder4 = "/home/tegwyn/ultrasonic_classifier/my_audio"
directory = os.fsencode("/home/tegwyn/ultrasonic_classifier/my_audio")

# Define command and arguments
command = 'Rscript'
command_python = "python3"
command_bash = "bash"

path_to_create_spectogram = "/home/tegwyn/ultrasonic_classifier/create_spectogram.py"
# path_to_create_spectogram = "/home/tegwyn/ultrasonic_classifier/create_spectogram_batch_process.py"       # Use this for experiments with spectograpghs.
path_to_create_graph = "/home/tegwyn/ultrasonic_classifier/create_barchart.py"
path_to_battery = "/home/tegwyn/ultrasonic_classifier/battery_info.sh"                      # Not used anymore.

n = 1
line = [1, 2, 3, 4, 5]

sys.stderr.write('\x1b[1;31m' + "Start of process_audio_files.py !!!!" + '\x1b[0m' + end)

f = open(file5)             # toggled_02.txt
text_or_graph_or_spectogram = f.readline()
print("From process_audio_files.py: Is it text or graph or spectogram?")
print(text_or_graph_or_spectogram )
f.close()

f = open(file4)             # combo_01.txt
while True:
    # read line
    x = f.readline()
    line[n] = x
    n = n + 1
    # print(x)
    # check if line is not empty
    if not x:
        break
f.close()

if (line[1] == "UK_Bats\n"):
	print ("UK_Bats was selected")
elif (line[1] == "Rodents\n" ):
	print ("Rodents was selected")
elif (line[1] == "Mechanical_Bearings"):
	print ("Mechanical_Bearings was selected")

if (line[2] == "Level1:_Species\n"):
	print ("Level1:_Species was selected")
elif (line[2] == "Level2:_Genera\n" ):
	print ("Level2:_Genera was selected")
elif (line[2] == "Level3:_Order\n"):
	print("Level3:_Order was selected")
elif (line[2] == "Bicycle_Wheel\n" ):
	print ("Bicycle_Wheel was selected")

if (line[3] ==  "All_Calls"):
	print("All_Calls was selected")
elif (line[3] == "Echolocation_Only" ):
	print("Echolocation was selected")
elif (line[3] == "Socials_Only" ):
	print("Socials was selected")
elif (line[3] == "NULL" ):
	print("NULL was selected")

if ((line[1] == "UK_Bats\n") and (line[2] == "Level1:_Species\n")):
	path2script = '/home/tegwyn/ultrasonic_classifier/Deploy_bats_pi.R'
	print ("Level 1 was deployed")
elif ((line[1] == "UK_Bats\n" ) and (line[2] == "Level2:_Genera\n" )):
	path2script = '/home/tegwyn/ultrasonic_classifier/Deploy_bats_pi_Level2.R'
	print ("Level 2 was deployed")
elif ((line[1] == "UK_Bats\n" ) and (line[2] == "Level3:_Order\n" )):
	path2script = '/home/tegwyn/ultrasonic_classifier/Deploy_bats_pi_Level3.R'
	print ("Level 3 was deployed")
else:
	print ("No valid combo box selection was made")


print("Starting .....")

for file in os.listdir(directory):                                       # This loop will carry on going as long as there are more files to process.
    filename = os.fsdecode(file)
    sys.stderr.write('\x1b[1;31m' + "Processing new wav file ...." + '\x1b[0m' + end)
    if filename.endswith(".wav"):
        # print(filename)
        # print(os.path.join(directory, filename))
        file_to_process = os.path.join(folder4, filename)
        # print(file_to_process)

        myaudio = AudioSegment.from_file(file_to_process , "wav") 
        # chunk_length_ms = 5000                         # pydub calculates in millisec ....... 5 seconds
        # chunk_length_ms = 500                            # pydub calculates in millisec ..... 1/2 second
        chunk_length_ms = 125                            # pydub calculates in millisec
        chunks = make_chunks(myaudio, chunk_length_ms)

        #Export all of the individual chunks as wav files

        for i, chunk in enumerate(chunks):
            sys.stderr.write('\x1b[1;31m' + "Processing audio chunk ...." + '\x1b[0m' + end)
            # if Final_result.txt" exists ......
            if Path(folder1 + "Final_result.txt").is_file():
                # print (i," File exists")
                os.unlink(file2)     # delete "Final_result.txt"
            # else:
                # print (i," File not exist")
                # continue
            for file in os.scandir(folder3) :                            # Delete all wav files in unknown_bat_audio.
                if file.name.endswith(".wav"):
                    os.unlink(file)

            chunk_name = "chunk{0}.wav".format(i)
            # print ("Processing ", chunk_name)
            # print(folder3 + chunk_name)
            chunk.export(folder3 + chunk_name, format="wav")             # folder3 is "unknown_bat_audio".
            # chunk.export(folder3 + filtered, format="wav")             # folder3 is "unknown_bat_audio". There is no actual filter applied .... yet !!
            
            # Build subprocess command
            cmd = [command, path2script]
            x = subprocess.Popen(cmd).wait()                              # This is where the classifier program is called. Not script_2.sh !!

            # if Final_result.txt" exists ......
            if Path(folder1 + "Final_result.txt").is_file():
                # print (i," Detected!")
                detected = "Something was detected:"
                
##############################################################################################################
                if text_or_graph_or_spectogram == "spectogram":
                    # Build subprocess command
                    cmd = [command_python, path_to_create_spectogram]
                    print(cmd)
                    x = subprocess.Popen(cmd).wait()                              # This is where the create spectogram program is called.
                if text_or_graph_or_spectogram == "graph":
                    # Build subprocess command
                    cmd = [command_python, path_to_create_graph]
                    print(cmd)
                    x = subprocess.Popen(cmd).wait()                              # This is where the create spectogram program is called.
######################################################################################################################
                    
                file2 = "/home/tegwyn/ultrasonic_classifier/Final_result.txt"
                newText = ""
                line2 = ""
                line3 = ""
                zzz = ""
                bat = ""
                prob = ""
                lines = 0
                with open(file2) as fp:
                    line = fp.readline()
                    cnt = 1
                    while line :
                        line = fp.readline()
                        line2 = re.sub('\ |\"|\!|\/|\;|\:', '', line)
                        if cnt < 2:
                            zzz = re.split(r'\t+', line2)
                            bat = zzz.pop(0)
                            prob = zzz.pop(1)
                            # print(bat)
                            # print(prob)
                            number = int(round((float(prob))*100,0))
                            newText = str(number) + "%_" + bat
                        cnt += 1
                #print(newText)
                fp.close()

                Current_Date = datetime.datetime.today().strftime ('%d-%b-%Y-%H:%M:%S')
                old_file = os.path.join(folder3, chunk_name)
                new_file = os.path.join(folder2, newText + "_" + Current_Date)
                os.rename(old_file, new_file)

            else:
                # print (i," Nothing detected")
                detected = "Nothing detected"
                newText = ""

        #for i, chunk in enumerate(chunks):
            # sys.stderr.write('\x1b[1;31m' + "Process audio chunk ...." + '\x1b[0m' + end)
            # print(file_to_process)
            # print(filename)
            # print ("Processing ", chunk_name)
            # print(detected)
            # print(newText)
            message = filename + "\n" + "Processing: " + chunk_name + "\n" + detected  + "\n" + newText
            print(message)

            file = file3
            f= open(file, "w+")
            f.write(message)
            f.close()

        #for i, chunk in enumerate(chunks):  finishes here.


message = "Finished!" + "\n" + "Check out the 'processed_audio' folder for results."
print("\n" + message)
file = file3
f= open(file, "w+")
f.write(message)
f.close()
# time.sleep(5)         # Allows GUI to catch up.
sys.stderr.write('\x1b[1;31m' + "End of process_audio_files.py !!!!" + '\x1b[0m' + end)
