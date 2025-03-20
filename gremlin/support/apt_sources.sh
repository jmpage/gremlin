#!/usr/bin/env bash

apt_sources() {
    case "$1" in
        check)
            shift 1
            grep -E "^$1 $2 $3( .* | )$4( |$)" /etc/apt/sources.list /etc/apt/sources.list.d/*
            ;;
        find)
            shift 1

            local files
            if [ -d /etc/apt/sources.list.d ]; then
                files=$(find /etc/apt/sources.list /etc/apt/sources.list.d/ -type f -printf '%p ')
            else
                files=/etc/apt/sources.list
            fi

            if [ "$#" -gt 3 ]; then
                # shellcheck disable=SC2086
                grep -EH "^$1 $2 $3( .* | )$4( |$)" $files | grep -Eo '^[^:]+'
            else
                # shellcheck disable=SC2086
                grep -EH "^$1 $2 $3 " $files | grep -Eo '^[^:]+'
            fi
            ;;
        list)
            grep ^deb /etc/apt/sources.list /etc/apt/sources.list.d/*
            ;;
        upsert)
            shift 1
            if ! apt_sources check "$@"; then
                if apt_sources find "$1" "$2" "$3"; then
                    local source_location
                    source_location=$(apt_sources find "$1" "$2" "$3")
                    sudo sed -i "s|^$1 $2 $3 \([^#]*\)|$1 $2 $3 \1 $4|" "$source_location"
                else
                    echo "$1 $2 $3 $4" | sudo tee --append /etc/apt/sources.list
                fi
            fi
            ;;
        *)
            echo "apt_sources: unsupported option $1"
            exit 1
            ;;
    esac
}
