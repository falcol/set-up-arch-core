#!/usr/bin/env bash

set -euo pipefail

# Constants
readonly SCRIPT_ALIAS_NAME="cursor-setup"
readonly DOWNLOAD_DIR="$HOME/.AppImage"
readonly ICON_DIR="$HOME/.local/share/icons"
readonly USER_DESKTOP_FILE="$HOME/Desktop/cursor.desktop"
# readonly DOWNLOAD_URL="https://downloader.cursor.sh/linux/appImage/x64"
readonly CURSOR_API_ENDPOINT="https://cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
readonly ICON_URL="https://mintlify.s3-us-west-1.amazonaws.com/cursor/images/logo/app-logo.svg"
readonly VERSION_CHECK_TIMEOUT=5 # in seconds | if you have a slow connection, increase this value to 10, 15, or more
readonly SPINNERS=("meter" "line" "dot" "minidot" "jump" "pulse" "points" "globe" "moon" "monkey" "hamburger")
readonly SPINNER="${SPINNERS[0]}"
readonly DEPENDENCIES=("gum" "curl" "wget" "pv" "bc" "find:findutils" "chmod:coreutils" "timeout:coreutils" "mkdir:coreutils" "apparmor_parser:apparmor-utils")
readonly GUM_VERSION_REQUIRED="0.14.5"
readonly SYSTEM_DESKTOP_FILE="$HOME/.local/share/applications/cursor.desktop"
readonly APPARMOR_PROFILE="/etc/apparmor.d/cursor-appimage"
readonly RC_FILES=("bash:$HOME/.bashrc" "zsh:$HOME/.zshrc")
SCRIPT_PATH="$HOME/cursor-setup-wizard/cursor_setup.sh"
## Colors used for UI feedback and styling
readonly CLR_SCS="#16FF15"
readonly CLR_INF="#0095FF"
readonly CLR_BG="#131313"
readonly CLR_PRI="#6B30DA"
readonly CLR_ERR="#FB5854"
readonly CLR_WRN="#FFDA33"
readonly CLR_LGT="#F9F5E2"

# Variables
sudo_pass=""

local_name=""
local_size=""
local_version=""
local_path=""
local_md5=""

remote_name=""
remote_size=""
remote_version=""
remote_md5=""

