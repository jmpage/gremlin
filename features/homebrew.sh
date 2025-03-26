#!/usr/bin/env bash

set -euo pipefail

gremlin support as_root
gremlin support logmsg

install_main() {
    case $(uname) in
        Darwin)
            if [[ -e /opt/homebrew/bin/brew ]]; then
                logmsg info "FEAT homebrew: Install skipped as homebrew is already installed."
            else
                NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            ;;
        *)
            logmsg fatal "FEAT homebrew: unsupported operating system $(uname)."
            exit 1
            ;;
    esac
}

run() {
    if [ "$#" -lt 1 ]; then
        logmsg fatal "FEAT homebrew: invalid number of arguments: expected at least 1, received $#"
        exit 1
    fi

    /opt/homebrew/bin/brew install "$@"
}

main() {
    if [ "$#" -lt 1 ]; then
        logmsg fatal "FEAT homebrew: invalid number of arguments: expected at least 1, received $#"
        exit 1
    fi

    case "$1" in
        install)
            shift 1
            install_main "$@"
            ;;
        run)
            shift 1
            run "$@"
            ;;
        *)
            logmsg fatal "FEAT homebrew: invalid command: $1"
            exit 1
            ;;
    esac
}

main "$@"
