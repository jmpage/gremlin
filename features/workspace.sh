#!/usr/bin/env bash

set -euo pipefail

gremlin support get_home_dir

create() {
    mkdir -p "$(get_home_dir)/workspace/oss"
    mkdir -p "$(get_home_dir)/workspace/personal"
}

main() {
    if [ "$#" -lt 1 ]; then
        echo "Invalid number of arguments: expected at least 1, received $#"
        echo ""
        exit 1
    fi

    case "$1" in
        create)
            shift 1
            create
            ;;
        *)
            echo "$0: invalid command: $1"
            echo ""
            exit 1
            ;;
    esac
}

main "$@"
