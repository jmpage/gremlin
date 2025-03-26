#!/usr/bin/env bash

set -euo pipefail

gremlin support as_root
gremlin support get_home_dir
gremlin support logmsg

get_emacs_dir() {
    echo "$(get_home_dir)/.emacs.d"
}

install_main() {
    if is_installed; then
        logmsg info "FEAT emacs-prelude: Install skipped as prelude is already present."
        return 0
    fi

    curl --silent --location https://github.com/bbatsov/prelude/raw/master/utils/installer.sh | sh
}

is_installed() {
    [[ -e "$(get_emacs_dir)/core/prelude-core.el" ]]
}

main() {
    if [ "$#" -lt 1 ]; then
        logmsg fatal "FEAT emacs-prelude: invalid number of arguments: expected at least 1, received $#"
        exit 1
    fi

    case "$1" in
        get-emacs-dir)
            get_emacs_dir
            ;;
        install)
            shift 1
            install_main "$@"
            ;;
        is-installed)
            is_installed
            ;;
        *)
            logmsg fatal "FEAT emacs-prelude: invalid command: $1"
            exit 1
            ;;
    esac
}

main "$@"
