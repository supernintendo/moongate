#!/bin/bash

counter=0
def_host=localhost
def_port=2599

HOST=${2:-$def_host}
PORT=${3:-$def_port}

while true; do
  echo "Sending message: $1 $counter"
  echo -n "$1 $counter" | nc -4u -w1 $HOST $PORT
  counter=$((counter + 1))
done