# Utility Functions
validate_os() {
  local os_name
  spinner "Checking system compatibility..." "sleep 1"
  os_name=$(grep -i '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
  grep -iqE "ubuntu|kubuntu|xubuntu|lubuntu|pop!_os|elementary|zorin|linux mint" /etc/os-release || {
    logg error "$(printf "\n   This script is designed exclusively for Ubuntu and its popular derivatives.\n   Detected: %s. \n   Exiting..." "$os_name")"; exit 1
  }
  logg success "$(echo -e "Detected $os_name (Ubuntu or derivative). System is compatible.")"
}

install_script_alias() {
  local alias_command="alias ${SCRIPT_ALIAS_NAME}=\"$SCRIPT_PATH\"" alias_added=false
  for entry in "${RC_FILES[@]}"; do
    local shell_name="${entry%%:*}" rc_file="${entry#*:}"
    if [[ -f "$rc_file" ]] && ! grep -Fxq "$alias_command" "$rc_file"; then
      echo -e "\n\n# This alias runs the Cursor Setup Wizard, simplifying installation and configuration.\n# For more details, visit: https://github.com/jorcelinojunior/cursor-setup-wizard\n$alias_command\n" >>"$rc_file"
      alias_added=true
      [[ "$(basename "$SHELL")" == "$shell_name" ]] && { echo " 🏷️  Adding the alias \"${SCRIPT_ALIAS_NAME}\" to the current shell..."; $(basename "$SHELL") -c "source $rc_file"; }
    fi
  done
  if [[ "$alias_added" == true ]]; then
    echo -e "\n   # The alias \"${SCRIPT_ALIAS_NAME}\" has been successfully added! ✨"
    echo "   # Open a new terminal to run the script \"Cursor Setup Wizard\""
    echo "   # using the following command:"
    echo "     ╭────────────────────╮"
    echo "     │  $ ${SCRIPT_ALIAS_NAME}    │"
    echo "     ╰────────────────────╯"
    echo ""
    read -rp "   Press any key to close this terminal..." -n1
    kill -9 $PPID
  else
    logg success "The alias '${SCRIPT_ALIAS_NAME}' is already configured. No changes were made."
  fi
}

check_and_install_dependencies() {
  spinner "Checking dependencies..." "sleep 1"
  local missing_packages=()
  for dep_info in "${DEPENDENCIES[@]}"; do
    local dep="${dep_info%%:*}" package="${dep_info#*:}"
    [[ "$package" == "$dep" ]] && package=""
    command -v "$dep" >/dev/null 2>&1 || missing_packages+=("${package:-$dep}")
  done

  local gum_installed_version
  if command -v gum >/dev/null 2>&1; then
    gum_installed_version=$(gum --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+')
    if [[ "$gum_installed_version" != "$GUM_VERSION_REQUIRED" ]]; then
      logg warn "Detected gum version $gum_installed_version. Downgrading to the more stable version $GUM_VERSION_REQUIRED due to known issues installed version."
      missing_packages+=("gum=$GUM_VERSION_REQUIRED")
    fi
  else
    missing_packages+=("gum=$GUM_VERSION_REQUIRED")
  fi

  if [[ "${#missing_packages[@]}" -gt 0 ]]; then
    logg prompt "Installing or downgrading: ${missing_packages[*]}"
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
    sudo apt update -y && sudo apt install -y --allow-downgrades "${missing_packages[@]}"
  fi
  logg success "All dependencies are good to go!"
}

show_banner() { clear; gum style --border double --border-foreground="$CLR_PRI" --margin "1 0 2 2" --padding "1 3" --align center --foreground="$CLR_LGT" --background="$CLR_BG" "$(echo -e "🧙 Welcome to the Cursor Setup Wizard! 🎉\n 📡 Effortlessly fetch, download, and configure Cursor. 🔧")"; }

show_balloon() { gum style --border double --border-foreground="$CLR_PRI" --margin "1 2" --padding "1 1" --align center --foreground="$CLR_LGT" "$1"; }

nostyle() {
  echo "$1" | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g'
}

edit_this_script() {
  local editors=("cursor:CursorAi" "code:Visual Studio Code" "gedit:Gedit" "nano:Nano")
  spinner "Opening the script in your default editor..." "sleep 2"
  for e in "${editors[@]}"; do
    local cmd="${e%%:*}" name="${e#*:}"
    command -v "$cmd" >/dev/null 2>&1 && { logg success "$(echo -e "\n    The script is now open in $name. Make your changes and save the file.\n    Remember to close the current script and reopen it with the \n    command 'cursor-setup' to see your changes.")"; "$cmd" "$SCRIPT_PATH"; return 0; }
  done
  logg error "No suitable editor found to open the script."; return 1
}

extract_version() {
  [[ "$1" =~ ([0-9]+\.[0-9]+\.[0-9]+) ]] && { echo "${BASH_REMATCH[1]}"; return 0; }
  echo "Error: No version found in filename" >&2; return 1
}

convert_to_mb() { printf "%.2f MB" "$(bc <<< "scale=2; $1 / 1048576")"; }

spinner() {
  local title="$1" command="$2" chars="|/-\\" i=0
  command -v gum >/dev/null 2>&1 && gum spin --spinner "$SPINNER" --spinner.foreground="$CLR_SCS" --title "$(gum style --bold "$title")" -- bash -c "$command" || {
    printf "%s " "$title"; bash -c "$command" & local pid=$!
    while kill -0 $pid 2>/dev/null; do printf "\r%s %c" "$title" "${chars:i++%${#chars}}"; sleep 0.1; done
    printf "\r\033[K"
  }
}

sudo_please() {
  while true; do
    [[ -z "$sudo_pass" ]] && sudo_pass=$(gum input --password --placeholder "Please enter your 'sudo' password: " --header=" 🛡️  Let's keep things secure. " --header.foreground="$CLR_LGT" --header.background="$CLR_PRI" --header.margin="1 0 1 2" --header.align="center" --cursor.background="$CLR_LGT" --cursor.foreground="$CLR_PRI" --prompt="🗝️  ")
    echo "$sudo_pass" | sudo -S -k true >/dev/null 2>&1 && break
    logg error "Oops! The password was incorrect. Try again."; sudo_pass=""
  done
}

logg() {
  local TYPE="$1" MSG="$2"
  local SYMBOL="" COLOR="" LABEL="" BGCOLOR="" FG=""
  GUM_AVAILABLE=$(command -v gum >/dev/null && echo true || echo false)
  case "$TYPE" in
    error) SYMBOL="$(echo -e "\n ✖")"; COLOR="$CLR_ERR"; LABEL=" ERROR "; BGCOLOR="$CLR_ERR"; FG="--foreground=$CLR_BG" ;;
    info) SYMBOL=" »"; COLOR="$CLR_INF" ;;
    md) command -v glow >/dev/null && glow "$MSG" || cat "$MSG"; return ;;
    prompt) SYMBOL=" ▶"; COLOR="$CLR_PRI" ;;
    star) SYMBOL=" ◆"; COLOR="$CLR_WRN" ;;
    start|success) SYMBOL=" ✔"; COLOR="$CLR_SCS" ;;
    warn) SYMBOL="$(echo -e "\n ◆")"; COLOR="$CLR_WRN"; LABEL=" WARNING "; BGCOLOR="$CLR_WRN"; FG="--foreground=$CLR_BG" ;;
    *) echo "$MSG"; return ;;
  esac
  { $GUM_AVAILABLE && gum style "$(gum style --foreground="$COLOR" "$SYMBOL") $(gum style --bold ${BGCOLOR:+--background="$BGCOLOR"} ${FG:-} "${LABEL:-}") $(gum style "$MSG")"; } || { echo "${TYPE^^}: $MSG"; }
  return 0
}

