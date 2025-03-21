#!/usr/bin/env bash

get_architecture() {
    case $(uname -m -p -i) in
        *x86_64*)
            echo 'amd64'
            ;;
        *aarch64* | *arm8*)
            echo 'arm64'
            ;;
        *i386* | *i686*)
            echo 'x86'
            ;;
        *)
            echo "get_architecture: unknown architecture $(uname -m -p -i)" 1>&2
            exit 1
            ;;
    esac
}
