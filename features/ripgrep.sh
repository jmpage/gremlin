#!/user/bin/env bash

set -euo pipefail

gremlin support as_root

install() {
    case $(uname) in
        Linux)
            as_root apt-get -y install ripgrep
            ;;
        Darwin)
            gremlin feature homebrew install-package ripgrep
            ;;
        *)
            echo "Ripgrep is not supported for operating system $(uname)"
            exit 1
            ;;
    esac
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