fetch_remote_version() {
  logg prompt "Fetching latest Cursor release metadata from official API..."
  local api_response

  api_response=$(spinner "Querying Cursor API..." "curl -s \"$CURSOR_API_ENDPOINT\"")

  if [[ -z "$api_response" ]]; then
    logg error "Failed to fetch data from Cursor API. Check your internet connection or try again later."
    return 1
  fi

  DOWNLOAD_URL=$(echo "$api_response" | jq -r '.downloadUrl')
  remote_version=$(echo "$api_response" | jq -r '.version')
  remote_name=$(basename "$DOWNLOAD_URL")
  # remote_version=$(extract_version "$remote_name")
  remote_md5="N/A"  # API doesn't return this
  remote_size="0"   # Unknown until downloaded

  if [[ -z "$DOWNLOAD_URL" || "$DOWNLOAD_URL" == "null" ]]; then
    logg error "API did not return a valid download URL."
    return 1
  fi

  logg success "Latest release metadata retrieved:"
  logg info "$(printf "  → Name: %s\n  → Version: %s\n  → Download URL: %s\n" "$remote_name" "$remote_version" "$DOWNLOAD_URL")"
}


find_local_version() {
  show_log=${1:-false}
  [[ $show_log == true ]] && spinner "Searching for a local version..." "sleep 2;"
  mkdir -p "$DOWNLOAD_DIR"
  local_path=$(find "$DOWNLOAD_DIR" -maxdepth 1 -type f -name 'Cursor-*.AppImage' -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -n 1 | cut -d' ' -f2-)
  if [[ -n "$local_path" ]]; then
    local_name=$(basename "$local_path")
    local_size=$(stat -c %s "$local_path" 2>/dev/null || echo "0")
    local_version=$(extract_version "$local_path")
    local_md5=$(md5sum "$local_path" | cut -d' ' -f1)
    [[ $show_log == true ]] && logg info "$(printf "Local version found:\n      - name: %s\n      - version: %s\n      - size: %s\n      - MD5 Hash: %s\n      - path: %s\n" "$local_name" "$local_version" "$(convert_to_mb "$local_size")" "$local_md5" "$local_path")"
    return 0
  fi
  [[ $show_log == true ]] && logg error "$(echo -e "No local version found in $DOWNLOAD_DIR\n   Go back to the menu and fetch it first.")"
  return 1
}

