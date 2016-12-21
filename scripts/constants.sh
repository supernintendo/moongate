#!/bin/sh

# Environment
git_source="https://github.com/elixir-lang/elixir.git"
world=$(printenv MOONGATE_WORLD)
elixir_tag=$(head -n 1 priv/metadata/elixir_tag)
elixir_version=$(head -n 1 priv/metadata/elixir_version)
declare -a args=($1 $2)

# Colors
beige=$(tput setaf 224)
blue=$(tput setaf 5)
dark=$(tput setaf 240)
green=$(tput setaf 64)
gold=$(tput setaf 220)
gray=$(tput setaf 242)
orange=$(tput setaf 172)
magenta=$(tput setaf 89)
normal=$(tput sgr0)
pink=$(tput setaf 171)
purple=$(tput setaf 93)
white=$(tput setaf 231)

if [ "$(uname)" == "Darwin" ]; then
  os="darwin"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  os="linux"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
  os="win"
elif [ "$(uname)" == "FreeBSD" ]; then
  os="freebsd"
elif [ "$(uname)" == "OpenBSD" ]; then
  os="openbsd"
elif [ "$(uname)" == "NetBSD" ]; then
  os="netbsd"
fi

if [ "$(uname -m)" == "x86_64" ]; then
  arch="amd64"
else
  arch="386"
fi