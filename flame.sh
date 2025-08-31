#!/usr/bin/env bash
set -euo pipefail

echo "[*] Installing Flameshot…"
if ! command -v flameshot >/dev/null 2>&1; then
  sudo apt update
  sudo apt install -y flameshot
else
  echo "    Flameshot already installed."
fi

echo "[*] Enabling Flameshot at login…"
mkdir -p "$HOME/.config/autostart"
if [ -f /usr/share/applications/org.flameshot.Flameshot.desktop ]; then
  cp /usr/share/applications/org.flameshot.Flameshot.desktop "$HOME/.config/autostart/"
  # Make sure autostart entry is enabled
  sed -i 's/^Hidden=.*$/Hidden=false/; s/^X-GNOME-Autostart-enabled=.*$/X-GNOME-Autostart-enabled=true/' \
    "$HOME/.config/autostart/org.flameshot.Flameshot.desktop" || true
fi

# Helper: set a gsettings key if the schema exists
gset_if_present () {
  local schema="$1" key="$2" value="$3"
  if gsettings list-schemas | grep -qx "$schema"; then
    if gsettings list-keys "$schema" | grep -qx "$key"; then
      gsettings set "$schema" "$key" "$value"
      return 0
    fi
  fi
  return 1
}

echo "[*] Disabling GNOME Shell default screenshot bindings…"
# These keys exist on Ubuntu 24.04 GNOME Shell
gset_if_present org.gnome.shell.keybindings screenshot "[]" || true
gset_if_present org.gnome.shell.keybindings screenshot-window "[]" || true
gset_if_present org.gnome.shell.keybindings show-screenshot-ui "[]" || true

# (Optional) In case you’re on Cinnamon sometimes:
gset_if_present org.cinnamon.desktop.keybindings.media-keys screenshot "['']" || true
gset_if_present org.cinnamon.desktop.keybindings.media-keys window-screenshot "['']" || true
gset_if_present org.cinnamon.desktop.keybindings.media-keys area-screenshot "['']" || true

echo "[*] Creating GNOME custom keybindings for Flameshot…"

# Paths for two custom bindings
FS_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot/"
FS_SUPER_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot-super/"

# Read existing custom keybindings array (may be "@as []" or "[]")
EXISTING=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings 2>/dev/null || echo "[]")
EXISTING="${EXISTING/@as /}"    # normalize "@as []" -> "[]"

# Function to ensure a path is present in the array
ensure_path_in_array () {
  local arr="$1" path="$2"
  if [[ "$arr" != *"'$path'"* ]]; then
    if [[ "$arr" == "[]" ]]; then
      echo "['$path']"
    else
      echo "${arr%]} , '$path']"
    fi
  else
    echo "$arr"
  fi
}

NEW_ARRAY="$EXISTING"
NEW_ARRAY=$(ensure_path_in_array "$NEW_ARRAY" "$FS_PATH")
NEW_ARRAY=$(ensure_path_in_array "$NEW_ARRAY" "$FS_SUPER_PATH")

# Write back the array
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_ARRAY"

# Configure each custom binding
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${FS_PATH}" name 'Flameshot'
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${FS_PATH}" command 'flameshot gui'
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${FS_PATH}" binding 'Print'

gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${FS_SUPER_PATH}" name 'Flameshot Super'
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${FS_SUPER_PATH}" command 'flameshot gui'
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${FS_SUPER_PATH}" binding '<Super>Print'

echo "[*] Done! Test with: Print, Fn+Print, and Super+Print."
echo "    If nothing happens, log out/in or run: nohup flameshot &"
