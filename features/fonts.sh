#!/usr/bin/env bash

set -euo pipefail

gremlin support as_root


get_font_dir() {
    case $(uname) in
        Linux)
            echo "${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
            ;;
        Darwin)
            echo "$HOME/Library/Fonts"
            ;;
        *)
            echo "Unhandled operating system: $(uname)" 1>&2
            exit 1
            ;;
    esac
}

install() {
    local filename
    local fontdir
    local fonts_installed
    fontdir="$(get_font_dir)"
    fonts_installed=0

    mkdir -p "$fontdir"

    for url in "$@"; do
        filename="$(echo "$url" | grep -Eo '[^/]+$' | sed 's/%20/ /g')"

        if [[ -e "$fontdir/$filename" ]]; then
            echo "Skipping installation of $filename as it already exists in $fontdir"
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
        echo "Invalid number of arguments: expected at least 1, received $#"
        echo ""
        exit 1
    fi

    case "$1" in
        install)
            shift 1
            install "$@"
            ;;
        *)
            echo "$0: invalid command: $1"
            echo ""
            exit 1
            ;;
    esac
}

main "$@"
