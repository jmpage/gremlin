#!/usr/bin/env bash

set -euo pipefail

gremlin support logmsg

configure() {
    gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
    gsettings_unbind '<Control>period'
    gsettings_unbind '<Alt>space'
}

gsettings_unbind() {
    local gs_args
    gs_args="$(gsettings list-recursively | grep "$1" | awk '{print $1, $2, "[]"}')"

    if [[ -n "$gs_args" ]]; then
        echo "$gs_args" | xargs -n3 gsettings set
    fi
}

main() {
    if [ "$#" -lt 1 ]; then
        logmsg fatal "FEAT gnome: invalid number of arguments: expected at least 1, received $#"
        exit 1
    fi

    case "$1" in
        configure)
            shift 1
            configure "$@"
            ;;
        *)
            logmsg fatal "FEAT gnome: invalid command: $1"
            exit 1
            ;;
    esac
}

main "$@"
