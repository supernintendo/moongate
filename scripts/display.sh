#!/bin/sh

# Display a banner.
greeting() {
    # Greeting
    peek "--no-greet" "${args[@]}"
    if [ $? -eq 1 ]; then
        version=$(head -n 1 priv/metadata/version)
        declare -a message=(
            "\n"
            █▀▄▀█ ████▄ ████▄    ▄     ▄▀  ██     ▄▄▄▄▀ ▄███▄   "\n"
            █ █ █ █   █ █   █     █  ▄▀    █ █ ▀▀▀ █    █▀   ▀  "\n"
            █ ▄ █ █   █ █   █ ██   █ █ ▀▄  █▄▄█    █    ██▄▄    "\n"
            █   █ ▀████ ▀████ █ █  █ █   █ █  █   █     █▄   ▄▀ "\n"
               █              █  █ █  ███     █  ▀      ▀███▀   "\n"
              ▀               █   ██         █
                             ▀
            "\n"
        )
	for (( i = 0; i < 8; i++ )); do
        printf "$(tput setaf 5)${message[$i]}$(tput sgr0)"
	done

        # for i in $(seq $start 256) ; do tput setaf $i ; printf "${message[i - $start]}" ; done ; tput setaf 15 ; echo
        echo ""
	echo "                                    version ${green}${version}."
        echo "${normal}"
    fi
}

# Print a line, adding a new line and
# resetting colorized text if --verbose
# is passed to avoid polluting output
# from other processes.
message() {
    peek "--verbose" "${args[@]}"
    if [ $? -eq 1 ]; then
        printf "  $@"
    else
        printf "  $@${normal}\n"
    fi
}

# Display a spinning moon animation.
spin() {
    pid=$! # Process Id of the previous running command
    frames='🌑🌒🌓🌔🌕🌖🌗🌘'

    i=0
    while kill -0 $pid 2>/dev/null
    do
        i=$(( (i+1) %8 ))
        printf "\r${frames:$i:1} "
        sleep .1
    done
    echo ""
}
