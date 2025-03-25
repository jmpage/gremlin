#!/usr/bin/env bash

set -euo pipefail

gremlin support as_root
gremlin support logmsg

install() {
    case $(uname) in
        Linux)
            as_root apt-get -y install tmux
            ;;
        Darwin)
            gremlin feature homebrew run install tmux
            ;;
        *)
            logmsg fatal "FEAT tmux: unsupported operating system $(uname)."
            exit 1
            ;;
    esac
}

main() {
    if [ "$#" -lt 1 ]; then
        logmsg fatal "FEAT tmux: invalid number of arguments: expected at least 1, received $#"
        exit 1
    fi

    case "$1" in
        install)
            shift 1
            install "$@"
            ;;
        *)
            logmsg fatal "FEAT tmux: invalid command: $1"
            exit 1
            ;;
    esac
}

main "$@"
