#!/usr/bin/env python

import socket
import sys
import time

TCP_IP = '127.0.0.1'
TCP_PORT = 2592
BUFFER_SIZE = 1024
MESSAGE = str(sys.argv[1])
PACKET_LENGTH = len(MESSAGE.replace(" ", ""))
PACKET = str(PACKET_LENGTH) + "{" + MESSAGE + "}"

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((TCP_IP, TCP_PORT))
s.send(PACKET)
data = s.recv(BUFFER_SIZE)
s.close()
