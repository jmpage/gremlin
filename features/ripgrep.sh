#!/usr/bin/env bash

set -euo pipefail

gremlin support as_root
gremlin support logmsg

install() {
    case $(uname) in
        Linux)
            as_root apt-get -y install ripgrep
            ;;
        Darwin)
            gremlin feature homebrew run install ripgrep
            ;;
        *)
            logmsg fatal "FEAT ripgrep: unsupported operating system $(uname)."
            exit 1
            ;;
    esac
}

main() {
    if [ "$#" -lt 1 ]; then
        logmsg fatal "FEAT ripgrep: invalid number of arguments: expected at least 1, received $#"
        exit 1
    fi

    case "$1" in
        install)
            shift 1
            install "$@"
            ;;
        *)
            logmsg fatal "FEAT ripgrep: invalid command: $1"
            exit 1
            ;;
    esac
}

main "$@"
