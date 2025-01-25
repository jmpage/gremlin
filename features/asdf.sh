#!/usr/bin/env bash

set -euo pipefail

gremlin support get_home_dir

get_asdf_dir() {
    echo "$(get_home_dir)/.asdf"
}

install() {
    local asdf_dir
    asdf_dir="$(get_asdf_dir)"

    if [[ -d "$asdf_dir" ]]; then
        echo "Asdf is already installed"
        return 0
    fi

    git clone 'https://github.com/asdf-vm/asdf.git' "$asdf_dir"
    cd "$asdf_dir"
    git checkout "$(git describe --abbrev=0 --tags)"

    run plugin update --all
}

execute() {
    # shellcheck disable=SC1091
    . "$(get_asdf_dir)/asdf.sh"
    "$@"
}

run() {
    "$(get_asdf_dir)/bin/asdf" "$@"
}

main() {
    if [ "$#" -lt 1 ]; then
        echo "Invalid number of arguments: expected at least 1, received $#"
        echo ""
        exit 1
    fi

    case "$1" in
        execute)
            shift 1
            execute "$@"
            ;;
        install)
            shift 1
            install "$@"
            ;;
        run)
            shift 1
            run "$@"
            ;;
        *)
            echo "$0: invalid command: $1"
            echo ""
            exit 1
            ;;
    esac
}

main "$@"
