# myPiProject
Organize a bunch of Raspberry Pis for a home automation.

**-bewegungssensor.py--** <br>
This file setup all the gpios which are assigned to use with motion sensors (e.g. via pi-setup.sh) and add event detection services for each one. Then the script sleeps until a event will rise. Then the event is send via (rest api) curl to the master-pi (where openHAB is running).

**------dht22.py-------**<br>
This file should be started at each pi where the dht22 sensors are attached at gpios.
The script reads all 60 seconds the temperature and humidity and send these information via (rest api) curl to the master-pi (where openHAB is running).

**-----pi-setup.sh-----** <br>
This file helps you to setup all your Pis within the project.<br>
**Features of v1.0.0**
- Change the tier of the device
- setup network
- deactivate DHCPCD
- set alias for ll
- update the software
- perform a systemupdate
- manage DHT22 sensors (humidity and temperature sensors) 
  - automatic installation of necessary software
  - assign gpio pins for the usage with a DHT22
  - remove gpio pins from the usage with a DHT22
- manage motion sensors 
  - assign gpio pins for the usage with a motion sensor
  - remove gpio pins from the usage with a motion sensor
- installation of standard software (at this time only vim) 
- enable syntax highliting for vim

**KNOWN ERRORS**
- Not able to remove the last item of DHT22 and BEWEGUNGSSENSOR

**Comming soon**
- Outsource the password and ssid information from pi-setup.sh file
- Outsource the network information in to an environment variable and make it configurable
- Merge dht22.py and bewegungssensor.py to a pi-slave.py file
- Add further sensors 
