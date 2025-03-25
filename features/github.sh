#!/usr/bin/env bash

set -euo pipefail

gremlin support get_home_dir
gremlin support logmsg

add_known_hosts() {
    local line
    while IFS="" read -r line || [ -n "$line" ]; do
        if [[ ! -f "$(known_hosts_file)" ]] || ! grep "$line" <"$(known_hosts_file)"; then
           echo "$line" >> "$(known_hosts_file)"
        fi
    done <<EOF
$(curl --silent https://api.github.com/meta | jq --raw-output '"github.com "+.ssh_keys[]')
EOF
}

check_ssh() {
    ssh -T git@github.com 2>&1 | grep success
}

known_hosts_file() {
    echo "$(get_home_dir)/.ssh/known_hosts"
}

main() {
    if [ "$#" -lt 1 ]; then
        logmsg fatal "FEAT github: invalid number of arguments: expected at least 1, received $#"
        exit 1
    fi

    case "$1" in
        add-known-hosts)
            shift 1
            add_known_hosts "$@"
            ;;
        check-ssh)
            check_ssh
            ;;
        *)
            logmsg fatal "FEAT github: invalid command: $1"
            exit 1
            ;;
    esac
}

main "$@"
