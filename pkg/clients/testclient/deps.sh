#!/bin/bash
function prompt_for_luarocks () {
  read response
  if echo "$response" | grep -iq "^y" ;then
    rm -rf _temp
    mkdir _temp
    cd _temp
    git clone git://github.com/keplerproject/luarocks.git
    cd luarocks
    ./configure --prefix="${HOME}/.luarocks51" --lua-suffix=5.1
    make
    make install
    cd ../..
    rm -rf _temp
  elif echo "$response" | grep -iq "^n" ;then
    echo "luarocks-5.1 was not found. If this version of luarocks is installed, you may need to alias it to luarocks-5.1. Aborting..."
    exit 0
  else
    echo "Plese answer y or n."
    prompt_for_luarocks
  fi
}

command -v luarocks-5.1 >/dev/null 2>&1 || {
  echo -n "luarocks-5.1 is required but was not found. Would you like to download and install it? (y/n) "
  prompt_for_luarocks
}

export PATH=$PATH:~/.luarocks/bin:~/.luarocks51/bin
export LUA_CPATH=";;${HOME}/.luarocks51/lib/lua/5.1/?.so"
export LUA_PATH=";;${HOME}/.luarocks51/share/lua/5.1/?.lua;${HOME}/.luarocks51/share/lua/5.1/?/init.lua"
export LUA_CPATH_5_2=";;${HOME}/.luarocks/lib/lua/5.2/?.so"
export LUA_PATH_5_2=";;${HOME}/.luarocks/share/lua/5.2/?.lua;${HOME}/.luarocks/share/lua/5.2/?/init.lua"
luarocks-5.1 install dkjson
luarocks-5.1 install inspect
luarocks-5.1 install middleclass
luarocks-5.1 install luasocket