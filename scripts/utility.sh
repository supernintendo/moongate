#!/bin/sh

# Execute a command and show a spinning moon
# animation while it runs (animation hides
# when --verbose is passed).
brewing() {
    peek "--verbose" "${args[@]}"
    if [ $? -eq 1 ]; then
        $@ >& "priv/worlds/${world}/.log--last-build" & spin
    else
        $@
    fi
}

# Compile Elixir from source.
build_elixir() {
    cd ".moongate/elixirs/${elixir_version}"
    git checkout "${elixir_tag}"
    make clean
    make
    reset_wd
}

# Clone Elixir from the URL specified in
# scripts/constants.sh.
fetch_elixir() {
    git clone "${git_source}" ".moongate/elixirs/${elixir_version}"
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
    rm .moongate/elixir 2> /dev/null
    rm .moongate/elixirc 2> /dev/null
    rm .moongate/iex 2> /dev/null
    rm .moongate/mix 2> /dev/null
    ln -s "elixirs/${elixir_version}/bin/elixir" .moongate/elixir
    ln -s "elixirs/${elixir_version}/bin/elixirc" .moongate/elixirc
    ln -s "elixirs/${elixir_version}/bin/iex" .moongate/iex
    ln -s "elixirs/${elixir_version}/bin/mix" .moongate/mix
}

# Set proper directory (or try to, anyhow).
reset_wd() {
    cd "${0%/*}"
}
