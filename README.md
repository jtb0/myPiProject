# myPiProject
Organize a bunch of Raspberry Pis for a home automation.
<img src=http://52.59.16.91:8080/wp-content/uploads/2017/01/The-Pi-Project.png alt="The-Pi-Project" style="width:200px;height:228px;">
<br>
**HOW TO START**<br>
Copy the pi.cfg to /etc/pi-setup/ or change the pi.cfg location in the pi-setup.sh (line 3).<br>

**-bewegungssensor.py--** <br>
This file setup all the gpios which are assigned to use with motion sensors (e.g. via pi-setup.sh) and add event detection services for each one. Then the script sleeps until a event will rise. Then the event is send via (rest api) curl to the master-pi (where openHAB is running).

**------dht22.py-------**<br>
This file should be started at each pi where the dht22 sensors are attached at gpios.
The script reads all 60 seconds the temperature and humidity and send these information via (rest api) curl to the master-pi (where openHAB is running).

**-----pi-setup.sh-----** <br>
This file helps you to setup all your Pis within the project.<br>
**Features**
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
- manage relais
  - assign gpio pins for the usage with a relais
  - remove gpio pins from the usage with a relais
- installation of standard software (at this time only vim) 
- enable syntax highliting for vim

**KNOWN ERRORS**
- No Known Errors

**Comming soon**
- Merge dht22.py and bewegungssensor.py to a pi-slave.py file
- Add further sensors 
