#!/usr/bin/env bash

set -euo pipefail

gremlin support logmsg

install_main() {
    case $(uname) in
        Linux)
            install_linux
            ;;
        *)
            logmsg fatal "FEAT joplin: unsupported operating system $(uname)."
            exit 1
            ;;
    esac
}

install_linux() {
    curl --silent --location https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash
}

main() {
    if [ "$#" -lt 1 ]; then
        logmsg fatal "FEAT joplin: invalid number of arguments: expected at least 1, received $#"
        exit 1
    fi

    case "$1" in
        install)
            shift 1
            install_main "$@"
            ;;
        *)
            logmsg fatal "FEAT joplin: invalid command: $1"
            exit 1
            ;;
    esac
}

main "$@"
