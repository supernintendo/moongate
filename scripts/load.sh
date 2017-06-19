#!/bin/bash
set -e

if [ -z "$ARG2" ]; then
  echo -e "No game directory provided."
  exit
fi

elixir scripts/ensure_moongate_config.exs
echo -e "Loading \033[0;32m${GAME_PATH}\033[0m"
mix clean
elixir scripts/gen_rustler_bridge.exs
iex --dot-iex .iex.moongate.exs -S mix
