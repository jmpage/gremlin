#!/usr/bin/env bash

set -euo pipefail

gremlin support as_root
gremlin support os_release
gremlin support apt_sources

install() {
    case $(uname) in
        Linux)
            install_linux
            ;;
        *)
            echo "Dropbox not supported for operating system $(uname)"
            exit 1
            ;;
    esac
}

install_linux() {
    case $(os_release id) in
        debian)
            install_debian
            ;;
        *)
            echo "Dropbox not supported for Linux distro $(os_release id)"
            exit 1
            ;;
    esac
}

install_debian() {
    if ! dpkg-query --status nautilus-dropbox; then
        local version_codename
        version_codename="$(os_release version_codename)"

        apt_sources upsert deb https://deb.debian.org/debian "$version_codename" non-free
        apt_sources upsert deb-src https://deb.debian.org/debian "$version_codename" non-free
        apt_sources upsert deb https://security.debian.org/debian-security "$version_codename"-security non-free
        apt_sources upsert deb-src https://security.debian.org/debian-security "$version_codename"-security non-free
        apt_sources upsert deb https://deb.debian.org/debian "$version_codename"-updates non-free
        apt_sources upsert deb-src https://deb.debian.org/debian "$version_codename"-updates non-free
        as_root apt-get update

        as_root apt-get install -y nautilus-dropbox
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
