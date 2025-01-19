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
            if [ "$#" -lt 2 ]; then
                echo "Invalid number of arguments, expected: gremlin feature <name> ..."
                exit 1
            fi

            local checkpoint
            local feature
            feature="$2"
            shift 2

            checkpoint="$GREMLIN_CHECKPOINT_DIR/$feature-$(echo $@ | sed 's/ /-/g')"
            if [[ -f "$checkpoint" ]]; then
                echo "Skipping feature which is already completed $feature $@"
            else
                touch "$checkpoint"
                ./gremlin/execute.sh "./features/$feature.sh" "$@"
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
