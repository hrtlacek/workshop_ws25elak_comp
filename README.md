# Überblick

## Verbindungsaufbau
- Wir haben uns mit dem Raspberry pi netzwerkmässig physisch verbunden (kabel zum router, macbook mit wifi von router verbunden).
- Wir haben die IP adresse bzw 'hostname' von unserm jeweiligen raspi herausgefunden um mit ihm 'sprechen' zu können. Zuhause könnt ihr das im Admin interface von eurem router irgendwie finden, bzw man kann auch einfach das eigene netzwerk scannen um zu sehen wer da ist (zb mit `nmap`). Alternativ könnte man keyboard und bildschirm anschließen an den raspi und dort im terminal seine IP herausfinden (`ip addr` wäre ein kommando um auf unix systemen die eigene IP im netzwerk herauszufinden).
- Wir haben beschlossen den raspi via `ssh` zu steuern und dateien via `samba` zu übertragen. Den grossteil haben wir schon letzten workshop erledigt (ssh keys erzeugen und übertragen) und einiges war schon von thomas vorkonfiguriert auf den raspi images (samba service). Ich hab auf meinem computer `scp` für dateitransfer verwendet um dateien via ssh zu übertragen (hauptsächlich aus Faulheit mich mit samba auf meinem linux rechner zu beschäftigen).
## Projekt
### Entwurf
- Wir haben beschlossen, wir möchten gerne einen `pd` patch haben der durch *GPIOs* gesteuert wird.
- Wir haben uns entschieden, das auslesen der GPIOs via `python` zu machen und die kommunikation zu `pd` via `OSC` zu lösen.
### Lokale Tests
- Bevor wir auf den raspi siedeln haben wir alles nicht-GPIO abhängige mal auf unserem laptop entworfen und getestet da wir da besser sehen können ob alles funktioniert.
- Wir mussten eine kleine library in python installieren zu OSC kommunikation. Wir haben das per `pip install python-osc` gemacht, eine kurze internet recherche hätte uns schnell an diesen punkt gebracht. Um unsere python versionen und pakete nicht ständig kaputt zu machen durch versionskonflikte oder ähnliches haben wir uns entschieden ein sogenanntes `virtual environment` für unser Projekt zu verwenden. Wir haben das gemacht via `python -m venv .`
- Wir haben ein `.py` file angelegt und ein script geschrieben das (pseudo-)Zufallswerte erzeugt und über OSC lokal verschickt. (lokal = zb von einem programm zum anderen, auf dem selben computer).
- in pd haben wir `[netreceive -u -b 9000]` verwendet um binary (`-b`) nachrichten über das UDP Protokoll (`-u`) am Port 9000 zu empfangen und `[oscparse]` verwendet um in weiterer folge adresse (`/test`) von werten trennen zu können. (Im unterricht hab ich gesagt ich hätte das anders gemacht, ich hab nachgeschaut: `[udpreceive]` und `[unpackosc]` habe ich verwendet. Diese objekte muss man aber zusätzlich installieren.)

### Auf dem Raspi
Nachdem all das funktioniert hat sind wir auf den Raspi 'gesiedelt'. Wir mussten:
- Den restlichen code für GPIO auslesen einfügen.
- unser script und pd patch auf den raspi schicken (wenn wir nicht schon über samba auf dem raspi gearbeitet haben)
- auch auf dem raspi das virtual environment anlegen (und aktivieren! via `. /bin/activate` im entsprechenden folder)und benötigte pakete installieren (python-osc und evtl GPIO)
- Wir haben überprüft welche GPIO pins verfügbar sind und einen nicht-verwendeten in unserem script benutzt.
- Wir haben in python den ausgelesenen wert geprintet und mit einem kabel eine verbindung zu ground hergestellt. (Da wir einen sog. *pullup* widerstand verwendet haben hat unser python script immer `1` ausgespuckt. Wenn wir unseren GPIO mit *ground* verbunden haben haben wir in python `0` gesehen).
- Nun standen wir noch vor der herausforderung dass pd schon lief und auch im falle eines crashes automatisch wieder gestartet wurde da thomas das so koniguriert hatte. (überprüfen von crashes und automatoscher neustart sehr empfehlenswert bei installationen). Wir hatten einige optionen dieses Problem zu umgehen, haben uns (ich hatte hier keinen überblick) denke ich dazu entschieden die entsprechende zeile aus dem `config` file auszukommentieren und den raspi neuzustarten. 


