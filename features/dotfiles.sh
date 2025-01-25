#!/usr/bin/env bash

set -euo pipefail

gremlin support get_home_dir

install() {
    gremlin feature github add-known-hosts
    gremlin feature yadm install

    if ! yadm status; then
        if ! gremlin feature -n github check-ssh; then
            gremlin feature yadm run clone https://github.com/jmpage/dotfiles.git
        else
            gremlin feature yadm run clone git@github.com:jmpage/dotfiles.git
        fi
    elif [[ ! "$(gremlin feature -n yadm run remote get-url origin)" == 'git@github.com:jmpage/dotfiles.git' ]] && gremlin feature -n github check-ssh; then
        gremlin feature yadm run remote set-url origin git@github.com:jmpage/dotfiles.git
    fi
}

link_prelude_personal() {
    local dotfiles_personal_dir
    local emacs_dir
    local prelude_personal_dir
    dotfiles_personal_dir="$(get_home_dir)/.config/prelude/personal"
    emacs_dir="$(gremlin feature -n emacs-prelude get-emacs-dir)"
    prelude_personal_dir="$emacs_dir/personal"

    if [[ -h "$prelude_personal_dir" ]] && [[ -e "$prelude_personal_dir" ]]; then
        echo "Skipping symlink of prelude personal directory as it is already symlinked."
        return 0
    fi

    if [[ ! -d "$dotfiles_personal_dir" ]]; then
        echo "Prelude personal directory is missing in dotfiles: $dotfiles_personal_dir" 1>&2
        exit 1
    elif [[ ! -d "$emacs_dir" ]]; then
        echo "Emacs configuration not found at $emacs_dir" 1>&2
        exit 1
    elif ! gremlin feature -n emacs-prelude is-installed; then
        echo "Emacs Prelude is not installed"
        exit 1
    fi

    unlink "$prelude_personal_dir" || rm -rf "$prelude_personal_dir"
    ln -s "$prelude_personal_dir" "$dotfiles_personal_dir"
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
        link-prelude-personal)
            shift 1
            link_prelude_personal "$@"
            ;;
        *)
            echo "$0: invalid command: $1"
            echo ""
            exit 1
            ;;
    esac
}

main "$@"
