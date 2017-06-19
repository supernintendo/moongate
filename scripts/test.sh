#!/bin/bash
set -e

MIX_ENV=test mix clean

if [ -z "$ARG2" ]; then
  MIX_ENV=test mix test
else
  MIX_ENV=test mix test $ARG2
fi
