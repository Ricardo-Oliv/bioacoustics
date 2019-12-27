# cd /home/pi/Desktop/deploy_classifier/ && python3 create_spectogram.py


import matplotlib.pyplot as plot
from scipy.io import wavfile
import os
import sys

file = "/home/pi/Desktop/deploy_classifier/unknown_bat_audio/filtered.wav"

if os.path.isfile(file):
	print("We found a wav file filtered,wav ....... ")

	samplingFrequency, signalData = wavfile.read(file)
	plot.rcParams['figure.figsize'] = [6.5, 5]
	plot.subplot(211)
	plot.specgram(signalData,Fs=samplingFrequency)
	# plot.xlabel('Time, seconds')
	# plot.ylabel('Frequency')
	plot.savefig('/home/pi/Desktop/deploy_classifier/images/spectograms/specto.png', bbox_inches='tight')
	# plot.show()
	
sys.exit()
