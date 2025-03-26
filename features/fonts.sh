#!/usr/bin/env bash

set -euo pipefail

gremlin support as_root
gremlin support logmsg

get_font_dir() {
    case $(uname) in
        Linux)
            echo "${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
            ;;
        Darwin)
            echo "$HOME/Library/Fonts"
            ;;
        *)
            logmsg fatal "FEAT fonts: unsupported operating system $(uname)."
            exit 1
            ;;
    esac
}

install_main() {
    local filename
    local fontdir
    local fonts_installed
    fontdir="$(get_font_dir)"
    fonts_installed=0

    mkdir -p "$fontdir"

    for url in "$@"; do
        filename="$(echo "$url" | grep -Eo '[^/]+$' | sed 's/%20/ /g')"

        if [[ -e "$fontdir/$filename" ]]; then
            logmsg info "FEAT fonts: skipping installation of $filename as it already exists in $fontdir"
        else
            curl -o "$fontdir/$filename" "$url"
            fonts_installed=$((fonts_installed+1))
        fi
    done

    if [[ "$fonts_installed" -gt 0 ]] && which fc-cache; then
        fc-cache -f -v
    fi
}

main() {
    if [ "$#" -lt 1 ]; then
        logmsg fatal "FEAT fonts: invalid number of arguments: expected at least 1, received $#"
        exit 1
    fi

    case "$1" in
        install)
            shift 1
            install_main "$@"
            ;;
        *)
            logmsg fatal "FEAT fonts: invalid command: $1"
            exit 1
            ;;
    esac
}

main "$@"
