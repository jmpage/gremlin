#!/usr/bin/env bash

set -euo pipefail

gremlin support get_home_dir
gremlin support logmsg

install_main() {
    if [[ -d "$(get_home_dir)/.oh-my-zsh" ]]; then
        logmsg info "FEAT oh-my-zsh: Skipping install as Oh My Zsh is already installed"
        return 0
    fi

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --skip-chsh --unattended"
}

main() {
    if [ "$#" -lt 1 ]; then
        logmsg fatal "FEAT oh-my-zsh: invalid number of arguments: expected at least 1, received $#"
        exit 1
    fi

    case "$1" in
        install)
            shift 1
            install_main "$@"
            ;;
        *)
            logmsg fatal "FEAT oh-my-zsh: invalid command: $1"
            exit 1
            ;;
    esac
}

main "$@"
