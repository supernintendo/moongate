#!/usr/bin/env python
from sys import argv
import socket

IP = '127.0.0.1'
PORT = 2594
SCRIPT, PACKET = argv
PACKET_DELAY = 100000
BUFFER_SIZE = 1024

counter = 0
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

while True:
  counter += 1

  if counter >= PACKET_DELAY:
    outgoing = "anon messages send {}".format(PACKET)
    packet_length = len(outgoing.replace(" ", ""))
    sock.sendto("{}{}{}{}".format(packet_length, "{", outgoing, "}"), (IP, PORT))
    data, addr = sock.recvfrom(BUFFER_SIZE)
    print data
    counter = 0