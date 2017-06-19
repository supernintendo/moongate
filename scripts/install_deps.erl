#!/usr/bin/env escript

%%% ---------------------------------------------------
%%%
%%% TODO: description here
%%%
%%% ---------------------------------------------------
%%%

main(_) ->
  mkdir(".moongate"),
  lists:map(fun(Dep) ->
    prompt_install_if_needed(Dep) end,
  deps()).

prompt_install_if_needed({Program, SkipVersionCheck, Link}) ->
  RequiredVersion = get_required_version(Program),

  case program_exists(Program) of
    true -> check_version(Program, SkipVersionCheck, RequiredVersion, Link);
    false -> prompt_install(Program, RequiredVersion, message_not_found(Program), Link)
  end.

check_version(Program, SkipVersionCheck, RequiredVersion, Link) ->
  Version = get_version(Program),
  VersionMatch = (string:str(Version, RequiredVersion) =/= 0),

  case (SkipVersionCheck orelse VersionMatch) of
    true -> ok;
    false ->
      Message = message_wrong_version(Program, Version, RequiredVersion),
      prompt_install(Program, RequiredVersion, Message, Link)
  end.

prompt_install(Program, Version, Message, Link) ->
  io:format(Message),

  case get_input() of
    true -> install(Program, Version);
    false -> terminate(message_cancel_refuse_install(Program, Version, Link))
  end.

install(Program, Version) ->
  Compatibility = {program_exists("curl"), program_exists("wget")},
  {Path, Filename} = download_args(Program, Version),

  case Compatibility of
    {_, true} ->
      download(wget, Path, Filename),
      setup(Program, Filename);
    {true, _} ->
      download(curl, Path, Filename),
      setup(Program, Filename);
    _ ->
      terminate(message_cant_download())
  end,
  io:format(message_post_install(Program, Version)).

download(Downloader, DownloadPath, Filename) ->
  io:format(["\033[34mDownloading ", DownloadPath, "\033[0m\n"]),
  case Downloader of
    curl -> external_cmd(["curl -Lo ", root_dir(), ".moongate/", Filename, " ", DownloadPath]);
    wget -> external_cmd(["wget -O ", root_dir(), ".moongate/", Filename, " ", DownloadPath]);
    _ -> terminate()
  end.

uncompress_archive(Path, Destination, ArchiveType) ->
  case {os:type(), ArchiveType} of
    {{win32, nt}, ".zip"} ->
      % TODO - support win32
      terminate();
    {{unix, _}, ".zip"} ->
      external_cmd([
        "unzip -qq -o ",
        root_dir(),
        Path,
        " -d ",
        Destination
      ]);
    {{unix, _}, ".gz"} ->
      external_cmd([
        "tar -xf ",
        root_dir(),
        Path,
        " -C ",
        Destination
      ]);
    _ ->
      terminate()
  end.

external_cmd(Cmd) ->
  Opt = [stream, exit_status, use_stdio,
          stderr_to_stdout, in, eof],
  P = open_port({spawn, Cmd}, Opt),
  get_data(P, []).

get_data(P, D) ->
  receive
    {P, {data, D1}} ->
      io:format(D1),
      get_data(P, [D|D1]);
    {P, eof} ->
      port_close(P),
      receive
        {P, {exit_status, N}} ->
        {N, lists:reverse(D)}
      end
  end.

% %%%
% %%% Dependency resolution
% %%%

deps() ->
  [
    {"elixir", false, "http://elixir-lang.org"},
    {"rustc", true, "http://elixir-lang.org"},
    {"node", false, "https://nodejs.org/en/"}
  ].

get_version(Program) ->
  case Program of
    "elixir" ->
      [Version | _] = lists:reverse(string:tokens(os:cmd("elixir -v"), " ")),
      clean_string(Version);
    "rustc" ->
      [_, Version | _] = string:tokens(os:cmd("rustc --version"), " "),
      clean_string(Version);
    "node" ->
      VersionString = os:cmd("node -v"),
      Version = string:substr(VersionString, 1, string:len(VersionString)),
      clean_string(Version);
    _ ->
    terminate()
  end.

download_args(Program, Version) ->
  case Program of
    "elixir" ->
      {[ "https://github.com/elixir-lang/elixir/releases/download/v",
        Version, "/Precompiled.zip" ], "elixir.zip"};
    "rustc" ->
      {"https://sh.rustup.rs", "rustup.rs"};
    "node" ->
      ArchiveFilename = node_archive_filename(Version),
      { node_download_link(ArchiveFilename, Version), ArchiveFilename };
    _ ->
      terminate()
  end.

node_archive_filename(Version) ->
  Arch = get_os_arch(),

  case os:type() of
    {win32, nt} ->
      ["node-v", Version, "-win-", Arch, ".zip"];
    {unix, darwin} ->
      ["node-v", Version, "-darwin-", Arch, ".tar.gz"];
    {unix, linux} ->
      ["node-v", Version, "-linux-", Arch, ".tar.gz"];
    _ ->
      terminate()
  end.

node_download_link(ArchiveFilename, Version) ->
  BaseLink = "https://nodejs.org/download/release/v",
  [BaseLink, Version, "/"] ++ ArchiveFilename.

setup(Program, ArchiveFile) ->
  case Program of
    "elixir" ->
      uncompress_archive(
        [".moongate/elixir.zip"],
        [".moongate/elixir"],
        ".zip"
      );
    "rustc" ->
      external_cmd(["sh ", root_dir(), ".moongate/rustup.rs -y"]);
    "node" ->
      Extension = filename:extension(ArchiveFile),
      TargetDir = [".moongate/"] ++ lists:droplast(ArchiveFile),
      uncompress_archive(
        [".moongate/", ArchiveFile],
        [".moongate"],
        Extension
      ),
      mv(TargetDir, ".moongate/node");
    _ -> terminate()
  end.

