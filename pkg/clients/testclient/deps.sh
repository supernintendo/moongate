#!/bin/bash

command -v luarocks-5.1 >/dev/null 2>&1 || {
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