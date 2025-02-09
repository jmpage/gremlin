#!/usr/bin/env bash

set -euo pipefail

gremlin support as_root

check_fingerprint() {
    local filename="$1"
    local expected_fingerprint="$2"

    local output
    set +e
    output="$(gpg --dry-run --quiet --import --import-options import-show "$filename")"
    set -e

    local fingerprint
    fingerprint="$(echo "$output" | awk '/pub/{getline; gsub(/^ +| +$/,""); print $0}')"

    if [[ "$fingerprint" == "$expected_fingerprint" ]]; then
        return 0
    else
        echo "$filename: fingerprint ($fingerprint) did not match expected fingerprint ($expected_fingerprint)" 1>&2
        return 1
    fi
}

debian_install() {
    as_root install --directory --mode=0755 /etc/apt/keyrings

    if [[ ! -f /etc/apt/keyrings/packages.mozilla.org.asc ]]; then
        local tempfile
        tempfile="$(mktemp --dry-run --suffix=mozilla-repo-signing-key.gpg)"
        curl -o "$tempfile" https://packages.mozilla.org/apt/repo-signing-key.gpg
        check_fingerprint "$tempfile" '35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3'
        as_root install --mode=0644 --owner=root --group=root "$tempfile" /etc/apt/keyrings/packages.mozilla.org.asc
        rm "$tempfile"
    fi

    if [[ ! -f /etc/apt/sources.list.d/mozilla.list ]]; then
        echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | as_root tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
    fi

    as_root apt-get update && as_root apt-get install firefox
}

macos_install() {
    local tempfile
    tempfile="$(mktemp --dry-run --suffix=firefox.dmg)"

    curl -o "$tempfile" https://download.mozilla.org/?product=firefox-latest-ssl&os=osx&lang=en-US
    hdiutil attach "$tempfile"
    as_root cp /Volumes/Firefox/Firefox.app /Applications/
    hdiutil unmount /Volumes/Firefox
    rm "$tempfile"
}

firefox_install() {
    case $(uname) in
        Linux)
            debian_install
            ;;
        Darwin)
            macos_install
            ;;
        *)
            echo "Cursor not supported for operating system $(uname)"
            exit 1
            ;;
    esac
}

firefox_main() {
    if [ "$#" -lt 1 ]; then
        echo "Invalid number of arguments: expected at least 1, received $#"
        echo ""
        exit 1
    fi

    case "$1" in
        install)
            shift 1
            firefox_install "$@"
            ;;
        *)
            echo "$0: invalid command: $1"
            echo ""
            exit 1
            ;;
    esac
}

firefox_main "$@"
