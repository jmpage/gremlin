#!/user/bin/env bash

set -euo pipefail

gremlin support get_home_dir

install() {
    if [[ -d "$(get_home_dir)/.oh-my-zsh" ]]; then
        echo "Skipping install as Oh My Zsh is already installed"
        return 0
    fi

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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
