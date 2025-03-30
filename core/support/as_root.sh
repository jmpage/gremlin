#!/usr/bin/env bash

as_root () {
    if [ "$EUID" != 0 ]; then
        sudo -- "$@"
    fi
}
