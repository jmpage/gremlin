#!/usr/bin/env bash

set -euo pipefail

gremlin support as_root
gremlin support logmsg

get_alacritty_bin() {
    case $(uname) in
        Linux)
            echo alacritty
            ;;
        Darwin)
            logmsg fatal "FEAT alacritty: TODO: Not implemented"
            exit 1
            ;;
        *)
            logmsg fatal "FEAT alacritty: Unsupported operating system $(uname)."
            exit 1
            ;;
    esac
}

get_installed_version() {
    "$(get_alacritty_bin)" --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo ''
}

get_tag() {
    if [[ "$#" -eq 0 ]]; then
        curl -s https://api.github.com/repos/alacritty/alacritty/tags | jq --raw-output 'map(select(.name | contains("-rc") | not)) | first .name'
    else
        echo "v$1"
    fi
}

get_tarball_url() {
    curl -s https://api.github.com/repos/alacritty/alacritty/tags | jq --raw-output "map(select(.name == \"$1\")) | first .tarball_url"
}

install() {
    local
    tag="$(get_tag "$@")"

    logmsg debug "FEAT alacritty: requested version: $tag"
    logmsg debug "FEAT alacritty: installed version: v$(get_installed_version)"

    if [[ "$tag" == "v$(get_installed_version)" ]]; then
        logmsg info "FEAT alacritty: Install skipped as $tag is already installed."
        return 0
    fi

    case $(uname) in
        Linux)
            install_linux "$tag"
            ;;
        Darwin)
            install_dmg "$tag"
            ;;
        *)
            logmsg fatal "FEAT alacritty: unsupported operating system $(uname)."
            exit 1
            ;;
    esac
}

install_dmg() {
    local download_url
    local mtree_status
    local tempfile
    local temptreefile

    download_url="https://github.com/alacritty/alacritty/releases/download/$1/Alacritty-$1.dmg"

    tempfile="$(mktemp --dry-run --suffix=.dmg)"
    curl -o "$tempfile" "$download_url"
    hdiutil attach "$tempfile"

    temptreefile="$(mktemp --dry-run --suffix=.mtree)"
    mtree -c -K sha256digest -p /Applications/Alacritty.app > "$temptreefile"

    set +e
    mtree_status=$(mtree -p /Volumes/Alacritty/Alacritty.app < "$temptreefile"; echo $?)
    set -e
    case "$mtree_status" in
        0)
            logmsg debug "FEAT alacritty: already matches installed version"
            ;;
        2)
            as_root rm -rf /Applications/Alacritty.app
            as_root cp /Volumes/Alacritty/Alacritty.app /Applications/
            ;;
        *)
            logmsg fatal "FEAT alacritty: Unexpected error occurred when comparing new and old Alacritty via mtree"
            hdiutil unmount /Volumes/Alacritty
            exit 1
            ;;
    esac

    hdiutil unmount /Volumes/Alacritty
    rm "$tempfile"
    rm "$temptreefile"
}

install_linux() {
    local tag
    local tempfile
    local tempdir

    tag="$1"

    install_linux_build_dependencies

    tempfile="$(mktemp --dry-run --suffix=.tar.gz)"
    tempdir="$(mktemp --directory --suffix=-alacritty-src)"
    curl -L -o "$tempfile" "$(get_tarball_url "$tag")"
    tar -xzf "$tempfile" -C "$tempdir"

    # Assumption: there is only one directory in the tarball
    cd "$tempdir/$(ls "$tempdir")"

    gremlin feature asdf execute asdf set rust latest
    gremlin feature asdf execute cargo build --release

    as_root cp ./target/release/alacritty /usr/local/bin/
    as_root chown root:root /usr/local/bin/alacritty
    as_root chmod 0755 /usr/local/bin/alacritty

    as_root tic -xe alacritty,alacritty-direct ./extra/alacritty.info

    as_root cp ./extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
    as_root chown root:root /usr/share/pixmaps/Alacritty.svg
    as_root chmod 0644 /usr/share/pixmaps/Alacritty.svg

    as_root desktop-file-install ./extra/linux/Alacritty.desktop
    as_root update-desktop-database

    as_root mkdir -p /usr/local/share/man/man1
    as_root mkdir -p /usr/local/share/man/man5

    scdoc < extra/man/alacritty.1.scd | gzip -c | as_root tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
    scdoc < extra/man/alacritty-msg.1.scd | gzip -c | as_root tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
    scdoc < extra/man/alacritty.5.scd | gzip -c | as_root tee /usr/local/share/man/man5/alacritty.5.gz > /dev/null
    scdoc < extra/man/alacritty-bindings.5.scd | gzip -c | as_root tee /usr/local/share/man/man5/alacritty-bindings.5.gz > /dev/null

    #as_root chmod 0644 /usr/local/share/man/man1/alacritty.1.gz

    rm -rf "$tempdir"
    rm "$tempfile"
}

install_linux_build_dependencies() {
    as_root apt-get install -y \
            cmake \
            pkg-config \
            libfreetype6-dev \
            libfontconfig1-dev \
            libxcb-xfixes0-dev \
            libxkbcommon-dev \
            python3 \
            gzip \
            scdoc

    gremlin feature asdf install
    gremlin feature asdf run plugin add rust
    gremlin feature asdf run install rust latest
}

main() {
    if [ "$#" -lt 1 ]; then
        logmsg fatal "FEAT alacritty: invalid number of arguments: expected at least 1, received $#"
        exit 1
    fi

    case "$1" in
        install)
            shift 1
            install "$@"
            ;;
        *)
            logmsg fatal "FEAT alacritty: invalid command: $1"
            exit 1
            ;;
    esac
}

main "$@"
