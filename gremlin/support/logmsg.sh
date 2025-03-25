#!/usr/bin/env bash

logmsg() {
    local loglevel
    local loglevel_name

    case $1 in
        fatal)
            loglevel=1
            ;;
        error)
            loglevel=2
            ;;
        warn)
            loglevel=3
            ;;
        info)
            loglevel=4
            ;;
        debug)
            loglevel=5
            ;;
        trace)
            loglevel=6
            ;;
        *)
            logmsg fatal "$0: unknown log level: $1"
            exit 1
            ;;
    esac

    loglevel_name=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    shift 1

    if [[ loglevel -le ${GREMLIN_LOG_LEVEL:-6} ]]; then
        echo "$loglevel_name $@" 1>&2
    fi
}
