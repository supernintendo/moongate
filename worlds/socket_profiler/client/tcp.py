#!/usr/bin/env python
from sys import argv
import socket

IP = '127.0.0.1'
PORT = 2593
SCRIPT, PACKET = argv
PACKET_DELAY = 100000
BUFFER_SIZE = 1024

counter = 0
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((IP, PORT))

while True:
  counter += 1

  if counter >= PACKET_DELAY:
    outgoing = "anon messages send {}".format(PACKET)
    packet_length = len(outgoing.replace(" ", ""))
    sock.send("{}{}{}{}".format(packet_length, "{", outgoing, "}"))
    data = sock.recv(BUFFER_SIZE)
    print data
    counter = 0

sock.close()

