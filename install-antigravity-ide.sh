#!/usr/bin/env bash
# install-antigravity-ide.sh
#
# Installs the Antigravity IDE Linux tarball into ~/Applications as a
# user-owned install, with a desktop launcher, icon, CLI symlink, and the
# desktop integrations VS Code's .deb would normally provide:
#   - "Open With > Antigravity IDE" in the file manager for folders and
#     text files (via .desktop MimeType)
#   - "Open in Antigravity IDE" right-click entry in Nautilus (via a small
#     python3-nautilus extension; GNOME / Nautilus only)
#   - antigravity-ide:// URL scheme handler
#
# Usage:
#   ./install-antigravity-ide.sh
#       (no argument: auto-download the latest Linux tarball for this arch
#        and install it. Needs curl, tar, python3.)
#   ./install-antigravity-ide.sh "/path/to/extracted/Antigravity IDE"
#       (use a tarball you already extracted; useful for updates.)
#
# Notes:
# - User-owned; no sudo for the app itself or for future updates.
# - On Ubuntu 24.04+ Chromium's user-namespace sandbox is blocked by AppArmor
#   by default. The script tries to install a one-time AppArmor profile
#   (this step needs sudo). If sudo isn't available or the profile fails to
#   load, it falls back to launching the IDE with --no-sandbox.
set -euo pipefail

# "" when installing from a pre-extracted dir; set to the resolved version
# when auto-downloading (drives the up-to-date skip + the version stamp).
version=""

SRC="${1:-}"

# No argument given: auto-download the latest Linux tarball for this arch.
if [ -z "$SRC" ]; then
    case "$(uname -m)" in
        x86_64|amd64) platform="linux-x64" ;;
        aarch64|arm64) platform="linux-arm" ;;
        *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
    esac
    for _dep in curl tar python3; do
        command -v "$_dep" >/dev/null 2>&1 || {
            echo "Missing dependency '$_dep' (needed to auto-download)." >&2; exit 1; }
    done

    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT
    dl_html="$tmpdir/download.html"
    dl_js="$tmpdir/bundle.js"
    archive="$tmpdir/Antigravity-IDE.tar.gz"

    download_page="https://antigravity.google/download"
    echo "Resolving the latest Antigravity IDE tarball..."
    curl -fsSL --compressed --retry 3 -o "$dl_html" "$download_page"
    main_js_url="$(python3 - "$dl_html" "$download_page" <<'PY'
import re, sys
from pathlib import Path
from urllib.parse import urljoin
html = Path(sys.argv[1]).read_text()
matches = re.findall(r'(?:src|href)="([^"]*main-[^"]+\.js)"', html)
if not matches:
    raise SystemExit("Could not find the Antigravity download bundle")
print(urljoin(sys.argv[2], matches[-1]))
PY
)"
    curl -fsSL --compressed --retry 3 -o "$dl_js" "$main_js_url"
    download_fields="$(python3 - "$dl_js" "$platform" <<'PY'
import re, sys
from pathlib import Path
bundle = Path(sys.argv[1]).read_text(errors="replace")
platform = sys.argv[2]
start = bundle.find('id:"antigravity-ide"')
end = bundle.find('},{name:"download",id:"antigravity-sdk"', start)
if start == -1 or end == -1:
    raise SystemExit("Could not find Antigravity IDE downloads in the bundle")
section = bundle[start:end]
m = re.search(r'href:"([^"]+/' + re.escape(platform) + r'/Antigravity%20IDE\.tar\.gz)"', section)
if not m:
    raise SystemExit(f"Could not find an IDE download for {platform}")
url = m.group(1)
vm = re.search(r'/stable/([^/]+)/', url)
print((vm.group(1).split("-", 1)[0] if vm else "unknown") + " " + url)
PY
)"
    read -r version download_url <<<"$download_fields"

    # Already up to date? Skip the (re)download entirely.
    installed_version_file="$HOME/Applications/antigravity-ide/.installed-version"
    if [ -f "$installed_version_file" ] \
       && [ "$(cat "$installed_version_file" 2>/dev/null || true)" = "$version" ]; then
        echo "Antigravity IDE ${version} is already installed. Nothing to do."
        exit 0
    fi

    echo "Downloading Antigravity IDE ${version} for ${platform}..."
    curl -fsSL --retry 3 -o "$archive" "$download_url"
    tar -xzf "$archive" -C "$tmpdir"
    SRC="$tmpdir/Antigravity IDE"
fi

if [ -z "$SRC" ] || [ ! -x "$SRC/antigravity-ide" ]; then
    echo "Usage: $0 [/path/to/extracted/Antigravity IDE]"
    echo "  (With no argument, it auto-downloads. Otherwise point it at an"
    echo "   extracted dir containing an executable 'antigravity-ide'.)"
    exit 1
