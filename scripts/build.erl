#!/usr/bin/env escript

%%% ---------------------------------------------------
%%%
%%% This script removes build artifacts from the Moongate
%%% application and runs standard Mix build tasks after-,
%%% wards, ensuring that the current project is rebuilt
%%% each time Moongate is run.
%%%
%%% ---------------------------------------------------
%%%

main(_) ->
  lists:map(
    fun({Description, Command}) ->
      io:format("\033[30m" ++ Description ++ " ... \033[0m"),
      os:cmd(Command),
      io:format("\r\033[30m" ++ Description ++ "\033[36m (done)\033[0m~n")
    end,
    [
      {"Cleaning up", "rm -rf _build/dev/lib/moongate"},
      {"Compiling dependencies", "mix deps.compile >/dev/null 2>&1 %"},
      {"Compiling Moongate", "mix compile >/dev/null 2>&1"}
    ]
  ).