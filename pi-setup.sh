#!/bin/bash
DATE=`date +%Y-%m-%d:%H:%M:%S`

# Prüfen, ob bereits eine Einrichtung stattgefunden hat und ob eine Umgebungsvariable EBENE gesetzt ist
EBENE=stage
if ! grep -q $EBENE /etc/pi-setup/pi.cfg
        then # Wenn nein
		echo "System ist noch nicht für eine Ebene eingerichtet"
		initialisiert=false
		echo "initialisiert="$initialisiert>&2
        else
		lade_Konfiguration ${EBENE}
		echo ${WERT}	
		echo 'System ist aktuell für Ebene ' $WERT ' eingerichtet'
		initialisiert=true
		echo "initialisiert="$initialisiert>&2

fi

menue (){
echo "###########################################################################"
echo "#										#"
echo "#                              pi-setup					#"
echo "#										#"
echo "###########################################################################"
echo ""
echo "Um eine konkurrierende Adressvergaben zu vermeiden, wird empfohlen, den DHCP Client Deamon aus zu schalten. Wird dies nicht getan, kann ein Interface mehrere IP-Adressen zugewiesen bekommen. Dies kann zu Problemen führen. Wenn DHCP nicht zwingend benötigt wird, wird empfohlen diesen zu deaktivieren."
echo ""
lade_Konfiguration "stage"
echo "Was soll getan werden?
(e)bene einrichten / ändern
(n)etzwerk einrichten
(d)hcpd deaktivieren
(a)lias ll für ls -l einrichten
System(u)pdate durchführen
(l)uftfeuchte und Temperatursensor einrichten / verwalten
(b)ewegungssensor einrichten / verwalten
(r)elais einrichten / verwalten
(f)irmwareupdate durchführen
Syntax(h)ighliting einschalten
(s)sh einrichten (Zertifikat wird erstellt und Zugriff über Passwort wird verboten)
na(m)e anpassen in pi-e${WERT}
E(x)it:"
read todo

case "$todo" in
        e)
        Ebene_aendern
	;;
	n)
	lade_Konfiguration "stage"
	if [ initialisiert ]; then Netzwerk_Einrichten $WERT; else print "Zuerst muss das System für eine Ebene initialisiert werden!";fi
	;;
	d)
	DHCPCD_deaktivieren
	;;
	a)
        Alias_einrichten
	;;
	u) echo "Aktualisiere die Systemsoftware ..."
	sudo apt-get update && sudo apt-get upgrade -y
	;;
        l) echo "Der DHT22 Sensor (Temperatur und Luftfeuchtesensor) wird eingerichtet..."
	Device_verwalten "dht22" "Temperatur und Luftfeuchtesensor"
	;;
        b) echo "Der Bewegungssensor wird eingerichtet..."
	Device_verwalten "bewegungssensor" ""
	;;
        b) echo "Das Relais wird eingerichtet"
	Device_verwalten "relais" "zum schalten externer Geräte"
	;;
	f) echo "Aktualisiere die Firmware ..."
	Firmwareupdate_einrichten
	;;
	t) echo "Installiere Standardsoftware ..."
	PAKET="vim"
	Paket_installieren $PAKET
	;;
	h) echo "Syntax Highligting für vim wird aktiviert ..."
	vim_syntax_highlight_einschalten
	;;
	s)
	ssh_einrichten
	;;
	m)
	lade_Konfiguration "stage"
	if [ initialisiert ]; then Name_anpassen $WERT; else print "Zuerst muss das System für eine Ebene initialisiert werden!";fi
	;;
	x)
	exit 0
	;;
esac
}
	
#TODO: auf conffile umstellen
Ebene_aendern (){
	echo "Bitte die Ebene des Hauses angeben, in dem der PI verwendet werden soll(für die Zentrale bitte die 9 angeben oder q zum Beenden)"
	read -p " Nummer :" Ebene
	ALL=false

	if [ $initialisiert = true ]
		then
			echo "Eintrag der neuen Ebene wurde in todo  eingetragen"
			#Ersetze die Nummer der Ebene 
			export EBENE=$Ebene
			sed -i 's/EBENE.*$/EBENE='$Ebene'/' /home/pi/.profile
		else
			echo "Eintrag der Ebene wurde in .profile vorgenommen"
			#setze die Nummer der Ebene 
			export EBENE=$Ebene
			#Schreibe den Export in die .profile damit die Variable einen Neustart übersteht
			echo "export EBENE=$Ebene" >> /home/pi/.profile
	fi
}

