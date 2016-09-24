#!/bin/sh

# Sets up the .moongate directory if it doesn't exist.
initiation() {
    if [ ! -d ".moongate" ]; then
        poem "${gold}This appears to be your first time running Moongate. Startup will take longer than usual.\n"
        rm -rf _build
        rm -rf deps
        mkdir .moongate
    fi

    [[ ! -z "${world// }" ]] && poem "${normal}Using world ${gold}${world}${normal}.\n"
    [[ -z "${world// }" ]] && world="default" && poem "${gray}MOONGATE_WORLD not set, using default world.\n"
}

scrying() {
    mkdir -p .moongate/elixirs

    if [ ! -d ".moongate/elixirs/${elixir_version}" ]; then
        poem "${purple}Downloading Elixir ${elixir_version} from ${git_source} ..."
        brewing "fetch_elixir"
        poem "${purple} Compiling Elixir ${elixir_version} (${elixir_tag}) from source (be patient) ..."
        brewing "build_elixir"
    fi
}

cleansing() {
    poem "${pink} Cleaning old build artifacts ..."
    brewing "rm -rf _build/dev/lib/moongate"
    poem "${pink} Resetting symbolic links ..."
    brewing "reset_symlinks"
}

fealty() {
    if [ ! -d "deps" ]; then
        poem "${magenta} Fetching dependencies ..."
        brewing "mix deps.get"
        poem "${magenta} Building dependencies ..."
        brewing "mix deps.compile"
    fi
}

creation() {
    poem "${beige} Building server ..."
    brewing "mix compile"
}
