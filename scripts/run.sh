#!/bin/sh

MOONGATE_WORLD=$1 iex -S mix
mix moongate.kill_external_pids $1