Paket_installieren (){
PAKET=$1
if dpkg-query -s $1 2>/dev/null|grep -q installed; then
   	echo "$PAKET ist bereits installiert"
else
     	echo "$PAKET wird installiert"
	sudo apt-get install -y $PAKET
fi
}


vim_syntax_highlight_einschalten (){
echo "Syntax Highliting wird eingeschaltet ..."
Text='
syntax on \n
 \n
colorscheme ron \n'
echo 
echo $Text > /home/pi/.vimrc

#sudo cp /usr/share/vim/vimrc /usr/share/vim/vimrc-$DATE.orig
#echo "die original Datei wurde unter folgendem Namen gespeichert: /usr/share/vim/vimrc-${DATE}.orig"
#sudo sed -i 's/"syntax on.*$/syntax on$/' /usr/share/vim/vimrc
#sudo sed -i 's/"set background=dark.*$/set background=dark/' /usr/share/vim/vimrc
}


ssh_einrichten (){
echo "ssh wird eingerichtet ..."
PAKET="openssh-server"
Paket_installieren $PAKET

# Prüfen, ob ein Privater Schlüssel vorhanden ist
if [ ! -f /home/pi/.ssh/id_rsa ] 
	then
		# Wenn nicht wird Schlüssel erzeugt
		echo "Schlüssel wird erzeugt"
		ssh-keygen -t rsa -b 4096
	else
		echo "es existiert bereits ein privater Schlüssel. Dieser wid verwendet"
fi
# Zur Sicherheit noch Passwortauthentifizierung ausschalten
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config-$DATE.orig
echo "die original Datei wurde unter folgendem Namen gespeichert: /etc/ssh/sshd_config-${DATE}.orig"

sudo sed -i 's/#PasswordAuthentication yes$/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication yes$/PasswordAuthentication no/' /etc/ssh/sshd_config

# IP Adresse ermitteln
ipaddress=$(/sbin/ip -4 -o addr show scope global | awk '{gsub(/\/.*/,"",$4); print $4}')
echo "bitte jetzt vom Client aus folgenden Befehl ausführen \n sudo ssh-copy-id -i ~/.ssh/id_rsa.pub $USER@$ipaddress"
read -p "ist dies erfolgt? Dann wird jetzt der ssh Dienst neu gestartet [y/n]: " sshdrestart
if ["$sshdrestart"="y"]
	then service ssh restart
fi
}


Alias_einrichten (){
echo "Alias ll wird eingerichtet ..."
sudo cp /home/pi/.bashrc /home/pi/.bashrc-$DATE.orig
# in der .bashrc den ll alias einrichten
sed -i "s/#alias ll=.*$/alias ll='ls -l'/" /home/pi/.bashrc
}


Firmwareupdate_einrichten (){
echo "Firmwareupdate wird durchgeführt ..."
PAKET="git"
Paket_installieren $PAKET

if [ ! -f /usr/bin/rpi-update ]
	then 
		sudo wget https://raw.github.com/Hexxeh/rpi-update/master/rpi-update -O /usr/bin/rpi-update && sudo chmod +x /usr/bin/rpi-update
	else echo "rpi-update ist bereits installiert"
fi
echo "Führe rpi-update aus..."
# Zum Testen auskommentieren
sudo rpi-update
}


Name_anpassen (){
echo "Name des Pi wird angepasst ..."
sudo cp /etc/hostname /etc/hostname-$DATE.orig
echo "die original Datei wurde unter folgendem Namen gespeichert: /etc/hostname-${DATE}.orig"
# sudo echo Lösung 
sudo bash -c 'echo "pi-e'$1'" >/etc/hostname'
sudo hostname -F /etc/hostname
sudo cp /etc/hosts /etc/hosts-$DATE.orig
echo "die original Datei wurde unter folgendem Namen gespeichert: /etc/hosts-${DATE}.orig"
sudo sed -i "s/127.0.1.1.*$/127.0.1.1	pi-e${EBENE}/" /etc/hosts
}


