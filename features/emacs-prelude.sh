#!/usr/bin/env bash

set -euo pipefail

gremlin support as_root
gremlin support get_home_dir

get_emacs_dir() {
    echo "$(get_home_dir)/.emacs.d"
}

install() {
    if is_installed; then
        echo 'Skipping prelude install as it is already present'
        return 0
    fi

    curl --silent --location https://github.com/bbatsov/prelude/raw/master/utils/installer.sh | sh
}

is_installed() {
    [[ -e "$(get_emacs_dir)/core/prelude-core.el" ]]
}

main() {
    if [ "$#" -lt 1 ]; then
        echo "Invalid number of arguments: expected at least 1, received $#"
        echo ""
        exit 1
    fi

    case "$1" in
        get-emacs-dir)
            get_emacs_dir
            ;;
        install)
            shift 1
            install "$@"
            ;;
        is-installed)
            is_installed
            ;;
        *)
            echo "$0: invalid command: $1"
            echo ""
            exit 1
            ;;
    esac
}

main "$@"
