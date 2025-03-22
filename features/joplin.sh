#!/usr/bin/env bash

set -euo pipefail

install_joplin() {
    case $(uname) in
        Linux)
            install_linux
            ;;
        *)
            echo "Joplin not supported for operating system $(uname)"
            exit 1
            ;;
    esac
}

install_linux() {
    curl --silent --location https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash
}

main() {
    if [ "$#" -lt 1 ]; then
        echo "Invalid number of arguments: expected at least 1, received $#"
        echo ""
        exit 1
    fi

    case "$1" in
        install)
            shift 1
            install_joplin "$@"
            ;;
        *)
            echo "$0: invalid command: $1"
            echo ""
            exit 1
            ;;
    esac
}

main "$@"