Netzwerk_Einrichten () {
echo "Das Netzwerk wird eingerichtet ..."
sudo mv /etc/network/interfaces /etc/network/interfaces-$DATE.orig
echo "Lade Config File..." >&2
source /etc/pi-setup/pi.cfg
SSID=$wpa_ssid >&2
PSK=$wpa_psk >&2
NETZWERK=$network >&2
Text='
source-directory /etc/network/interfaces.d \n
 \n
auto lo \n
 \n
iface lo inet loopback\n
# WLAN\n
#allow-hotplug wlan0\n
auto wlan0\n
iface wlan0 inet static\n
wpa-ssid "'$SSID'"\n
wpa-psk "'$PSK'"\n
address '$NETZWERK''$1'1\n
netmask 255.255.255.0\n
gateway '$NETZWERK'1\n
dns-nameservers '$NETZWERK'1\n
\n
# Ethernet\n
auto eth0\n
allow-hotplug eth0\n
iface eth0 inet static\n
address '$NETZWERK''$1'0\n
netmask 255.255.255.0\n
gateway '$NETZWERK'1\n
dns-nameservers '$NETZWERK'1\n
' 
sudo echo -e $Text | sudo tee -a /etc/network/interfaces
}


DHCPCD_deaktivieren (){
echo "DHCPCD wird gestoppt ..."
sudo systemctl stop dhcpcd
sudo systemctl disable dhcpcd
echo "Netzwerk wird neu gestartet ..."
echo "... gleich geht es weiter ..."
sudo service networking restart
}


Device_verwalten () {
DHT22_installieren
DEVICE=$1
DETAIL=$2
# Prüft, ob ein Eintrag für das Device existiert
if ! grep -q $DEVICE /etc/pi-setup/pi.cfg
        then # Wenn nein
                echo "Die Variable existiert nicht. Es ist kein Pin ${DEVICE} ${DETAILS} zugeordnet."
        else
		echo "Aktuell sind folgende Pins für den Gebrauch mit einem ${DEVICE} ${DETAILS} eingerichtet:"
		lade_Konfiguration ${DEVICE}
		echo ${WERT}	
fi

read -p "Möchten Sie (n)eue $DEVICE hinzufügen, vorhandene (e)ntfernen oder (z)urück?: " todo
case "$todo" in
        n)
        Pin_belegen $DEVICE
        ;;
	e)
        Pin_entfernen $DEVICE
	;;
	z)
	menue
	;;
esac
}


lade_Konfiguration (){
VARIABLE=$1
echo "Lade Config File..." >&2
source /etc/pi-setup/pi.cfg
# Bereits eingetragene Pins auslesen
WERT=${!VARIABLE} >&2
}


Pin_entfernen (){
DEVICE=$1
#Neustart_notwendig
# Prüft, ob ein Eintrag für das Device existiert
#TODO LEERE prüfung ist noch an zu passen
if ! grep -q $DEVICE /etc/pi-setup/pi.cfg
        then # Wenn nein
                echo "Die Variable existiert nicht. Es ist kein Pin ${DEVICE} zugeordnet."
        else
		lade_Konfiguration ${DEVICE}
		read -p "Welcher Pin soll aus der Liste entfernt werden (Physikalische Notation) ?" pin
		# Inhalt in eine Datei schreiben
		echo ${WERT} > old
		# Nach der <pinnummer> als erster Wert suchen und löschen oder ...
		sed "s/^$pin://"< old>new
		cp new old
		# ... nach :<pinnummer> in der mitte suchen und löschen oder ...
		sed "s/:$pin:/:/"< old>new
		# ... wenn nur ein Eintrag vorhanden ist oder ...
		sed "s/^$pin$//"< old>new
		# ... nach der <pinnummer> als letzten Wert suchen und löschen
		sed "s/:$pin$//"< old>new
		# Neuer Wert aus Datei in das config File schreiben
		text="${DEVICE}=$(cat new)"
                # Ersetzt die Variable durch den geänderten Eintrag
		sudo sed -i 's/'$DEVICE'.*$/'$DEVICE'='$(cat new)'/' /etc/pi-setup/pi.cfg
		rm old, new
fi
}


