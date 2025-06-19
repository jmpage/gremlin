#!/usr/bin/env bash

set -euo pipefail

gremlin support as_root
gremlin support logmsg

get_cursor_bin() {
    case $(uname) in
        Linux)
            echo '/opt/cursor/squashfs-root/resources/app/bin/cursor'
            ;;
        Darwin)
            echo '/Applications/Cursor.app/Contents/Resources/app/bin/code'
            ;;
        *)
            logmsg fatal "FEAT cursor: unsupported operating system $(uname)."
            exit 1
            ;;
    esac
}

install_appimage() {
    local tempfile
    tempfile="$(mktemp --dry-run)"

    local download_url
    download_url="$(curl --silent 'https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable' | jq --raw-output '.downloadUrl')"

    curl -o "$tempfile" "$download_url"

    as_root mkdir -p /opt/cursor
    as_root mv -f "$tempfile" /opt/cursor/Cursor.AppImage
    as_root chmod 755 /opt/cursor/Cursor.AppImage

    cd /opt/cursor
    as_root rm -rf /opt/cursor/squashfs-root
    as_root /opt/cursor/Cursor.AppImage --appimage-extract
    as_root chown -R "$USER:$USER" /opt/cursor/squashfs-root

    as_root ln --symbolic --force /opt/cursor/squashfs-root/usr/share/cursor/resources/linux/bin/cursor /usr/local/bin/cursor
}

install_macos() {
    local tempfile
    tempfile="$(mktemp --dry-run --suffix=.dmg)"

    local download_url
    download_url="$(curl --silent 'https://www.cursor.com/api/download?platform=darwin-universal&releaseTrack=stable' | jq --raw-output '.downloadUrl')"

    curl -o "$tempfile" "$download_url"

    hdiutil attach "$tempfile"
    as_root cp /Volumes/Cursor/Cursor.app /Applications/
    hdiutil unmount /Volumes/Cursor
    rm "$tempfile"

    as_root ln --symbolic --force /opt/cursor/squashfs-root/resources/app/bin/cursor /usr/local/bin/cursor
}

install_extension() {
    if [ "$#" -ne 1 ]; then
        logmsg fatal "FEAT cursor: invalid number of arguments: expected 1, received $#"
        exit 1
    fi

    local cursor_bin
    cursor_bin="$(get_cursor_bin)"

    if ! [[ -e "$cursor_bin" ]]; then
       logmsg fatal "FEAT cursor: cursor not found at $(cursor_bin)"
       exit 1
    fi

    if $cursor_bin --list-extensions | grep "$1"; then
        logmsg info "FEAT cursor: Skipping installation of extension $1 as it is already installed."
        return
    fi

    $cursor_bin --install-extension "$1"
    logmsg info "FEAT cursor: extension $1 installed."
}

install_main() {
    case $(uname) in
        Linux)
            install_appimage
            patch_script
            write_desktop_file
            ;;
        Darwin)
            install_macos
            ;;
        *)
            logmsg fatal "FEAT cursor: unsupported operating system $(uname)."
            exit 1
            ;;
    esac
}

main() {
    if [ "$#" -lt 1 ]; then
        logmsg fatal "FEAT cursor: invalid number of arguments: expected at least 1, received $#"
        exit 1
    fi

    case "$1" in
        install)
            shift 1
            install_main "$@"
            ;;
        install-extension)
            shift 1
            install_extension "$@"
            ;;
        *)
            logmsg fatal "FEAT cursor: invalid command: $1"
            exit 1
            ;;
    esac
}

patch_script() {
    patch -p0 --ignore-whitespace /opt/cursor/squashfs-root/usr/share/cursor/resources/linux/bin/cursor <<'EOF'
--- /opt/cursor/squashfs-root/usr/share/cursor/resources/linux/bin/cursor 2025-06-19 16:00:57.742217120 -0500
+++ /opt/cursor/squashfs-root/usr/share/cursor/resources/linux/bin/cursor 2025-06-19 16:02:25.793505866 -0500
@@ -46,11 +46,11 @@

 if [ ! -L "$0" ]; then
        # if path is not a symlink, find relatively
-       VSCODE_PATH="$(dirname "$0")/.."
+       VSCODE_PATH="$(dirname "$0")/../../.."
 else
        if command -v readlink >/dev/null; then
                # if readlink exists, follow the symlink and find relatively
-               VSCODE_PATH="$(dirname "$(readlink -f "$0")")/.."
+               VSCODE_PATH="$(dirname "$(readlink -f "$0")")/../../.."
        else
                # else use the standard install location
                VSCODE_PATH="/usr/share/cursor"
EOF
}

write_desktop_file() {
    local tempfile
    tempfile="$(mktemp --dry-run)"

    cat >"$tempfile" <<EOF
[Desktop Entry]
Name=Cursor
Comment=The AI Code Editor.
GenericName=Text Editor
Exec=/opt/cursor/squashfs-root/AppRun
Terminal=false
Type=Application
Icon=/opt/cursor/squashfs-root/co.anysphere.cursor.png
StartupNotify=false
StartupWMClass=Cursor
MimeType=application/x-cursor-workspace;
Categories=TextEditor;Development;IDE;
Keywords=cursor;
EOF

    as_root mv -f "$tempfile" /usr/share/applications/cursor.desktop
    as_root chmod 644 /usr/share/applications/cursor.desktop
    as_root update-desktop-database
}

main "$@"
