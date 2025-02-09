#!/usr/bin/env bash
#
# Loads "DSL" and executes given plan

set -euxo pipefail

gremlin() {
    set +u
    if [[ -z "$GREMLIN_CHECKPOINT_DIR" ]]; then
        GREMLIN_CHECKPOINT_DIR="$(mktemp -d -u -p /tmp/gremlin-checkpoints)"
        export GREMLIN_CHECKPOINT_DIR
        mkdir -p "$GREMLIN_CHECKPOINT_DIR"
    fi
    set -u

    case "$1" in
        feature)
            shift 1

            local skip_checkpoint
            skip_checkpoint=0

            local OPTARG
            local OPTIND
            while getopts ":n" opt "${@}"; do
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
            local hashed_args
            local sanitized_args
            feature="$1"
            shift 1

            if [[ "$skip_checkpoint" -eq 1 ]]; then
                if [[ "$*" == 'get-emacs-dir' ]]; then
                    echo "DEBUG: $("$GREMLIN_DIR/gremlin/execute.sh" "$GREMLIN_DIR/features/$feature.sh" "$@")" 1>&2
                fi
                "$GREMLIN_DIR/gremlin/execute.sh" "$GREMLIN_DIR/features/$feature.sh" "$@"
            else
                hashed_args="$(echo "$*" | md5sum | cut -c -32)"
                sanitized_args="$(echo "$*" | sed -r 's/[^a-zA-Z0-9]/-/g' | cut -c 32)"
                checkpoint="$GREMLIN_CHECKPOINT_DIR/$feature-$sanitized_args-$hashed_args"
                if [[ -f "$checkpoint" ]]; then
                    cat "$checkpoint"
                else
                    echo "pwd: $(pwd)"
                    "$GREMLIN_DIR/gremlin/execute.sh" "$GREMLIN_DIR/features/$feature.sh" "$@" > "$checkpoint"
                fi
            fi
            ;;
        support)
            if [ "$#" -ne 2 ]; then
                echo "Invalid number of arguments, expected: gremlin support <name>"
                exit 1
            fi

            # shellcheck disable=SC1090
            . "$GREMLIN_DIR/gremlin/support/$2.sh"
            ;;
        *)
            echo "Unknown command $1"
            exit 1
            ;;
    esac
}

# shellcheck disable=SC1090
. "$@"
