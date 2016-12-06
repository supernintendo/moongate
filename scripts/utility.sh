#!/bin/sh

# Compile Elixir from source.
build_elixir() {
    cd "_moongate/elixir/${elixir_version}"
    git checkout "${elixir_tag}"
    make clean
    make
    reset_wd
}

# Clone Elixir from the URL specified in
# scripts/constants.sh.
download_elixir() {
    git clone "${git_source}" "_moongate/elixir/${elixir_version}"
}

# Execute a command and show a spinning moon
# animation while it runs (animation hides
# when --verbose is passed).
loading() {
    peek "--verbose" "${args[@]}"
    if [ $? -eq 1 ]; then
        $@ >& "priv/logs/${world}-build.log" & spin
    else
        $@
    fi
}

# Takes a string and array (constructed
#  with declare -a). Returns 0 (success)
#  if the string matches any elements
#  in the array.
peek() {
    local e
    for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
    return 1
}

reset_symlinks() {
    reset_wd
    rm _moongate/elixir 2> /dev/null
    rm _moongate/elixirc 2> /dev/null
    rm _moongate/iex 2> /dev/null
    rm _moongate/mix 2> /dev/null
    ln -s "elixir/${elixir_version}/bin/elixir" _moongate/elixir
    ln -s "elixir/${elixir_version}/bin/elixirc" _moongate/elixirc
    ln -s "elixir/${elixir_version}/bin/iex" _moongate/iex
    ln -s "elixir/${elixir_version}/bin/mix" _moongate/mix
}

# Set proper directory (or try to, anyhow).
reset_wd() {
    cd "${0%/*}"
}
