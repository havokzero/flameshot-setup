# Flameshot Auto-Setup

A simple script to install [Flameshot](https://flameshot.org/), enable it at startup, and set it as the default **screenshot tool** on Ubuntu 24.04 (GNOME).  
It rebinds the **Print Screen** key (including `Fn+PrtSc`) and **Super+PrtSc** to launch `flameshot gui`.

---

## ✨ Features
- Installs Flameshot (if missing)
- Adds Flameshot to autostart
- Disables GNOME’s default screenshot shortcuts
- Binds:
  - `PrtSc` / `Fn+PrtSc` → `flameshot gui`
  - `Super+PrtSc` → `flameshot gui`

---

## 🚀 Usage

Clone and run the setup script:

    git clone [this sctipt](https://github.com/havokzero/flameshot-setup).git
    cd flameshot-auto-setup
    bash setup-flameshot.sh

Log out and back in (or reboot) to apply keybinding changes.

---

## 🖼️ Example

Press <kbd>PrtSc</kbd> or <kbd>Super</kbd>+<kbd>PrtSc</kbd> to launch the Flameshot capture overlay:

![flameshot demo](https://flameshot.org/img/screen1.jpg)

---

## 🔧 Notes
- Tested on **Ubuntu 24.04 GNOME**.
- Works on most laptops where `Fn+PrtSc` maps to `Print`.
- To undo: remove the custom shortcuts from *Settings → Keyboard → Shortcuts* and delete the autostart entry in `~/.config/autostart/`.

---

## 📜 License
MIT
