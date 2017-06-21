#!/bin/bash

# Prepare environment
export ELIXIR_DIR=${BASE_DIR}/.moongate/elixir/bin
export NODE_DIR=${BASE_DIR}/.moongate/node/bin
export MODIFIED_PATH=${ELIXIR_DIR}:${NODE_DIR}:${PATH}
export GAME_PATH=${2:-games/orbs}
export MOONGATE_GAME=$(basename $GAME_PATH)
export MOONGATE_GAME_PATH=${GAME_PATH}
export PATH=${MODIFIED_PATH}
