#!/usr/bin/python

# cd /home/pi/Desktop/deploy_classifier/ && python3 create_spectogram.py
# cd /home/pi/Desktop/deploy_classifier/ && chmod 775 create_spectogram.py


import matplotlib.pyplot as plot
from scipy.io import wavfile
import os
import sys

folder1 = "/home/pi/Desktop/deploy_classifier/"
folder2 = "/home/pi/Desktop/deploy_classifier/processed_audio/"
folder3 = "/home/pi/Desktop/deploy_classifier/unknown_bat_audio/"
folder4 = "/home/pi/Desktop/deploy_classifier/my_audio"


# file_to_process = "/home/pi/Desktop/deploy_classifier/unknown_bat_audio/filtered.wav"
directory = os.fsencode("/home/pi/Desktop/deploy_classifier/unknown_bat_audio/")
for file in os.listdir(directory):                                       # This loop will carry on going as long as there are more files to process.
    filename = os.fsdecode(file)
    if filename.endswith(".wav"):
        # print(filename)
        # print(os.path.join(directory, filename))
        file_to_process = os.path.join(folder3, filename)
        # print(file_to_process)

if os.path.isfile(file_to_process):
	print("From create_spectogram .... We found a wav file filtered.wav ....... ")
	samplingFrequency, signalData = wavfile.read(file_to_process)
	plot.rcParams['figure.figsize'] = [6.5, 5]
	plot.subplot(211)
	plot.specgram(signalData,Fs=samplingFrequency)
	# plot.xlabel('Time, seconds')
	# plot.ylabel('Frequency')
	plot.savefig('/home/pi/Desktop/deploy_classifier/images/spectograms/specto.png', bbox_inches='tight')
	# plot.show()
	
# sys.exit()
# Exit with status os.EX_OK 
# using os._exit() method 
# The value of os.EX_OK is 0         
os._exit(os.EX_OK)



