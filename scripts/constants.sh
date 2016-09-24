#!/bin/sh

# Environment
git_source="https://github.com/elixir-lang/elixir.git"
world=$(printenv MOONGATE_WORLD)
elixir_tag=$(head -n 1 priv/common/elixir_tag)
elixir_version=$(head -n 1 priv/common/elixir_version)
declare -a args=($1 $2)

# Colors
beige=$(tput setaf 224)
green=$(tput setaf 64)
gold=$(tput setaf 220)
gray=$(tput setaf 242)
orange=$(tput setaf 172)
magenta=$(tput setaf 89)
normal=$(tput sgr0)
pink=$(tput setaf 171)
purple=$(tput setaf 93)
white=$(tput setaf 231)
