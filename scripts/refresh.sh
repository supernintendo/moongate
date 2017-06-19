#!/bin/bash
set -e

elixir scripts/ensure_moongate_config.exs
mix do clean, deps.get
elixir scripts/gen_rustler_bridge.exs

echo ""
echo -e "🔮 \033[0;33m Moongate is ready to use!\033[0m"
echo ""
