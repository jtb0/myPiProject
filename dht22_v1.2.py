#!/usr/bin/env python
#coding: utf8 

###############################################################################
#                                                                             #
# reads the ports from the config file used for DHT22 sensors                 #
# Please take care for the correct entry at the config file                   #
#                                                                             #
# example:                                                                    #
# $ cat /etc/pi-setup/pi.cfg | grep dht22                                     #
# $ dht22 = ['26']                                                            #
#                                                                             #
# The logical port numbers (BCM) are used in this script                      #
# physical Pin 37 = BCM 26                                                    #
#                                                                             #
###############################################################################

import time
import os
import sys
#import ast to fix a returned list (as str) object into a real list
import ast
import RPi.GPIO as GPIO
import Adafruit_DHT
import ConfigParser

# set the sys.argv for the import of the editConffile
conffile=sys.argv[1]
sys.argv=["/home/pi/myPiProject/editConffile.py", sys.argv[1], "get", "network", "network", "0"]
import editConffile

section="things"
variable="dht22"
network=editConffile.optionGet(conffile, "network", "network")
#network=os.system("python /home/pi/myPiProject/editConffile.py /etc/pi-setup/pi.cfg get network network novalue")
print "network:"
print network

# get the stage from the config file
EBENE=editConffile.optionGet(conffile, "common", "stage")
#print "EBENE:"
#print EBENE



# read all ports from the config file, where DHT22 sensors connected
ListOfDht22=editConffile.optionGet(conffile, "things", "dht22")
#ListOfDht22=os.system("editConffile.py /etc/pi-setup/pi.cfg get things dht22 novalue")
print "ListOfDht22:"
print ListOfDht22
# magic conversion of the return value into a real list object
ListOfDht22=ast.literal_eval(ListOfDht22)
sensor = Adafruit_DHT.DHT22
# Zählweise der Pins festlegen
GPIO.setmode(GPIO.BOARD)
# Set all ports as input ports
#for arg in sys.argv[1:]:
for arg in ListOfDht22:
    pin=int(arg)
    print "PIN:"
    print pin
    GPIO.setup(pin, GPIO.IN, pull_up_down = GPIO.PUD_DOWN)
# Schleifenzähler
i = 0
# Eigentlicher Programmablauf
decimal_seconds = 0
while 1:
    time.sleep(1)
    decimal_seconds = decimal_seconds +1
    # Alle 60 Sekunden den Sensor auslesen
    if decimal_seconds >= 10:
        # Für jeden übergebenen Pin (an dem ein Sensor angeschlossen ist)
        #for arg in sys.argv[1:]:
        for arg in ListOfDht22:
            pin = int(arg)
            print "lese Sensor aus"
            # Sensor auslesen
            humidity, temperature = Adafruit_DHT.read_retry(sensor, pin)
            #print "Pin ist:"
            #print pin
            #print "Temperatur ist:"
            #print temperature
            #print "Luftfeuchtigkeit ist:"
            #print humidity
	    #TODO: ersetze IP-Adresse durch Variable network
            #commandString="curl --header \"Content-Type: text/plain\" --request POST --data \"{0}\" http://192.168.0.51:8080/rest/items/Temperatur_E{1}_PIN{2}" .format(temperature, EBENE, pin)
            commandString="curl --header \"Content-Type: text/plain\" --request POST --data \"{0}\" http://192.168.0.90:8080/rest/items/Temperatur_E{1}_PIN{2}" .format(temperature, EBENE, pin)
            #print commandString
            os.system(commandString)
            #commandString="curl --header \"Content-Type: text/plain\" --request POST --data \"{0}\" http://192.168.0.51:8080/rest/items/Feuchtigkeit_E{1}_PIN{2}" .format(humidity, EBENE, pin)
            commandString="curl --header \"Content-Type: text/plain\" --request POST --data \"{0}\" http://192.168.0.90:8080/rest/items/Feuchtigkeit_E{1}_PIN{2}" .format(humidity, EBENE, pin)
            #print commandString
            os.system(commandString)
        decimal_seconds = 0
raw_input("Enter zum Beenden!\n")