download_logo() {
  logg prompt "Getting the Cursor logo ready..."
  mkdir -p "$ICON_DIR"
  if spinner "Downloading the logo..." "sleep 1 && curl -s -o \"$ICON_DIR/cursor-icon.svg\" \"$ICON_URL\""; then
    logg success "Logo successfully downloaded to: $ICON_DIR/cursor-icon.svg"
  else
    logg error "Failed to download the logo. Please check your connection."
  fi
}

download_appimage() {
  logg prompt "Starting the download of the latest version..."
  mkdir -p "$DOWNLOAD_DIR"

  logg info "Fetching latest download URL from Cursor API..."
  DOWNLOAD_URL=$(curl -s "$CURSOR_API_ENDPOINT" | jq -r '.downloadUrl')
  if [[ -z "$DOWNLOAD_URL" || "$DOWNLOAD_URL" == "null" ]]; then
    logg error "Failed to retrieve the AppImage URL from API. Please check your network or API availability."
    return 1
  fi

  remote_name=$(basename "$DOWNLOAD_URL")
  output_document="$DOWNLOAD_DIR/$remote_name"

  logg info "Downloading: $remote_name"
  if command -v wget >/dev/null; then
    spinner "Downloading AppImage..." \
      "wget --quiet --show-progress -O \"$output_document\" \"$DOWNLOAD_URL\""
  elif command -v curl >/dev/null; then
    spinner "Downloading AppImage..." \
      "curl -L \"$DOWNLOAD_URL\" -o \"$output_document\""
  else
    logg error "Neither wget nor curl is available. Please install one of them."
    return 1
  fi

  chmod +x "$output_document"
  local_path="$output_document"
  local_name=$(basename "$local_path")
  local_size=$(stat -c %s "$local_path" 2>/dev/null || echo "0")
  local_version=$(extract_version "$local_name")
  local_md5=$(md5sum "$local_path" | cut -d' ' -f1)

  logg success "Download complete!"
  logg info "  → Path: $local_path"
  logg info "  → Version: $local_version"
  logg info "  → Size: $(convert_to_mb "$local_size")"
}


setup_launchers() {
  local error=false
  logg prompt "Creating desktop launchers for Cursor..."
  for file_path in "$SYSTEM_DESKTOP_FILE" "$USER_DESKTOP_FILE"; do
    if spinner "Creating launcher at $file_path" "sleep 1 && echo '[Desktop Entry]
Type=Application
Name=Cursor
GenericName=Intelligent, fast, and familiar, Cursor is the best way to code with AI.
Exec=$local_path
Icon=$ICON_DIR/cursor-icon.svg
X-AppImage-Version=$local_version
Categories=Utility;Development
StartupWMClass=Cursor
Terminal=false
Comment=Cursor is an AI-first coding environment for software development.
Keywords=cursor;ai;code;editor;ide;artificial;intelligence;learning;programming;developer;development;software;engineering;productivity;vscode;sublime;coding;gpt;openai;copilot;
MimeType=x-scheme-handler/cursor;' > \"$file_path\""; then
      logg success "Launcher created: $file_path"
    fi
    if spinner "Setting execution permissions for $file_path" "sleep 1 && chmod +x \"$file_path\""; then
      logg success "Permissions set: $file_path"
    else
      logg error "Failed to set permissions for $file_path"
      error=true
    fi
    if spinner "Marking launcher as trusted" "sleep 1 && dbus-launch gio set \"$file_path\" \"metadata::trusted\" true"; then
      logg success "Launcher marked as trusted: $file_path"
    else
      logg error "Failed to mark $file_path as trusted"
      error=true
    fi
  done
  if [ "$error" = false ]; then
    logg success "All desktop launchers created successfully!"
    return 0
  else
    logg warn "Some launchers could not be created. Please check the error messages above."
  fi
}

