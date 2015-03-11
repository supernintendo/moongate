#!/bin/bash
if [ -d "deps" ]; then
  rm -rf deps
fi

mkdir deps
cd deps
git clone https://github.com/LuaDist/dkjson.git
git clone https://github.com/kikito/inspect.lua.git inspect
git clone https://github.com/kikito/middleclass.git
luarocks install luasocket
cd ..