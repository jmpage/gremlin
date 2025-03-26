#!/usr/bin/env bash

set -euo pipefail

gremlin support as_root
gremlin support get_home_dir
gremlin support logmsg

clone() {
    # NOTE: When cloning outside of the home directory, new files will be staged and deleted
    cd "$(get_home_dir)"
    "$(yadm_bin)" clone "$@"
}

install_main() {
    case $(uname) in
        Linux)
            as_root apt-get -y install yadm
            ;;
        Darwin)
            gremlin feature homebrew run install yadm
            ;;
        *)
            logmsg fatal "FEAT yadm: unsupported operating system $(uname)."
            exit 1
            ;;
    esac
}

main() {
    if [ "$#" -lt 1 ]; then
        logmsg fatal "FEAT yadm: invalid number of arguments: expected at least 1, received $#"
        exit 1
    fi

    case "$1" in
        clone)
            shift 1
            clone "$@"
            ;;
        install)
            shift 1
            install_main "$@"
            ;;
        run)
            shift 1
            "$(yadm_bin)" "$@"
            ;;
        *)
            logmsg fatal "FEAT yadm: invalid command: $1"
            exit 1
            ;;
    esac
}

yadm_bin() {
    case $(uname) in
        Linux)
            echo '/usr/bin/yadm'
            ;;
        Darwin)
            echo '/opt/homebrew/bin/yadm'
            ;;
        *)
            logmsg fatal "FEAT yadm: unsupported operating system $(uname)."
            exit 1
            ;;
    esac

}

main "$@"
