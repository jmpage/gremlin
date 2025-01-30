#!/usr/bin/env bash
#
# This is a thin wrapper around the rest of gremlin

set -euo pipefail

export PS4='+${LINENO}: '

gremlin_main() {
    local OPTARG
    local OPTIND
    while getopts ":hd" opt "${@}"; do
        case ${opt} in
            h)
                print_help
                exit 0
                ;;
            d)
                export GREMLIN_VERBOSE=1
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
        ?)
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
    endofheader_pos=$(sed -n '/^[^#]/{=;q;}' "./plans/$1.sh")
    head -n "$((endofheader_pos - 1))" "./plans/$1.sh" | tail -n "$((endofheader_pos - 2))" | sed -E 's/^# ?//'
}

execute_plan() {
    if [ "$#" -lt 1 ]; then
        echo "Invalid argument to execute: plan name must be specified but no arguments were given"
        echo ""
        print_help
        exit 1
    fi

    ./gremlin/execute.sh "./plans/$1.sh"
}

list_plans() {
    for file in ./plans/*.sh; do
        echo "$file" | sed -nE 's/.*\/([a-z0-9_-]+).sh/\1/p'
    done
}

print_help() {
    echo "USAGE: $0 [-h] [-v] <command>"
    echo ""
    echo "Executes system setup according to plans"
    echo ""
    echo "OPTIONS"
    echo ""
    echo "  -h - show this help"
    echo ""
    echo "  -v - log verbosely"
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
