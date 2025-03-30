#!/usr/bin/env bash

# man os-release
# https://www.linux.org/docs/man5/os-release.html
os_release() {
    case "$1" in
        id) # e.g. debian
            grep '^ID=' < /etc/os-release | sed -E 's/^ID="?([^"]+)"?/\1/'
            ;;
        version_id) # e.g. 12
            grep '^VERSION_ID' < /etc/os-release | sed -E 's/VERSION_ID="?([^"]+)"?/\1/'
            ;;
        version_codename) # e.g. bookworm
            grep '^VERSION_CODENAME' < /etc/os-release | sed -E 's/VERSION_CODENAME="?([^"]+)"?/\1/'
            ;;
        *)
            echo "os_release: unsupported option $1"
            exit 1
            ;;
    esac
}
