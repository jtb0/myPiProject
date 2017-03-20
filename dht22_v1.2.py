#!/usr/bin/env python
#coding: utf8 

###############################################################################
#                                                                             #
# Dieses Skript liest die für den DHT22 verwendeten Pins aus der              #
# Umgebungsvariable DHT22 aus.                                                #
# Stellen Sie sicher, dass diese Variable korrekt gesetzt ist.                #
#                                                                             #
# Beispiel:                                                                   #
# $ echo $DHT22                                                               #
# $ 16:18:22                                                                  #
#                                                                             #
# In diesem Beispiel sind an den (Physical-Zählweise) Pins 16, 18 und 22      #
# Bewegungs-Sensoren angeschlossen. Dies entsprcht:                           #
# Pin 16 = GPIO. 4                                                            #
# Pin 18 = GPIO. 5                                                            #
# Pin 22 = GPIO. 3                                                            #
#                                                                             #
###############################################################################

import time
import os
import sys
import RPi.GPIO as GPIO
import Adafruit_DHT

# Umgebungsvariable EBENE auslesen
EBENE = int(os.environ['EBENE'])

# Alle Pins aus der Umgebungsvariable lesen, an der der DHT22 angeschlossen ist
DHT22 = os.environ['DHT22']
# In eine Liste umwandeln
ListOfDht22 = DHT22.split(":")

sensor = Adafruit_DHT.DHT22
# Zählweise der Pins festlegen
GPIO.setmode(GPIO.BOARD)
# Alle übergebenen Pins als Eingänge festlegen
#for arg in sys.argv[1:]:
for arg in ListOfDht22:
    pin = int(arg)
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
            commandString="curl --header \"Content-Type: text/plain\" --request POST --data \"{0}\" http://192.168.0.90:8080/rest/items/Temperatur_E{1}_PIN{2}" .format(temperature, EBENE, pin)
            #print commandString
            os.system(commandString)
            commandString="curl --header \"Content-Type: text/plain\" --request POST --data \"{0}\" http://192.168.0.90:8080/rest/items/Feuchtigkeit_E{1}_PIN{2}" .format(humidity, EBENE, pin)
            #print commandString
            os.system(commandString)
        decimal_seconds = 0
raw_input("Enter zum Beenden!\n")