fi
SRC="$(cd "$SRC" && pwd)"

APP_NAME="antigravity-ide"
APP_DISPLAY="Antigravity IDE"
BINARY="antigravity-ide"
DEST="$HOME/Applications/$APP_NAME"
ICON_DEST="$HOME/.local/share/icons/hicolor/512x512/apps/$APP_NAME.png"
DESKTOP="$HOME/.local/share/applications/$APP_NAME.desktop"
BIN_LINK="$HOME/.local/bin/$APP_NAME"

ICON_SRC="$SRC/resources/app/resources/linux/code.png"
if [ ! -f "$ICON_SRC" ]; then
    echo "Warning: expected icon at $ICON_SRC not found; launcher will have no icon."
    ICON_SRC=""
fi

# --- 1. Move app into ~/Applications --------------------------------------
mkdir -p "$(dirname "$DEST")" "$(dirname "$BIN_LINK")" \
         "$(dirname "$DESKTOP")" "$(dirname "$ICON_DEST")"
# Swap with rollback: move the current install aside, drop the new build
# in, and restore the old one if the new copy fails to land -- so a failed
# update never leaves you with nothing installed.
if [ -d "$DEST" ]; then
    rm -rf "$DEST.old"
    mv "$DEST" "$DEST.old"
fi
if ! mv "$SRC" "$DEST"; then
    echo "ERROR: failed to move the new build into $DEST." >&2
    if [ -d "$DEST.old" ]; then
        mv "$DEST.old" "$DEST"
        echo "Restored the previous Antigravity IDE." >&2
    fi
    exit 1
fi
rm -rf "$DEST.old"

# Stamp the installed version so the next run can skip a no-op re-download.
if [ -n "$version" ]; then
    printf '%s\n' "$version" >"$DEST/.installed-version" 2>/dev/null || true
fi

# --- 2. Install icon (resized down to 512x512 if ImageMagick available;
#       otherwise just install the original 1024x1024 PNG) -----------------
if [ -n "$ICON_SRC" ]; then
    ORIG_ICON="$DEST/resources/app/resources/linux/code.png"
    if command -v magick >/dev/null 2>&1; then
        magick "$ORIG_ICON" -resize 512x512 "$ICON_DEST"
    elif command -v convert >/dev/null 2>&1; then
        convert "$ORIG_ICON" -resize 512x512 "$ICON_DEST"
    else
        install -Dm644 "$ORIG_ICON" \
            "$HOME/.local/share/icons/hicolor/1024x1024/apps/$APP_NAME.png"
        install -Dm644 "$ORIG_ICON" "$ICON_DEST"
    fi
    gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
fi

# --- 3. Sandbox: try AppArmor profile, else fall back to --no-sandbox -----
EXEC_LINE="\"$DEST/$BINARY\" %F"
USERNS_RESTRICTED="$(cat /proc/sys/kernel/apparmor_restrict_unprivileged_userns 2>/dev/null || echo 0)"
if [ "$USERNS_RESTRICTED" = "1" ]; then
    PROFILE_NAME="userns-${APP_NAME}-${USER}"
    PROFILE_PATH="/etc/apparmor.d/${PROFILE_NAME}"
    PROFILE_BODY="abi <abi/4.0>,
include <tunables/global>

profile ${PROFILE_NAME} \"$DEST/$BINARY\" flags=(unconfined) {
  userns,
  include if exists <local/${PROFILE_NAME}>
}
"
    echo "Ubuntu AppArmor restricts unprivileged user namespaces."
    echo "Installing a one-time AppArmor profile so Chromium's sandbox works"
    echo "(requires sudo; updates afterwards will not need sudo)."
    if echo "$PROFILE_BODY" | sudo tee "$PROFILE_PATH" >/dev/null \
       && sudo apparmor_parser -r "$PROFILE_PATH"; then
        echo "AppArmor profile installed: $PROFILE_PATH"
    else
        echo "AppArmor profile install failed; using --no-sandbox in launcher."
        EXEC_LINE="\"$DEST/$BINARY\" --no-sandbox %F"
    fi
fi

# --- 4. Desktop launcher (registers as editor + URL handler) --------------
cat > "$DESKTOP" <<EOF
[Desktop Entry]
Name=$APP_DISPLAY
Comment=Code editor
GenericName=Text Editor
Exec=$EXEC_LINE
Icon=$APP_NAME
Terminal=false
Type=Application
Categories=Development;IDE;TextEditor;
StartupWMClass=$APP_NAME
MimeType=text/plain;inode/directory;application/x-antigravity-ide-workspace;x-scheme-handler/antigravity-ide;
Actions=new-empty-window;

[Desktop Action new-empty-window]
Name=New Empty Window
Exec=$EXEC_LINE --new-window
Icon=$APP_NAME
EOF
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

