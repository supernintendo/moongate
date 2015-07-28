#!/usr/bin/env python
import socket

TCP_IP = '127.0.0.1'
TCP_PORT = 2593
BUFFER_SIZE = 1024

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((TCP_IP, TCP_PORT))
s.send('begin anon auth login foo bar end')
data = s.recv(BUFFER_SIZE)
print data
s.close()

