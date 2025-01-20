#!/user/bin/env bash

get_home_dir () {
    if [[ -z "$USER" ]]; then
        # shellcheck disable=SC2016
        echo '$USER not set!' 1>&2
        exit 1
    fi

    case $(uname) in
        Linux)
            echo "/home/$USER"
            ;;
        Darwin)
            echo "/Users/$USER"
            ;;
        *)
            echo "Unhandled operating system $(uname)"
            exit 1
            ;;
    esac
}
