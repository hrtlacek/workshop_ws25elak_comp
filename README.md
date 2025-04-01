# Raspi

- .ssh/config : 
`Host elakpi
    HostName ipaddr
    User elak
`

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

## PD
install libraries via `sudo apt-get install pd-..`
We need:
- iemnet
- osc

They will be installed in `/usr/lib/pd/extra`.
We need to include them and start pd via:
`pd -nogui -path /usr/lib/pd/extra/iemnet -path /usr/lib/pd/extra/osc localTest.pd`


## WDF/FAUST
faust insatllieren. Die lib in apt ist aber veraltet. Wir kopieren via wget die aktuelle version nach `/usr/share/faust`

## I2C
PIN 3 (SDA)
PIN 5 (SCL)

## Ardiono MIDI
https://www.youtube.com/watch?v=IwfycC8rLos
https://github.com/silveirago/DIY-Midi-Controller/blob/master/Code%20-%20c%C3%B3digo/en-DIY_midi_controller/en-DIY_midi_controller.ino
