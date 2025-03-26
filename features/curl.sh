#!/usr/bin/env bash

set -euo pipefail

gremlin support as_root
gremlin support logmsg

install_main() {
    case $(uname) in
        Linux)
            as_root apt-get -y install curl
            ;;
        Darwin)
            gremlin feature homebrew run install curl
            ;;
        *)
            logmsg fatal "FEAT curl: unsupported operating system $(uname)."
            exit 1
            ;;
    esac
}

main() {
    if [ "$#" -lt 1 ]; then
        logmsg fatal "FEAT curl: invalid number of arguments: expected at least 1, received $#"
        echo ""
        exit 1
    fi

    case "$1" in
        install)
            shift 1
            install_main "$@"
            ;;
        *)
            logmsg fatal "FEAT curl: invalid command: $1"
            exit 1
            ;;
    esac
}

main "$@"
