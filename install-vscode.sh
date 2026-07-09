#!/usr/bin/env bash
#
# install-vscode.sh — Install or update VSCode, wired into apt so future
# `apt update && apt upgrade` keeps it current without re-running this script.
#
# Mechanism: add the official Microsoft apt repo + signing key once (idempotent),
# then `apt-get install -y code` (installs if missing, upgrades if a newer
# version exists; never downgrades).

set -euo pipefail

# --- Constants ----------------------------------------------------------------
readonly REPO_URL="https://packages.microsoft.com/repos/code"
readonly GPG_KEY_URL="https://packages.microsoft.com/keys/microsoft.asc"
readonly KEYRING_PATH="/etc/apt/keyrings/packages.microsoft.gpg"
readonly SOURCES_FILE="/etc/apt/sources.list.d/vscode.list"
readonly APT_LINE="deb [arch=amd64,arm64,armhf signed-by=${KEYRING_PATH}] ${REPO_URL} stable main"
readonly PKG_NAME="code"

## Colors — mirrors the cursor_setup.sh palette
readonly CLR_SCS="#16FF15" CLR_INF="#0095FF" CLR_PRI="#6B30DA"
readonly CLR_ERR="#FB5854" CLR_WRN="#FFDA33" CLR_BG="#131313" CLR_LGT="#F9F5E2"

# --- Logging helper (mirrors cursor_setup.sh logg()) --------------------------
logg() {
  local TYPE="$1" MSG="$2"
  local SYMBOL="" COLOR="" LABEL="" BGCOLOR=""
  local GUM_AVAILABLE
  GUM_AVAILABLE=$(command -v gum >/dev/null && echo true || echo false)
  case "$TYPE" in
    error)   SYMBOL="✖"; COLOR="$CLR_ERR"; LABEL=" ERROR ";  BGCOLOR="$CLR_ERR" ;;
    info)    SYMBOL="»"; COLOR="$CLR_INF" ;;
    prompt)  SYMBOL="▶"; COLOR="$CLR_PRI" ;;
    star)    SYMBOL="◆"; COLOR="$CLR_WRN" ;;
    success) SYMBOL="✔"; COLOR="$CLR_SCS" ;;
    warn)    SYMBOL="◆"; COLOR="$CLR_WRN"; LABEL=" WARNING "; BGCOLOR="$CLR_WRN" ;;
    *) echo "$MSG"; return ;;
  esac

  if $GUM_AVAILABLE; then
    local styled_msg
    styled_msg=$(gum style --foreground="$COLOR" "$SYMBOL")
    [[ -n "$LABEL" ]] && styled_msg+=" $(gum style --background="$BGCOLOR" --foreground="$CLR_BG" --bold "$LABEL")"
    styled_msg+=" $(gum style "$MSG")"
    echo "$styled_msg"
  else
    echo "${TYPE^^}: $MSG"
  fi
}

# --- Guard: must run as root (re-exec via sudo if not) ------------------------
require_root() {
  if [[ $EUID -ne 0 ]]; then
    logg info "Root privileges required. Re-launching with sudo..."
    exec sudo -E "$0" "$@"
  fi
}

# --- Guard: Debian/Ubuntu family only (apt + Microsoft .deb repo) -------------
validate_os() {
  local os_name
  os_name=$(grep -i '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
  grep -iqE "ubuntu|debian|linux mint|pop!_os|kubuntu|xubuntu|lubuntu|zorin|elementary" /etc/os-release || {
    logg error "This script targets Debian/Ubuntu and derivatives only. Detected: ${os_name}. Exiting."
    exit 1
  }
  logg success "Detected ${os_name}. System is compatible."
}

# --- Ensure the Microsoft repo + keyring are in place (idempotent) -------------
ensure_repo() {
  if [[ -f "$SOURCES_FILE" ]] && grep -qF "$REPO_URL" "$SOURCES_FILE"; then
    logg info "Microsoft VSCode repository is already configured."
    return 0
  fi

  logg prompt "Adding Microsoft GPG key and apt repository..."
  install -d -m 0755 "$(dirname "$KEYRING_PATH")"
  curl -fsSL "$GPG_KEY_URL" | gpg --dearmor --yes > "$KEYRING_PATH"
  chmod 0644 "$KEYRING_PATH"
  echo "$APT_LINE" > "$SOURCES_FILE"
  logg success "Repository added at ${SOURCES_FILE}."
}

# --- Main ---------------------------------------------------------------------
main() {
  require_root "$@"
  validate_os

  local was_installed=0
  if dpkg -s "$PKG_NAME" >/dev/null 2>&1; then
    was_installed=1
  fi

  ensure_repo

  export DEBIAN_FRONTEND=noninteractive
  logg prompt "Refreshing apt package index..."
  apt-get update -y

  if [[ $was_installed -eq 1 ]]; then
    logg prompt "Updating VSCode (apt will skip if already newest)..."
  else
    logg prompt "Installing VSCode..."
  fi
  apt-get install -y "$PKG_NAME"

  local version
  version=$(dpkg-query -W -f='${Version}' "$PKG_NAME" 2>/dev/null || echo "unknown")
  logg success "VSCode ${version} is installed."
  echo
  logg info "From now on, VSCode updates via:  sudo apt update && sudo apt upgrade"
  logg info "No need to re-run this script."
}

main "$@"
