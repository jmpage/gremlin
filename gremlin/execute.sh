#!/usr/bin/env bash
#
# Loads "DSL" and executes given plan

set -euo pipefail

gremlin() {
    set +u
    if [[ -z "$GREMLIN_CHECKPOINT_DIR" ]]; then
        local tempdir
        GREMLIN_CHECKPOINT_DIR="$(mktemp -d -u -p /tmp/gremlin-checkpoints)"
        mkdir -p "$GREMLIN_CHECKPOINT_DIR"
    fi
    set -u

    case "$1" in
        feature)
            shift 1

            local skip_checkpoint
            local OPTIND
            while getopts ":n" opt "${@}"; do
                echo "opt: $opt, arg: ${OPTARG}"
                case ${opt} in
                    n)
                        skip_checkpoint=1
                        ;;
                    *)
                        echo "Invalid option: ${OPTARG}"
                        echo ""
                        exit 1;
                        ;;
                esac
            done
            shift $((OPTIND -1))

            if [ "$#" -lt 1 ]; then
                echo "Invalid number of arguments, expected: gremlin feature [-n] <name> ..."
                exit 1
            fi

            local checkpoint
            local feature
            feature="$1"
            shift 1

            if [[ skip_checkpoint -eq 0 ]]; then
                ./gremlin/execute.sh "./features/$feature.sh" "$@"
            else
                checkpoint="$GREMLIN_CHECKPOINT_DIR/$feature-$(echo $@ | sed 's/ /-/g')"
                if [[ -f "$checkpoint" ]]; then
                    cat "$checkpoint"
                else
                    ./gremlin/execute.sh "./features/$feature.sh" "$@" > "$checkpoint"
                fi
            fi
            ;;
        support)
            if [ "$#" -ne 2 ]; then
                echo "Invalid number of arguments, expected: gremlin support <name>"
                exit 1
            fi

            . ./gremlin/support/$2.sh
            ;;
        *)
            echo "Unknown command $1"
            exit 1
            ;;
    esac
}

. $@
