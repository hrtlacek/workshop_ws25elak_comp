import RPi.GPIO as GPIO
import sys
import time
from pythonosc.udp_client import SimpleUDPClient


GPIO_PIN = 27
IP = '127.0.0.1'
#IP = '192.168.8.104'
PORT = 9006
#ADDR = f'/gpio{GPIO_PIN} '
ADDR = '/test'
dt = 1


#GPIO.setmode(GPIO.BOARD)
GPIO.setmode(GPIO.BCM)

#GPIO.setup(GPIO_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(GPIO_PIN, GPIO.IN)


client = SimpleUDPClient(IP, PORT)

try:
    while True:
        val = GPIO.input(GPIO_PIN)
        print(ADDR)
        print(val)

        client.send_message(ADDR, val)
        time.sleep(dt)
except KeyboardInterrupt:
    GPIO.cleanup()
    print('Exiting.')
    sys.exit()



GPIO.cleanup()
