#!/bin/bash
set -e

elixir scripts/moongate_config.exs
echo -e "Loading \033[0;32m${GAME_PATH}\033[0m"
mix clean
elixir scripts/gen_rustler_bridge.exs
iex --dot-iex .iex.moongate.exs -S mix