configure_apparmor() {
  logg prompt "Setting up AppArmor configuration..."
  sudo_please
  if ! systemctl is-active --quiet apparmor; then
    logg warn "AppArmor is not active. Enabling and starting the service..."
    spinner "Enabling and starting AppArmor" "sudo -S <<< \"$sudo_pass\" systemctl enable apparmor && sudo -S <<< \"$sudo_pass\" systemctl start apparmor"
    logg success "AppArmor service started and enabled."
  fi
  sudo -S <<< "$sudo_pass" bash -c "printf 'abi <abi/4.0>,\ninclude <tunables/global>\n\nprofile cursor \"%s\" flags=(unconfined) {\n  userns,\n  include if exists <local/cursor>\n}\n' \"$local_path\" > \"$APPARMOR_PROFILE\""
  if spinner "Applying AppArmor profile" "sleep 2 && sudo -S <<< \"$sudo_pass\" apparmor_parser -r \"$APPARMOR_PROFILE\""; then
    logg success "AppArmor profile successfully applied!"
  else
    logg error "Couldn't apply AppArmor profile. Check your system configuration."
  fi
}

add_cli_command() {
  logg prompt "Adding the 'cursor' command to your system..."

  local cli_path="/usr/local/bin/cursor"
  local tmp_script="$HOME/.cursor_tmp_script.sh"

  sudo_please

  # Write script content to temporary file
  cat > "$tmp_script" <<EOF
#!/bin/bash

APPIMAGE_PATH="$local_path"

if [[ ! -f "\$APPIMAGE_PATH" ]]; then
  echo "Error: Cursor AppImage not found at \$APPIMAGE_PATH" >&2
  exit 1
fi

"\$APPIMAGE_PATH" --no-sandbox "\$@" &
EOF

  # Create target dir & move script with sudo
  echo "$sudo_pass" | sudo -S mkdir -p /usr/local/bin
  echo "$sudo_pass" | sudo -S mv "$tmp_script" "$cli_path"
  echo "$sudo_pass" | sudo -S chmod +x "$cli_path"

  logg success "The 'cursor' command has been added at: $cli_path"
  logg info "Try it now:  cursor .   or   cursor /path/to/project"
}

# NEW FUNCTION: Update Cursor
update_cursor() {
  logg prompt "Checking for Cursor updates..."

  # Find local version first
  if ! find_local_version; then
    logg error "No local Cursor installation found. Please use 'All-in-One' option to install first."
    return 1
  fi

  logg info "Current installed version: $local_version"

  # Fetch remote version
  if ! fetch_remote_version; then
    logg error "Failed to fetch remote version information."
    return 1
  fi

  # Compare versions
  if [[ "$local_version" == "$remote_version" ]]; then
    show_balloon "$(echo -e "🎉 You're already up to date! 🎈\n✨ Current version: $local_version\n🌟 No update needed. Happy coding! 💻")"
    return 0
  fi

  logg info "Update available!"
  logg info "  → Current version: $local_version"
  logg info "  → Latest version: $remote_version"

  # Ask user if they want to update
  if gum confirm "Do you want to update to version $remote_version?" --show-help --prompt.foreground="$CLR_INF" --selected.background="$CLR_PRI"; then
    # Backup old version
    local backup_path="${local_path}.backup-$(date +%Y%m%d-%H%M%S)"
    logg prompt "Creating backup of current version..."
    if spinner "Backing up current version" "mv \"$local_path\" \"$backup_path\""; then
      logg success "Backup created: $backup_path"
    else
      logg warn "Failed to create backup, but continuing with update..."
    fi

    # Download new version
    if download_appimage; then
      # Update launchers with new version
      setup_launchers
      # Update CLI command with new path
      add_cli_command
      # Update AppArmor profile if it exists
      if [[ -f "$APPARMOR_PROFILE" ]]; then
        configure_apparmor
      fi

      show_balloon "$(echo -e "🎉 Update completed successfully! 🎈\n✨ Updated from $local_version to $remote_version\n🗑️  Old version backed up to:\n   $(basename "$backup_path")\n🌟 Ready to use the latest Cursor! 💻")"

      # Ask if user wants to remove backup
      if gum confirm "Remove the backup file to save space?" --show-help --prompt.foreground="$CLR_WRN" --selected.background="$CLR_PRI"; then
        if rm -f "$backup_path"; then
          logg success "Backup file removed successfully."
        else
          logg warn "Failed to remove backup file. You can manually delete it later."
        fi
      fi
    else
      # Restore backup if download failed
      if [[ -f "$backup_path" ]]; then
        logg warn "Download failed. Restoring backup..."
        mv "$backup_path" "$local_path"
        logg success "Backup restored. Your previous version is still available."
      fi
      return 1
    fi
  else
    logg info "Update cancelled by user."
  fi
}

