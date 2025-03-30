import sys
import time
from pythonosc.udp_client import SimpleUDPClient

IP = '127.0.0.1'
PORT = 9006
ADDR = '/gpio27'

dt = 0.5
client = SimpleUDPClient(IP, PORT)

try:
	while True:
		val = 5
		client.send_message(ADDR, val)
		time.sleep(dt)
		print('sent')
except KeyboardInterrupt:

	print('\nExiting.\n')
	sys.exit()