## Python und pd parallel

Wir haben uns entschieden `byobu` zu verwenden um komfortabel mehere 'fenster' in unseren raspi zu bekommen. Es gibt auch hier zahlreiche varianten das zu machen, `byobu` ist eine sehr freundliche variante, `screen` und `tmux` sind sehr verbreitet wobei sich `screen` besonders anbietet, da es schon auf dem image in verwendung ist.

Um pd zu starten haben wir im terminal `pd meinfile.pd` geschrieben. Da wir kein graphisches user interface (GUI) haben, mussten wir die `-nogui` flag verwenden. `pd -help` zeigt uns alle optionen an die wir steuern können, zb welche soundkarte verwendet wird, ob wir audio inputs deaktivieren wollen (`-noadc`) und ähnliches. 

## Allgemein parktische/wichtige Linux Commands
- `cd`, change directory um in ein anderes verzeichnis zu wechseln.
- `pwd`, print working directory. In welchem verzeichnis bin ich gerade?
- `ls`, list directory(vermutlich). Zeigt den inhalt des aktuellen verzeichnisses.
- `mkdir bla` make directory. Macht einen neuen Ordner mit dem namen 'bla'.
- `cat meinfile.txt` zeigt den inhalt eines files als text an.
- `nano meinfile.txt` nano ist einer der vielen texteditoren. Lässt uns das file `meinfile.txt` editieren. 
- `htop` und `top` ein commandline 'performance monitor'. zeigt uns cpu auslastung, prozesse etc an.



## Pisound 

### Unused GPIO:
https://blokas.io/pisound/docs/general-specifications/
BOARD NUMBERS: 8,10,16,26,3,5,7,13,15,29,31

Pinout:
BOARD NUMNERS: 3,5,6,7,8,9,10

BCM NUMBERS: 7, 5, 6, 22, 23, 27, 4, 15, 14


use: `sudo cat /sys/kernel/debug/gpio` to see what GPIO pins are alrteady in use.


### OSC Sending
`pip install python-osc`

### Debugging 
`nc -ul 9000` (9000 = example port)


### Example Script to read a GPIO pin:

```python
import RPi.GPIO as GPIO
import sys
import time
from pythonosc.udp_client import SimpleUDPClient


GPIO_PIN = 27 #BCM 27, 9 on pinout of pysound.
IP = '127.0.0.1'
PORT = 8000
ADDR = f'/gpio{GPIO_PIN}'

dt = 0.5


#GPIO.setmode(GPIO.BOARD)
GPIO.setmode(GPIO.BCM)

#GPIO.setup(GPIO_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(GPIO_PIN, GPIO.IN)


client = SimpleUDPClient(IP, PORT)

try:
    while True:
        val = GPIO.input(GPIO_PIN)
        #print(ADDR)
        print(val)

        client.send_message(ADDR, val)
        time.sleep(dt)
except KeyboardInterrupt:
    GPIO.cleanup()
    print('Exiting.')
    sys.exit()



GPIO.cleanup()
```

# Random Other notes

# ssh config Beispiel

- .ssh/config : 
`Host elakpi
    HostName ipaddr
    User elak
`


## PD
Für `[oscunpack]` und `[udpreceive]`:

 install libraries via `sudo apt-get install pd-..`
- iemnet
- osc

They will be installed in `/usr/lib/pd/extra`.
We need to include them and start pd via:
`pd -nogui -path /usr/lib/pd/extra/iemnet -path /usr/lib/pd/extra/osc localTest.pd`


## WDF/FAUST
faust insatllieren. Die lib in apt ist aber veraltet. Wir kopieren via wget die aktuelle version nach `/usr/share/faust`


## Ardiono MIDI Controller
https://www.youtube.com/watch?v=IwfycC8rLos
https://github.com/silveirago/DIY-Midi-Controller/blob/master/Code%20-%20c%C3%B3digo/en-DIY_midi_controller/en-DIY_midi_controller.ino
