#!/user/bin/env bash

set -euo pipefail

gremlin support as_root

install() {
    case $(uname) in
        Linux)
            as_root apt-get -y install emacs
            ;;
        Darwin)
            install_dmg "$@"
            ;;
        *)
            echo "Emacs not supported for operating system $(uname)"
            exit 1
            ;;
    esac
}

install_dmg() {
    local codesign_output
    local mtree_status
    local tempfile
    local temptreefile
    local version

    if [[ -z "$1" ]]; then
        version=$(curl https://emacsformacosx.com/download/emacs-builds/ | grep -E '"Emacs-[0-9\.\-]+-universal.dmg"' | sed -re 's/.*"(Emacs-[0-9\.\-]+-universal.dmg)".*([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\2 \1/g' | sort -nr | head -1 | sed 's/^[0-9\-]* //g')
    else
        version="$1"
    fi

    tempfile="$(mktemp --dry-run --suffix=.dmg)"
    curl -o "$tempfile" "https://emacsformacosx.com/emacs-builds/$version"
    hdiutil attach "$tempfile"

    codesign_output="$(codesign -dvv /Volumes/Emacs/Emacs.app 2>&1)"
    if ! echo $codesign_output | grep 'Authority=Developer ID Application: Galvanix (5BRAQAFB8B)'; then
        echo "Signature check for emacs failed! Check $tempfile"
        hdiutil unmount /Volumes/Emacs
        exit 1
    fi

    temptreefile="$(mktemp --dry-run --suffix=.mtree)"
    mtree -c -K sha256digest -p /Applications/Emacs.app > "$temptreefile"

    set +e
    mtree_status=$(mtree -p /Volumes/Emacs/Emacs.app < "$temptreefile"; echo $?)
    set -e
    case mtree_status in
        0)
            echo "Emacs already matches installed version"
            ;;
        2)
            as_root rm -rf /Applications/Emacs.app
            as_root cp /Volumes/Emacs/Emacs.app /Applications/
            as_root ln --symbolic --force /usr/local/bin/emacs /Applications/Emacs.app/Contents/MacOS/Emacs
            as_root ln --symbolic --force /usr/local/bin/emacsclient /Applications/Emacs.app/Contents/MacOS/bin/emacsclient
            ;;
        *)
            echo "Error occurred when comparing new and old Emacs via mtree"
            hdiutil unmount /Volumes/Emacs
            exit 1
            ;;
    esac

    hdiutil unmount /Volumes/Emacs
    rm "$tempfile"
    rm "$temptreefile"
}

main() {
    if [ "$#" -lt 1 ]; then
        echo "Invalid number of arguments: expected at least 1, received $#"
        echo ""
        exit 1
    fi

    case "$1" in
        install)
            shift 1
            install "$@"
            ;;
        *)
            echo "$0: invalid command: $1"
            echo ""
            exit 1
            ;;
    esac
}

main "$@"
