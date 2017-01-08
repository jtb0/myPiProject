#!/usr/bin/env python
#coding: utf8 

###############################################################################
#                                                                             #
# Dieses Skript wird aufgerufen mit der Übergabe der Parameter.               #
# In Diesem Fall sind die Parameter alle Pins, an denen ein Bewegungs-Sensor  #
# angeschlossen wurde.                                                        #
#                                                                             #
# Beispiel:                                                                   #
# $ ./dht22.py 16 18 22                                                       #
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

# Umgebungsvariable EBENE auslesen
EBENE = int(os.environ['EBENE'])
# Zählweise der Pins festlegen (physikalische Zählweise)
GPIO.setmode(GPIO.BOARD)

# Alle Pins aus der Umgebungsvariable lesen, an der der Bewegunssensor angeschlossen ist
BEWEGUNGSSENSOR = os.environ['BEWEGUNGSSENSOR']
# In eine Liste umwandeln
ListOfSensor = BEWEGUNGSSENSOR.split(":")

# Alle übergebenen Pins als Eingänge festlegen
#for arg in sys.argv[1:]:
for arg in ListOfSensor:
    pin = int(arg)
    GPIO.setup(pin, GPIO.IN, pull_up_down = GPIO.PUD_DOWN)

# Methode deklarieren, falls ein Event auftritt
def doIfHigh(channel):
    # Zugriff auf Variable i ermögliche
    global i
    if GPIO.input(channel) == GPIO.HIGH:
        commandString="curl --header \"Content-Type: text/plain\" --request POST --data \"ON\" http://192.168.0.90:8080/rest/items/Bewegung_E{0}_PIN{1}" .format(EBENE, pin)
        # Wenn Eingang HIGH ist, Ausgabe im Terminal erzeugen
        print "Eingang HIGH " + str(i)
        print commandString
        os.system(commandString)
    else:
        commandString="curl --header \"Content-Type: text/plain\" --request POST --data \"OFF\" http://192.168.0.90:8080/rest/items/Bewegung_E{0}_PIN{1}" .format(EBENE, pin)
        # Wenn Eingang LOW ist, Ausgabe im Terminal erzeugen
        print "Eingang LOW " + str(i)
        print commandString
        os.system(commandString)
        # Schleifenzähler erhöhen
        i = i + 1

# Alle Pins in der Liste ...
#for arg in sys.argv[1:]:
for arg in ListOfSensor:
    pin = int(arg) 
    print "Pin: {0}" .format(pin)
    # ... als Eingänge festlegen
    GPIO.setup(pin, GPIO.IN, pull_up_down = GPIO.PUD_DOWN)
    #GPIO.setup(4, GPIO.IN, pull_up_down = GPIO.PUD_DOWN)
    # ... ein Ereignis deklarieren
    GPIO.add_event_detect(pin, GPIO.BOTH, callback = doIfHigh, bouncetime = 500)
    #GPIO.add_event_detect(4, GPIO.BOTH, callback = doIfHigh, bouncetime = 500)

# Schleifenzähler
i = 0
# Eigentlicher Programmablauf
decimal_seconds = 0
while 1:
    time.sleep(0.1)
raw_input("Enter zum Beenden!\n")
