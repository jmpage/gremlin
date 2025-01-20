#!/user/bin/env bash

set -euo pipefail

gremlin support as_root

install() {
    case $(uname) in
        Darwin)
            if [[ -e /opt/homebrew/bin/brew ]]; then
                echo "Homebrew already installed"
            else
                NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            ;;
        *)
            echo "Homebrew is not supported for operating system $(uname)"
            exit 1
            ;;
    esac
}

run() {
    if [ "$#" -lt 1 ]; then
       echo "Invalid number of arguments: expected at least 1, received $#"
       exit 1
    fi

    /opt/homebrew/bin/brew install "$@"
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
        run)
            shift 1
            run "$@"
            ;;
        *)
            echo "$0: invalid command: $1"
            echo ""
            exit 1
            ;;
    esac
}

main "$@"
