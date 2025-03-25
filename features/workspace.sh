#!/usr/bin/env bash

set -euo pipefail

gremlin support get_home_dir
gremlin support logmsg

create() {
    mkdir -p "$(get_home_dir)/workspace/oss"
    mkdir -p "$(get_home_dir)/workspace/personal"
}

main() {
    if [ "$#" -lt 1 ]; then
        logmsg fatal "FEAT workspace: invalid number of arguments: expected at least 1, received $#"
        exit 1
    fi

    case "$1" in
        create)
            shift 1
            create
            ;;
        *)
            logmsg fatal "FEAT workspace: invalid command: $1"
            exit 1
            ;;
    esac
}

main "$@"
