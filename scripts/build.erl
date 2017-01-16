#!/usr/bin/env escript

main(_) ->
  io:format("\033[30mCleaning up\033[0m"),
  os:cmd("rm -rf _build/dev/lib/moongate"),
  io:format("\033[30m\rCleaning up \033[36m(done)\033[0m~n"),
  io:format("\033[30mCompiling dependencies\033[0m"),
  os:cmd("mix deps.compile >/dev/null 2>&1 %"),
  io:format("\033[30m\rCompiling dependencies \033[36m(done)\033[0m~n"),
  io:format("\033[30mCompiling Moongate\033[0m"),
  io:format("\033[30m\rCompiling Moongate \033[36m(done)\033[0m~n"),
  os:cmd("mix compile >/dev/null 2>&1").