% %%%
% %%% Utility functions
% %%%

clean_string(String) ->
  re:replace(String, "(^\\s+)|(\\s+$)", "", [global,{return,list}]).

get_input() ->
  case io:fread("[Y/n] ","~s") of
    {ok, Response} ->
      clean_string(Response) =:= "Y" orelse clean_string(Response) =:= "y";
    _ ->
      terminate()
  end.

mkdir(Path) ->
  case file:read_file_info(Path) of
    {ok, _} -> ok;
    _ -> file:make_dir([root_dir(), Path])
  end.

mv(Source, Target) ->
  case os:type() of
    {win32, nt} ->
      % TODO - support win32
      terminate();
    {unix, _} ->
      os:cmd(["mv ", root_dir(), Source, " ", root_dir(), Target]);
      % os:cmd(["mv ", root_dir(), Source, " ", root_dir(), Target]);
    _ ->
      terminate()
  end.

root_dir() ->
  [filename:dirname(escript:script_name()), "/../"].

% %% Returns `true` if the executable can be found.
program_exists(Program) ->
  case os:type() of
    {win32, nt} ->
      string:str(os:cmd(["where ", Program]), Program) =/= 0;
    {unix, _} ->
      string:str(os:cmd(["which ", Program]), Program) =/= 0;
    _ ->
      terminate()
  end.

get_os_arch() ->
  RawOsArch = get_raw_os_arch(),
  CheckX64 = string:str(RawOsArch, "64"),

  case CheckX64 of
    Result when Result > 0 ->
      "x64";
    _ ->
      "x86"
  end.

get_raw_os_arch() ->
  case os:type() of
    {win32, _} ->
      % TODO - support win32
      terminate();
    {unix, _} ->
      os:cmd("printf $(uname -m)");
    _ ->
      terminate()
  end.

% %% Reads the required version number from the
% %% priv/project version file,
get_required_version(Program) ->
  {ok, File} = file:read_file([root_dir(), "priv/manifest/", Program ,"_version"]),
  Contents = unicode:characters_to_list(File),
  clean_string(Contents).

terminate() ->
  terminate("\n\033[31mQuitting\n").
terminate(Message) ->
  io:format(Message),
  halt(1).

% %%%
% %%% Messages
% %%%%

message_cancel_refuse_install(Program, Version, Link) ->
  [
    "\033[31mERROR: ",
    "Moongate needs ",
    Program,
    " version ",
    Version,
    " to run.\n",
    "To install it manually, visit ",
    Link,
    "\n"
  ].

message_cant_download() ->
  [
    "\033[31mERROR: Can't find wget or curl to download Elixir.\n",
    "Check your PATH.\n",
    "\n"
  ].

message_not_found(Program) ->
  Message = [
    "\n🔮\033[30m  Moongate requires ", Program, " but it doesn't ",
    "appear to\nbe installed (if you think this is wrong check your\n",
    "PATH variable). Download and install it?\n",
    "\n"
  ],
  unicode:characters_to_binary(Message).

message_post_install(Program, Version) ->
  {ok, WorkingDir} = file:get_cwd(),

  [
    "\033[32m",
    Program,
    " ",
    Version,
    " installed in ",
    WorkingDir,
    "/.moongate\033[0m\n"
  ].

message_wrong_version(Program, Version, Required) ->
  {ok, WorkingDir} = file:get_cwd(),

  case Program of
    "elixir" ->
      unicode:characters_to_binary([
        "\n🔮  Moongate requires Elixir version \033[36m",
        Required, "\e[0m but you\nhave version \033[31m",
        Version, "\e[0m. Should Moongate download and\n",
        "install the correct version? This will not modify\n",
        "your existing installation - a copy will be setup\n",
        "in Moongate's own directory:\n",
        "\n\033[33m", WorkingDir, "/.moongate/", Program,
        "\033[0m\n"
      ]);
    "node" ->
      unicode:characters_to_binary([
        "\n🔮  Moongate uses NodeJS version \033[36m", Required,
        "\e[0m for its web-based\nclient integrations, but you have \033[31m",
        Version, "\e[0m. The installed\nversion will likely work fine if it is ",
        "within the *\033[36m", major_version(Version), "\n\e[0mrange. ",
        "(If you don't intend to connect to Moongate using\na web ",
        "browser or the bundled Electron client, you can\nskip this step.)\n\n",

        "Should Moongate download and install the correct version?\n",
        "This will not modify your existing installation - a copy\n",
        "will be setup in Moongate's own directory:\n",
        "\n\033[33m", WorkingDir, "/.moongate/", Program,
        "\033[0m\n"
      ]);
    _ ->
      unicode:characters_to_binary([
        "\n🔮  Moongate requires", Program,
        "version \033[36m", Required, "\e[0m but you\n",
        "have version \033[36m", Version, "\e[0m. Should",
        "Moongate download and\ninstall the correct version?",
        "This will not modify\nyour existing installation - ",
        "a copy will be setup in Moongate's own directory:\n",
        "\n\033[33m", WorkingDir, "/.moongate/", Program,
        "\033[0m\n"
      ])
  end.

major_version(Version) ->
  [MajorVersion | _] = string:tokens(Version, "."),
  MajorVersion.
