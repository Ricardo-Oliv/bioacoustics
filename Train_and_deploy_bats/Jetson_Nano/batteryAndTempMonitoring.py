#!/usr/bin/env python3

# cd /home/tegwyn/ultrasonic_classifier/ && python3 batteryAndTempMonitoring.py
"""
================================================
ABElectronics ADC Pi 8-Channel ADC demo

Requires python smbus to be installed
run with: python demo_readvoltage.py
================================================

Initialise the ADC device using the default addresses and sample rate,
change this value if you have changed the address selection jumpers

Sample rate can be 12,14, 16 or 18
"""
from __future__ import absolute_import, division, print_function, \
                                                    unicode_literals
import time
import os

try:
	from ADCPi import ADCPi
except ImportError:
	print("Failed to import ADCPi from python system path")
	print("Importing from parent folder instead")
	try:
		import sys
		sys.path.append('..')
		from ADCPi import ADCPi
	except ImportError:
		raise ImportError(
			"Failed to import library from parent folder")


def main():
	'''
	Main program function
	'''
	adc = ADCPi(0x68, 0x69, 12)

	# clear the console
	# os.system('clear')
	
	file1 = '/sys/class/thermal/thermal_zone1/temp'
	if (os.path.getsize(file1) > 0):
		with open(file1, "r") as fp:
			text1 = fp.read()
			text1 = text1.strip('\n')
	fp.close()
	#print(text1,' °C')

	file2 = '/sys/class/thermal/thermal_zone2/temp'
	if (os.path.getsize(file2) > 0):
		with open(file2, "r") as fp:
			text2 = fp.read()
			text2 = text2.strip('\n')
	fp.close()
	#print(text2,' °C')

	file3 = '/sys/class/thermal/thermal_zone3/temp'
	if (os.path.getsize(file3) > 0):
		with open(file3, "r") as fp:
			text3 = fp.read()
			text3 = text3.strip('\n')
	fp.close()
	#print(text3,' °C'	)

	file5 = '/sys/class/thermal/thermal_zone5/temp'
	if (os.path.getsize(file5) > 0):
		with open(file5, "r") as fp:
			text5 = fp.read()
			text5 = text5.strip('\n')
	fp.close()
	#print(text5,' °C')

	# read from adc channels and print to screen
	batteryPackRead = float(adc.read_voltage(1))*3.9194
	switcherOutRead = float(adc.read_voltage(2))*1.1937
			
	#print("Channel 1: %02f" % adc.read_voltage(1))
	#print("Channel 2: %02f" % adc.read_voltage(2))
	#print("Channel 3: %02f" % adc.read_voltage(3))
	#print("Channel 4: %02f" % adc.read_voltage(4))
	#print("Channel 5: %02f" % adc.read_voltage(5))
	#print("Channel 6: %02f" % adc.read_voltage(6))
	#print("Channel 7: %02f" % adc.read_voltage(7))
	#print("Channel 8: %02f" % adc.read_voltage(8))
	#print("Channel 1: %02f" % batteryPackRead)
	#print("Channel 2: %02f" % switcherOutRead)
	# wait 0.2 seconds before reading the pins again
	# time.sleep(2)

	message = 'CPU: ' + str(round((int(text1) + int(text2) + int(text3) + int(text5))  /400) /10) + ' °C' + '  Bat: ' + str(round(batteryPackRead *100)/100) + ' V' + ' Sup: ' + str(round(switcherOutRead *100)/100) + ' V' 
	print(message)

	file6 = '/home/tegwyn/ultrasonic_classifier/helpers/battery_info.txt'
	f= open(file6, "w+")
	f.write(message)
	f.close()

	exit

if __name__ == "__main__":
    main()
