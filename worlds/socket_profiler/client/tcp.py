#!/usr/bin/env python
from sys import argv
import socket

TCP_IP = '127.0.0.1'
TCP_PORT = 2593
BUFFER_SIZE = 1024
SCRIPT, PACKET = argv
PACKET_DELAY = 100000

counter = 0
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((TCP_IP, TCP_PORT))

while True:
  counter += 1

  if counter >= PACKET_DELAY:
    s.send('begin anon messages send %s end' % PACKET)
    data = s.recv(BUFFER_SIZE)
    print data
    counter = 0

s.close()

