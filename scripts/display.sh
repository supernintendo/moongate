#!/bin/sh

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