menu() {
  local option
  show_banner
  while true; do
    all_in_one=$(gum style --foreground="$CLR_LGT" --bold "All-in-One (fetch, download & configure all)")
    update_cursor=$(gum style --foreground="$CLR_LGT" --bold "Update Cursor (check & update to latest version)")
    reconfigure_all=$(gum style --foreground="$CLR_LGT" --bold "Reconfigure All (no online fetch)")
    setup_apparmor=$(gum style --foreground="$CLR_LGT" --bold "Setup AppArmor Profile")
    add_cli_command=$(gum style --foreground="$CLR_LGT" --bold "Add 'cursor' CLI Command (bash/zsh)")
    edit_script=$(gum style --foreground="$CLR_LGT" --bold "Edit This Script")
    _exit=$(gum style --foreground="$CLR_LGT" --italic "Exit")
    option=$(echo -e "$all_in_one\n$update_cursor\n$reconfigure_all\n$setup_apparmor\n$add_cli_command\n$edit_script\n$_exit" | gum choose --header "🧙 Pick what you'd like to do next:" --header.margin="0 0 0 2" --header.border="rounded" --header.padding="0 2 0 2" --header.italic --header.foreground="$CLR_LGT" --cursor=" ➤ " --cursor.foreground="$CLR_ERR" --cursor.background="$CLR_PRI" --selected.foreground="$CLR_LGT" --selected.background="$CLR_PRI")
    case "$option" in
      "$(nostyle "$all_in_one")")
        fetch_remote_version
        if ! find_local_version || [[ "$local_md5" != "$remote_md5" ]]; then
          download_appimage
          download_logo
          setup_launchers
          configure_apparmor
          add_cli_command
        else
          find_local_version true
          show_balloon "$(echo -e "🧙 The latest version is already installed and ready to use! 🎈\n🌟 Ready to start coding? Let's build something amazing! 💻")"
        fi
        ;;
      "$(nostyle "$update_cursor")")
        update_cursor
        ;;
      "$(nostyle "$reconfigure_all")")
        if find_local_version true; then
          download_logo
          setup_launchers
          configure_apparmor
          add_cli_command
        fi
        ;;
      "$(nostyle "$setup_apparmor")")
        if find_local_version true; then
          configure_apparmor
        fi
        ;;
      "$(nostyle "$add_cli_command")")
        if find_local_version true; then
          add_cli_command
        fi
        ;;
      "$(nostyle "$edit_script")")
        edit_this_script
        ;;
      "$(nostyle "$_exit")")
          if gum confirm "Are you sure you want to exit?" --show-help --prompt.foreground="$CLR_WRN" --selected.background="$CLR_PRI"; then
            clear;
            gum style --border double --border-foreground="$CLR_PRI" --padding "1 3" --margin "1 2" --align center --background "$CLR_BG" --foreground "$CLR_LGT" "$(echo -e "🎩🪄 Thanks for stopping by! Happy coding with Cursor!\n\n Enjoyed this tool? Support it and keep the magic alive!\n☕ Buy me a coffee 🤗\n $(gum style  --foreground="$CLR_WRN" "https://buymeacoffee.com/jorcelinojunior") \n\n Your kindness helps improve this tool for everyone!\n Thank you for your support! 🌻💜 ")"
            echo -e " \n\n "
            break
          fi
        ;;
    esac
    if gum confirm "$(echo -e "\nWould you like to do something else?" | gum style --foreground="$CLR_PRI")" --affirmative="《Back" --negative="✖ Close" --show-help --prompt.foreground="$CLR_WRN" --selected.background="$CLR_PRI"; then
      show_banner
    else
      break
    fi
  done
}

main() {
  clear
  echo ""
  SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
  validate_os
  install_script_alias
  check_and_install_dependencies
  spinner "Initializing the setup wizard..." "sleep 1"
  menu
}

main
