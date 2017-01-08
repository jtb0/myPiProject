# myPiProject
Organize a bunch of Raspberry Pis for a home automation.


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
