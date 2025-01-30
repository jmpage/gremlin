#!/usr/bin/env bash

set -euo pipefail

gsettings_unbind() {
    local gs_args
    gs_args="$(gsettings list-recursively | grep "$1" | awk '{print $1, $2, "[]"}')"

    if [[ -n "$gs_args" ]]; then
        echo "$gs_args" | xargs -n3 gsettings set
    fi
}

configure() {
    gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
    gsettings_unbind '<Control>period'
    gsettings_unbind '<Alt>space'
}

main() {
    if [ "$#" -lt 1 ]; then
        echo "Invalid number of arguments: expected at least 1, received $#"
        echo ""
        exit 1
    fi

    case "$1" in
        configure)
            shift 1
            configure "$@"
            ;;
        *)
            echo "$0: invalid command: $1"
            echo ""
            exit 1
            ;;
    esac
}

main "$@"
