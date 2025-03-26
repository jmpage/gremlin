#!/usr/bin/env bash
#
# This is a thin wrapper around the rest of gremlin

set -euo pipefail

export PS4='+${LINENO}: '
export GREMLIN_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

gremlin_main() {
    local OPTARG
    local OPTIND
    local loglevel
    loglevel=info

    while getopts ":hv:" opt "${@}"; do
        case ${opt} in
            h)
                print_help
                exit 0
                ;;
            v)
                loglevel="${OPTARG}"
                ;;
            ?)
                echo "Invalid option: ${OPTARG}"
                echo ""
                print_help
                exit 1;
                ;;
        esac
    done
    shift $((OPTIND -1))

    case "$loglevel" in
        fatal)
            export GREMLIN_LOG_LEVEL=1
            ;;
        error)
            export GREMLIN_LOG_LEVEL=2
            ;;
        warn)
            export GREMLIN_LOG_LEVEL=3
            ;;
        info)
            export GREMLIN_LOG_LEVEL=4
            ;;
        debug)
            export GREMLIN_LOG_LEVEL=5
            ;;
        trace)
            export GREMLIN_LOG_LEVEL=6
            ;;
        *)
            echo "Invalid verbosity option: $loglevel"
            exit 1
            ;;
    esac

    if [ "$#" -lt 1 ]; then
        echo "Invalid number of arguments: expected at least 1, received $#"
        echo ""
        print_help
        exit 1
    fi

    case "$1" in
        describe)
            shift 1
            describe_plan "$@"
            ;;
        execute)
            shift 1
            execute_plan "$@"
            ;;
        list)
            list_plans
            ;;
        *)
            echo "Invalid command: $1"
            echo ""
            print_help
            exit 1
            ;;
        esac
}

describe_plan() {
    if [ "$#" -lt 1 ]; then
        echo "Invalid argument to describe: plan name must be specified but no arguments were given"
        echo ""
        print_help
        exit 1
    fi

    # TODO: Rewrite this to be less hacky
    local endofheader_pos
    endofheader_pos=$(sed -n '/^[^#]/{=;q;}' "$GREMLIN_DIR/plans/$1.sh")
    head -n "$((endofheader_pos - 1))" "$GREMLIN_DIR/plans/$1.sh" | tail -n "$((endofheader_pos - 2))" | sed -E 's/^# ?//'
}

execute_plan() {
    if [ "$#" -lt 1 ]; then
        echo "Invalid argument to execute: plan name must be specified but no arguments were given"
        echo ""
        print_help
        exit 1
    fi

    "$GREMLIN_DIR/gremlin/execute.sh" "$GREMLIN_DIR/plans/$1.sh"
}

list_plans() {
    for file in "$GREMLIN_DIR/plans"/*.sh; do
        echo "$file" | sed -nE 's/.*\/([a-z0-9_-]+).sh/\1/p'
    done
}

print_help() {
    echo "USAGE: $0 [-h] [-v level] <command>"
    echo ""
    echo "Executes system setup according to plans"
    echo ""
    echo "OPTIONS"
    echo ""
    echo "  -h - show this help"
    echo ""
    echo "  -v - the log level to use: trace|debug|info|warn|error|fatal (default: info)"
    echo ""
    echo "COMMANDS"
    echo ""
    echo "  describe <name> - describe the named plan"
    echo ""
    echo "  execute <name> - execute the named plan"
    echo ""
    echo "  list - list the available plans"
}

gremlin_main "$@"