# --- 5. CLI symlink -------------------------------------------------------
ln -sf "$DEST/$BINARY" "$BIN_LINK"

# ~/.local/bin is not on PATH by default on Arch / minimal setups, so the
# symlink above would be unreachable until the user fixes it. Ensure it:
# no-op if already on PATH or already referenced in the shell rc; otherwise
# append once (with a marker) to the matching rc file.
ensure_local_bin_on_path() {
    case ":${PATH}:" in
        *":${HOME}/.local/bin:"*) return 0 ;;
    esac
    local rc=""
    case "${SHELL:-}" in
        */zsh) rc="$HOME/.zshrc" ;;
        */bash) rc="$HOME/.bashrc" ;;
        *) rc="$HOME/.profile" ;;
    esac
    if grep -qF "${HOME}/.local/bin" "$rc" 2>/dev/null; then
        return 0
    fi
    {
        printf '\n# Added by antigravity-ide installer\n'
        printf 'export PATH="${HOME}/.local/bin:${PATH}"\n'
    } >>"$rc"
    echo "Added ~/.local/bin to PATH in $rc"
    echo "Start a new terminal (or run: source $rc) to use 'antigravity-ide'."
}
ensure_local_bin_on_path

# --- 6. Register as the handler for antigravity-ide:// links --------------
xdg-mime default "$APP_NAME.desktop" x-scheme-handler/antigravity-ide 2>/dev/null || true

# --- 7. Nautilus "Open in Antigravity IDE" right-click entry --------------
# GNOME / Nautilus only. Requires python3-nautilus (offered via apt below).
# Skipped silently if nautilus is not the active file manager.
NAUTILUS_EXT_DIR="$HOME/.local/share/nautilus-python/extensions"
NAUTILUS_EXT_FILE="$NAUTILUS_EXT_DIR/antigravity-ide.py"

install_nautilus_extension() {
    if ! command -v nautilus >/dev/null 2>&1; then
        return 0  # not a Nautilus desktop, silently skip
    fi
    if ! dpkg -s python3-nautilus >/dev/null 2>&1; then
        echo
        echo "Nautilus 'Open in $APP_DISPLAY' menu entry needs the python3-nautilus"
        echo "package. Install it now? (sudo apt install python3-nautilus)"
        if [ -t 0 ]; then
            read -r -p "  [Y/n] " ans
        else
            ans="Y"
        fi
        case "${ans:-Y}" in
            [Nn]*) echo "Skipping Nautilus extension."; return 0 ;;
        esac
        sudo apt-get install -y python3-nautilus || {
            echo "Failed to install python3-nautilus; skipping Nautilus extension."
            return 0
        }
    fi

    mkdir -p "$NAUTILUS_EXT_DIR"
    cat > "$NAUTILUS_EXT_FILE" <<'PYEOF'
"""Nautilus right-click entry: Open in Antigravity IDE."""
import os
import subprocess
from urllib.parse import unquote, urlparse

import gi
for _v in ("4.1", "4.0", "3.0"):
    try:
        gi.require_version("Nautilus", _v)
        break
    except ValueError:
        continue
from gi.repository import GObject, Nautilus

APP_DISPLAY = "Antigravity IDE"
BINARY = os.path.expanduser("~/Applications/antigravity-ide/antigravity-ide")


def _local_path(file_info):
    parts = urlparse(file_info.get_uri())
    if parts.scheme != "file":
        return None
    return unquote(parts.path)


def _launch(paths):
    subprocess.Popen([BINARY, *paths], start_new_session=True)


class OpenInAntigravityIDE(GObject.GObject, Nautilus.MenuProvider):
    def _item(self, name, label, paths):
        item = Nautilus.MenuItem(name=name, label=label, tip=f"Open in {APP_DISPLAY}")
        item.connect("activate", lambda _i, _p=paths: _launch(_p))
        return item

    def get_file_items(self, files):
        paths = [p for p in (_local_path(f) for f in files) if p]
        if not paths:
            return []
        return [self._item("AntigravityIDE::open_files",
                           f"Open in {APP_DISPLAY}", paths)]

    def get_background_items(self, folder):
        path = _local_path(folder)
        if not path:
            return []
        return [self._item("AntigravityIDE::open_folder",
                           f"Open Folder in {APP_DISPLAY}", [path])]
PYEOF
    nautilus -q 2>/dev/null || true
    echo "Nautilus extension installed at $NAUTILUS_EXT_FILE"
    echo "(Nautilus has been restarted; open windows will reappear.)"
}
install_nautilus_extension

echo
echo "Installed $APP_DISPLAY -> $DEST"
echo "Launch from your application menu, or run: $APP_NAME"
echo "(If '$APP_NAME' is not found, add ~/.local/bin to your PATH or log out/in.)"
