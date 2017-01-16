#!/usr/bin/env escript

%%% ---------------------------------------------------
%%%
%%% When this script is run it checks for an installation
%%% of Elixir. If it does not find one or if the currently
%%% installed version is different than the one Moongate
%%% requires, it prompts the user to download the correct
%%% version of Elixir. This downloads a precompiled zip
%%% of the corresponding release from the Elixir GitHub
%%% repo at https://github.com/elixir-lang/elixir. The
%%% binaries are extracted to _moongate/elixir which is
%%% included in the PATH of other scripts in the Moongate
%%% init process.
%%% 
%%% ---------------------------------------------------
%%%

main([Os]) ->
  Version = get_installed_version(),
  Required = get_required_version(),
  case program_exists("elixir", Os) of
    true -> check_version(Version, Required, Os);
    false -> prompt_install(Required, message_not_found(), Os)
  end.

check_version(Version, Required, Os) ->
  Message = message_wrong_version(Version, Required),
  case string:str(Version, Required) =/= 0 of
    true -> halt(0);
    false -> prompt_install(Required, Message, Os)
  end.

prompt_install(Required, Message, Os) ->
  io:format(Message),
  case get_input() of
    true -> install_elixir(Required, Os);
    false -> terminate(message_cancel_no_elixir())
  end.

install_elixir(Version, Os) ->
  Result = {program_exists("curl", Os), program_exists("wget", Os)},

  case Result of
    {_, true} ->
      download_elixir(wget, Version),
      unzip_elixir(Os);
    {true, _} ->
      download_elixir(curl, Version),
      io:format("\033[32mDownloading Elixir " ++ Version ++ "\033[0m~n"),
      unzip_elixir(Os);
    _ ->
    terminate(message_cant_download())
  end,
  io:format(message_post_download(Version)).

download_elixir(Downloader, Version) ->
  io:format("\033[34mDownloading Elixir " ++ Version ++ "\033[0m~n"),
  case Downloader of
    curl -> os:cmd("curl -Lo _moongate/Elixir.zip " ++ elixir_link(Version));
    wget -> os:cmd("wget -O _moongate/Elixir.zip " ++ elixir_link(Version));
    _ -> terminate()
  end.

unzip_elixir(Os) ->
  case Os of
    "win" -> io:format("TODO: Unzip windows");
    _ -> io:format(os:cmd("unzip -qq -o _moongate/Elixir.zip -d _moongate/elixir"))
  end.

terminate() ->
  terminate("\n\033[31mQuitting\n").
terminate(Message) ->
  io:format(Message),
  halt(1).

%
% Utility functions
%

clean_string(String) ->
  re:replace(String, "(^\\s+)|(\\s+$)", "", [global,{return,list}]).

elixir_link(Version) ->
  "https://github.com/elixir-lang/elixir/releases/download/v" ++
  Version ++
  "/Precompiled.zip".

get_input() ->
  case io:fread("[Y/n] ","~s") of
    {ok, Response} -> clean_string(Response) =:= "Y" orelse clean_string(Response) =:= "y";
    _ -> terminate()
  end.

%% Returns `true` if the executable can be found.
program_exists(Program, Os) ->
  case Os of
    "win" -> string:str(os:cmd("where " ++ Program), Program) =/= 0;
    _ -> string:str(os:cmd("which " ++ Program), Program) =/= 0
  end.

%% Reads the required Elixir version number from the
%% priv/metadata/elixir_version file, 
get_required_version() ->
  {ok, File} = file:read_file("priv/metadata/elixir_version"),
  Contents = unicode:characters_to_list(File),
  clean_string(Contents).

%% Reads the currently installed Elixir version number
%% using the `elixir -v` command.
get_installed_version() ->
  [Version | _] = lists:reverse(string:tokens(os:cmd("elixir -v"), " ")),
  clean_string(Version).

% 
% Messages
%

message_cancel_no_elixir() ->
  "\033[31mMoongate needs Elixir but can't find it. Quitting\n".

message_cant_download() ->
  "\033[31mCan't find wget or curl to download Elixir. Check your PATH. Quitting\n".

message_not_found() ->
  "Moongate requires Elixir but it doesn't appear to be installed "   ++
  "(if you think this is wrong, check your PATH variable). Download " ++
  "and install it?".

message_post_download(Version) ->
  {ok, WorkingDir} = file:get_cwd(),

  "\033[32mElixir " ++ Version ++ " installed in " ++ WorkingDir ++ 
  "/_moongate/elixir.\033[0m~n\n".

message_wrong_version(Version, Required) ->
  Message = "\n🔮\033[30m  Moongate requires Elixir version \033[36m"           ++
  Required ++ "\033[30m but you have version \033[36m" ++ Version ++ "\033[30m" ++
  ". \nDownload and install it? This will not modify your existing install. "   ++
  " \nMoongate will setup a local copy of Elixir for its own use.\033[0m~n\n",
  unicode:characters_to_binary(Message).
