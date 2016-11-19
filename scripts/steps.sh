#!/bin/sh

# Sets up the _moongate directory if it doesn't exist.
initialize() {
    if [ ! -d "_moongate" ]; then
        message "${gold}This appears to be your first time running Moongate. Startup will take longer than usual.\n"
        rm -rf _build
        rm -rf deps
        mkdir _moongate
    fi

    [[ ! -z "${world// }" ]] && message "${normal}Using world ${gold}${world}${normal}.\n"
    [[ -z "${world// }" ]] && world="default" && message "${gray}MOONGATE_WORLD not set, using default world.\n"
}

fetch_elixir() {
    mkdir -p _moongate/elixirs

    if [ ! -d "_moongate/elixirs/${elixir_version}" ]; then
        message "${purple}Downloading Elixir ${elixir_version} from ${git_source} ..."
        loading "download_elixir"
        message "${purple} Compiling Elixir ${elixir_version} (${elixir_tag}) from source (be patient) ..."
        loading "build_elixir"
    fi
}

clean_moongate() {
    message "${pink} Cleaning old build artifacts ..."
    loading "rm -rf _build/dev/lib/moongate"
    message "${pink} Resetting symbolic links ..."
    loading "reset_symlinks"
}

fetch_deps() {
    if [ ! -d "deps" ]; then
        message "${magenta} Fetching dependencies ..."
        loading "mix deps.get"
        message "${magenta} Building dependencies ..."
        loading "mix deps.compile"
    fi
}

compile_moongate() {
    message "${beige} Building server ..."
    loading "mix compile"
}
