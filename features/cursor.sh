#!/user/bin/env bash

set -euo pipefail

gremlin support as_root

get_cursor_bin() {
    case $(uname) in
        Linux)
            echo '/opt/cursor/squashfs-root/resources/app/bin/cursor'
            ;;
        Darwin)
            echo '/Applications/Cursor.app/Contents/Resources/app/bin/code'
            ;;
        *)
            echo 'Unknown OS'
            exit 1
            ;;
    esac
}

cursor_install_appimage() {
    local tempfile
    tempfile="$(mktemp --dry-run)"

    curl -o "$tempfile" https://downloader.cursor.sh/linux/appImage/x64

    as_root mkdir -p /opt/cursor
    as_root mv -f "$tempfile" /opt/cursor/Cursor.AppImage
    as_root chmod 755 /opt/cursor/Cursor.AppImage

    cd /opt/cursor
    as_root /opt/cursor/Cursor.AppImage --appimage-extract
    as_root chown -R $USER:$USER /opt/cursor/squashfs-root
    as_root chown root:root /opt/cursor/squashfs-root/chrome-sandbox
    as_root chmod 4755 /opt/cursor/squashfs-root/chrome-sandbox

    as_root ln --symbolic --force /opt/cursor/squashfs-root/resources/app/bin/cursor /usr/local/bin/cursor
}

cursor_write_desktop_file() {
    local tempfile
    tempfile="$(mktemp --dry-run)"

    # NOTE: A desktop file is included in the cursor AppImage but it's pretty
    # barebones.
    cat >"$tempfile" <<EOF
[Desktop Entry]
Name=Cursor
Exec=/opt/cursor/squashfs-root/cursor
Terminal=false
Type=Application
Icon=/opt/cursor/squashfs-root/cursor.png
StartupWMClass=Cursor
X-AppImage-Version=latest
MimeType=x-scheme-handler/cursor;
Categories=Utility;Development
EOF

    as_root mv -f "$tempfile" /usr/share/applications/cursor.desktop
    as_root chmod 644 /usr/share/applications/cursor.desktop
    as_root update-desktop-database
}

cursor_patch_script() {
    patch -p0 --ignore-whitespace /opt/cursor/squashfs-root/resources/app/bin/cursor <<'EOF'
--- /opt/cursor/squashfs-root/resources/app/bin/cursor 2025-01-19 17:00:57.742217120 -0500
+++ /opt/cursor/squashfs-root/resources/app/bin/cursor 2025-01-19 17:02:25.793505866 -0500
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

cursor_install_dmg() {
    local tempfile
    tempfile="$(mktemp --dry-run --suffix=.dmg)"

    curl -o "$tempfile" https://downloader.cursor.sh/mac/installer/universal
    hdiutil attach "$tempfile"
    as_root cp /Volumes/Cursor/Cursor.app /Applications/
    hdiutil unmount /Volumes/Cursor
    rm "$tempfile"

    as_root ln --symbolic --force /opt/cursor/squashfs-root/resources/app/bin/cursor /usr/local/bin/cursor
}

cursor_install() {
    case $(uname) in
        Linux)
            cursor_install_appimage
            cursor_patch_script
            cursor_write_desktop_file
            ;;
        Darwin)
            cursor_install_dmg
            ;;
        *)
            echo "Cursor not supported for operating system $(uname)"
            exit 1
            ;;
    esac
}

cursor_install_extension() {
    if [ "$#" -ne 1 ]; then
        echo "Invalid number of arguments: expected 1, received $#"
        exit 1
    fi

    local cursor_bin
    cursor_bin="$(get_cursor_bin)"

    if ! [[ -e "$cursor_bin" ]]; then
       echo "Cursor not installed at $(cursor_bin)"
       exit 1
    fi

    if $cursor_bin --list-extensions | grep "$1"; then
        echo "Cursor extension $1 is already installed."
        return
    fi

    $cursor_bin --install-extension $1
    echo "Cursor extension $1 installed."
}

cursor_main() {
    if [ "$#" -lt 1 ]; then
        echo "Invalid number of arguments: expected at least 1, received $#"
        echo ""
        exit 1
    fi

    case "$1" in
        install)
            shift 1
            cursor_install "$@"
            ;;
        install-extension)
            shift 1
            cursor_install_extension "$@"
            ;;
        *)
            echo "$0: invalid command: $1"
            echo ""
            exit 1
            ;;
    esac
}

cursor_main "$@"
