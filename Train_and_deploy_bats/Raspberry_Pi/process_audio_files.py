# cd /home/pi/Desktop/deploy_classifier/ && python3 process_audio_files.py
# python3 process_audio_files.py

import subprocess
from pathlib import Path
from pydub import AudioSegment
from pydub.utils import make_chunks
import os
import datetime
import re
import time

# file = "/home/pi/Desktop/deploy_classifier/my_audio/noctula_Oct_31_2019_01.wav"
file = "/home/pi/Desktop/deploy_classifier/my_audio/11_oct_2019_01.wav"                # 110 Mb
file2 = "/home/pi/Desktop/deploy_classifier/Final_result.txt"
file3 = "/home/pi/Desktop/deploy_classifier/Final_result_copy.txt"
folder1 = "/home/pi/Desktop/deploy_classifier/"
folder2 = "/home/pi/Desktop/deploy_classifier/processed_audio/"
folder3 = "/home/pi/Desktop/deploy_classifier/unknown_bat_audio/"
folder4 = "/home/pi/Desktop/deploy_classifier/my_audio"

# Define command and arguments
command = 'Rscript'
path2script = '/home/pi/Desktop/deploy_classifier/Deploy_bats_pi.R'

directory = os.fsencode("/home/pi/Desktop/deploy_classifier/my_audio")

print("Starting .....")

for file in os.listdir(directory):
    filename = os.fsdecode(file)
    if filename.endswith(".wav"):
        # print(filename)
        # print(os.path.join(directory, filename))
        file_to_process = os.path.join(folder4, filename)
        # print(file_to_process)

        myaudio = AudioSegment.from_file(file_to_process , "wav") 
        chunk_length_ms = 5000                         # pydub calculates in millisec
        chunks = make_chunks(myaudio, chunk_length_ms) # Make chunks of 5 secs.

        #Export all of the individual chunks as wav files

        for i, chunk in enumerate(chunks):

            # if Final_result.txt" exists ......
            if Path(folder1 + "Final_result.txt").is_file():
                # print (i," File exists")
                os.unlink(file2)     # delete "Final_result.txt"
            # else:
                # print (i," File not exist")
                # continue
            for file in os.scandir(folder3) :            # Delete all wav files in unknown_bat_audio
                if file.name.endswith(".wav"):
                    os.unlink(file)

            chunk_name = "chunk{0}.wav".format(i)
            # print ("Processing ", chunk_name)
            # print(folder3 + chunk_name)
            chunk.export(folder3 + chunk_name, format="wav")

            # Build subprocess command
            cmd = [command, path2script]
            x = subprocess.Popen(cmd).wait()

            # if Final_result.txt" exists ......
            if Path(folder1 + "Final_result.txt").is_file():
                # print (i," Detected!")
                detected = "Something was detected:"
                file2 = "/home/pi/Desktop/deploy_classifier/Final_result.txt"
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
            print("")
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
time.sleep(5)         # Allows GUI to catch up.
