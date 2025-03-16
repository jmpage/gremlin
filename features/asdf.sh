#!/usr/bin/env bash

set -euo pipefail

gremlin support as_root
gremlin support get_home_dir

install() {
    local
    tag="$(get_tag "$@")"

    # TODO: check installed version

    if which asdf; then
        echo "Asdf is already installed"
        return 0
    fi

    case $(uname) in
        Linux)
            # Assumption: AMD64 architecture
            download_and_install "$tag" linux amd64
            ;;
        Darwin)
            install_macos
            ;;
        *)
            echo "Asdf not supported for operating system $(uname)"
            exit 1
            ;;
    esac

    run plugin update --all
}

install_macos() {
    gremlin feature homebrew run install asdf
}

# $1 = version
# $2 = platform (darwin|linux)
# $3 = architecture (arm64|amd64|386)
download_and_install() {
    local download_url
    local tempfile

    # 2 = darwin, 3 = amd64
    download_url="https://github.com/asdf-vm/asdf/releases/download/$1/asdf-$1-$2-$3.tar.gz"

    tempfile="$(mktemp --dry-run --suffix=.tar.gz)"
    curl -L -o "$tempfile" "$download_url"

    as_root rm -f /usr/local/bin/asdf
    as_root tar -xzf "$tempfile" --directory /usr/local/bin asdf

    rm "$tempfile"
}

execute() {
    export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
    # shellcheck disable=SC1090
    . <(asdf completion bash)
    "$@"
}

run() {
    asdf "$@"
}

get_tag() {
    if [[ "$#" -eq 0 ]]; then
        curl -s https://api.github.com/repos/asdf-vm/asdf/tags | jq --raw-output 'first .name'
    else
        echo "v$1"
    fi
}

main() {
    if [ "$#" -lt 1 ]; then
        echo "Invalid number of arguments: expected at least 1, received $#"
        echo ""
        exit 1
    fi

    case "$1" in
        execute)
            shift 1
            execute "$@"
            ;;
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