Neustart_notwendig (){
echo ""
echo ""
echo "###########################################################################"
echo "#										#"
echo "# 			    Achtung!!!					#" 
echo "#      Diese Änderungen werden erst nach einem Neustart wirksam!        	#"
echo "#										#"
echo "###########################################################################"
echo ""
echo ""
}


Pin_belegen (){
DEVICE=$1
#Neustart_notwendig
read -p "An welchen Pin soll das neue Gerät angeschlossen werden (Physikalische Notation) ?" pin
# Prüft, ob ein Eintrag für das Device existiert
if ! grep -q $DEVICE /etc/pi-setup/pi.cfg
        then # Wenn nein
		echo "Es wurde Pin $pin nun der Verwendung als Gerät $DEVICE zugewiesen"
		# Hängt das neue Device mit dem zugewiesenen Pin an die Config-Datei an
		
		sudo bash -c 'echo "'${DEVICE}'='$pin'" >> /etc/pi-setup/pi.cfg'
        else
		lade_Konfiguration ${DEVICE}
		#echo "Lade Config File..." >&2
		#source /etc/pi-setup/pi.cfg
		## Bereits eingetragene Pins auslesen
		#LISTE=${!DEVICE} >&2
		# Neunen Pin durch : getrennt anhängen
		LISTE="$WERT:$pin"
		echo $LISTE
		echo "Es wurde Pin $pin nun der Verwendung als Gerät $DEVICE zugewiesen"
		echo "Aktuell sind folgende Pins duch das Gerät $DEVICE in Verwendung:"
		echo "$LISTE"
		# Die erweitere Liste in Config-Datei schreiben
		sudo sed -i 's/'$DEVICE'.*$/'$DEVICE'='$LISTE'/' /etc/pi-setup/pi.cfg
fi
}



# Auskommentierte Version, die die Umgebungsvariable nutzt
#Pin_belegen (){
#UVAR=$1
#Neustart_notwendig
#read -p "An welchen Pin soll das neue Gerät angeschlossen werden (Physikalische Notation) ?" pin
#if [ -z "${!UVAR}" ]
#        then
#		text="${UVAR}=$pin"
#		export $text
#		#export $UVAR="$pin"
#		echo "Es wurde Pin $pin nun der Verwendung als Gerät $UVAR zugewiesen"
#		#echo "export $UVAR=${!UVAR}" >> /home/pi/.profile
#		echo "export $text" >> /home/pi/.profile
#        else
#		text="${UVAR}=${!UVAR}:$pin"
#		echo $text
#		export $text
#		echo "Es wurde Pin $pin nun der Verwendung als Gerät $UVAR zugewiesen"
#		echo "Aktuell sind folgende Pins duch das Gerät $UVAR in Verwendung:"
#		echo "${!UVAR}"
#		echo "Eintrag wurde in .profile eingetragen"
#                # Ersetzt die Variable durch den geänderten Eintrag
#		sed -i 's/'$UVAR'.*$/'$text'/' /home/pi/.profile
#fi
## Dafür sorgen, dass geänderte Umgebungsvariable in der aktuellen Sitzung bekannt sind
#source ~/.profile
#}

DHT22_installieren () {
echo "DHT22 wird installiert ..."
PAKET="build-essential"
Paket_installieren $PAKET
PAKET="python-dev"
Paket_installieren $PAKET
PAKET="python-openssl"
Paket_installieren $PAKET
PAKET="git"
Paket_installieren $PAKET
# Wenn die Datei bereits vorhanden ist, wird nicht neu ausgecheckt
if [ -f ~/Adafruit_Python_DHT/examples/AdafruitDHT.py ]
	then
		echo "Adafruit_Python_DHT bereits installiert"
	else
		git clone https://github.com/adafruit/Adafruit_Python_DHT.git && cd Adafruit_Python_DHT
		sudo python setup.py install
fi

echo "-----------------INFO-----------------"
echo "getestet werden kann der Sensor mit folgendem Aufruf:"
echo ""
echo "sudo ~/Adafruit_Python_DHT/examples/AdafruitDHT.py 22 4"
echo ""
echo "Wobei die 4 auf die Nummer des verwendeten PINs geändert werden muss"
echo "---------------INFO-ENDE--------------"
}



# Verbleibt dauerhaft im Menü, bis beendet wird
while true; do menue; sleep 1; done

