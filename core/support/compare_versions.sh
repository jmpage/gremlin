#!/usr/bin/env bash

compare_versions() {
    local version1
    local version2
    local bigger_side
    local i

    IFS="." read -r -a version1 <<< "$1"
    IFS="." read -r -a version2 <<< "$3"

    for (( i = ${#version1[@]}; i < ${#version2[@]}; i++ )); do
        version1[i]=0
    done

    bigger_side=0
    for (( i = 0; i < ${#version1[@]}; i++ )); do
        if [[ ${version1[i]} -gt ${version2[i]} ]]; then
            bigger_side=-1
            break
        fi

        if [[ ${version1[i]} -lt ${version2[i]} ]]; then
            bigger_side=1
            break
        fi
    done

    case "$2" in
        -ge) [[ $bigger_side != 1 ]] && return 0 ;;
        -gt) [[ $bigger_side == -1 ]] && return 0 ;;
        -eq) [[ $bigger_side == 0 ]] && return 0 ;;
        -lt) [[ $bigger_side == 1 ]] && return 0 ;;
        -le) [[ $bigger_side != -1 ]] && return 0 ;;
        *)
            echo "$0: Invalid operand $2" 1>&2
            exit 1
            ;;
    esac

    return 1
}
