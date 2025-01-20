#!/user/bin/env bash

set -euo pipefail

gremlin support as_root

install() {
    gremlin feature github add-known-hosts
    gremlin feature yadm install

    if ! yadm status; then
        if ! gremlin feature -n github check-ssh; then
            gremlin feature yadm run clone https://github.com/jmpage/dotfiles.git
        else
            gremlin feature yadm run clone git@github.com:jmpage/dotfiles.git
        fi
    elif [[ ! "$(gremlin feature -n yadm run remote get-url origin)" -eq 'git@github.com:jmpage/dotfiles.git' ]] && gremlin feature -n github check-ssh; then
        gremlin feature yadm run remote set-url origin git@github.com:jmpage/dotfiles.git
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
