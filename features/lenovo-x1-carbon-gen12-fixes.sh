#!/usr/bin/env bash

set -euo pipefail

gremlin support apt_sources
gremlin support as_root
gremlin support compare_versions
gremlin support logmsg
gremlin support os_release

build_and_install_firmware_sof_backport() {
    local tempdir
    local version

    if dpkg-query --status firmware-sof-signed; then
        version=$(dpkg-query --status firmware-sof-signed | grep '^Version:' | grep -Eo '[0-9]+' | head -n1)
        if [[ $version -ge 2024 ]]; then
            logmsg info "FEAT lenovo-x1-carbon-gen12-fixes: Skipping custom backport of firmware-sof-signed as it is already version $version"
            return 0
        fi
    fi

    as_root apt-get install -y packaging-dev debian-keyring devscripts equivs

    if ! [[ -e /etc/apt/sources.list.d/testing-sources.list ]]; then
        printf "# Debian testing packages sources\ndeb-src https://deb.debian.org/debian/ testing main non-free-firmware" | as_root tee -a /etc/apt/sources.list.d/testing-sources.list > /dev/null
        as_root apt-get update
    fi

    tempdir="$(mktemp --directory --suffix=firmware-sof)"
    cd "$tempdir"
    apt-get source firmware-sof-signed/testing

    cd firmware-sof-*
    as_root mk-build-deps --install --remove
    dch --bpo --controlmaint 'backport newer audio drivers (sof-mtl.ri)'
    fakeroot debian/rules binary
    dpkg-buildpackage --build=binary --unsigned-changes
    cd ..

    as_root apt-get install ./firmware-sof-signed_*.deb
    rm -rf "$tempdir"
}

get_hardware_name() {
    sudo dmidecode --type 1 | grep Version | cut -c 11-
}

install_debian() {
    if [[ $(os_release version_id) != "12" ]]; then
        logmsg warn "FEAT lenovo-x1-carbon-gen12-fixes: Fixes are only supported for Debian 12 Bookworm, got version $(os_release version_id)"
        return 0
    fi

    apt_sources upsert deb https://deb.debian.org/debian bookworm non-free
    apt_sources upsert deb https://deb.debian.org/debian bookworm-backports main
    apt_sources upsert deb https://deb.debian.org/debian bookworm-backports contrib
    apt_sources upsert deb https://deb.debian.org/debian bookworm-backports non-free
    apt_sources upsert deb https://deb.debian.org/debian bookworm-backports non-free-firmware
    as_root apt-get update

    if compare_versions "$(uname -v | grep -Eo '[0-9]+(\.[0-9]+){2}')" -lt 6.11.10; then
        # Fixes: Newer kernel from backports for touchpad support
        as_root apt-get install -t bookworm-backports -y linux-image-6.11.10+bpo-amd64
        # TODO: install latest available kernel from backports instead of 6.11.10 specifically
    else
        logmsg "FEAT lenovo-x1-carbon-gen12-fixes: Skipping install of newer kernel from backports because current version $(uname -v | grep -Eo '[0-9]+(\.[0-9]+){2}') is at least 6.11.10"
    fi

    # Fixes:
    # - Newer version of iwlwifi (from backports) for wifi support
    # - Newer mesa, va drivers, et al to fix hardware acceleration for applications
    as_root apt-get install -y intel-media-va-driver-non-free
    as_root apt-get install -t bookworm-backports -y \
            firmware-iwlwifi \
            libegl-mesa0 \
            libgl1-mesa-dri \
            libglapi-mesa \
            libglu1-mesa \
            libglx-mesa0 \
            mesa-utils \
            mesa-utils-bin \
            mesa-va-drivers \
            mesa-vdpau-drivers \
            mesa-vulkan-drivers

    # Fixes: audio support
    build_and_install_firmware_sof_backport
}

install_linux() {
    if [[ $(get_hardware_name) != "ThinkPad X1 Carbon Gen 12" ]]; then
        logmsg warn "FEAT lenovo-x1-carbon-gen12-fixes: Fixes not supported for $(get_hardware_name)"
        return 0
    fi

    case $(os_release id) in
        debian)
            install_debian
            ;;
        *)
            logmsg warn "FEAT lenovo-x1-carbon-gen12-fixes: Fixes not supported for Linux distro $(os_release id)"
            return 0
            ;;
    esac
}

install_main() {
    case $(uname) in
        Linux)
            install_linux
            ;;
        *)
            logmsg fatal "FEAT lenovo-x1-carbon-gen12-fixes: unsupported operating system $(uname)."
            exit 1
            ;;
    esac
}

main() {
    if [ "$#" -lt 1 ]; then
        logmsg fatal "FEAT lenovo-x1-carbon-gen12-fixes: invalid number of arguments: expected at least 1, received $#"
        exit 1
    fi

    case "$1" in
        install)
            shift 1
            install_main "$@"
            ;;
        *)
            logmsg fatal "FEAT lenovo-x1-carbon-gen12-fixes: invalid command: $1"
            exit 1
            ;;
    esac
}

main "$@"
