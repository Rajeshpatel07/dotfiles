# 🚀 My Hyprland Dotfiles

This configuration provides a clean, minimal, and functional Hyprland desktop on Fedora Linux.

## 📦 What's Included

This repository contains configurations for the following core components:

*   **Window Manager:** [Hyprland](https://hyprland.org/) + Hyprlock
*   **Status Bar:** [Waybar](https://github.com/Alexays/Waybar)
*   **Terminal:** [Kitty](https://sw.kovidgoyal.net/kitty/)
*   **App Launcher:** [Rofi](https://github.com/davatorium/rofi) (Wayland fork)
*   **Notifications:** [Mako](https://github.com/emersion/mako)
*   **Terminal Multiplexer:** [Tmux](https://github.com/tmux/tmux) (with TPM plugin manager)
*   **Text Editor:** [Neovim](https://neovim.io/) (Powered by [Kickstart.nvim](https://github.com/Rajeshpatel07/kickstart.nvim))

---

## 🛠️ Setup Instructions

### 1. Installation

To set up this environment from scratch on a fresh Fedora system, use the provided `install.sh` script. It will automatically install the necessary packages, copy the configurations to your `~/.config` directory, set up Tmux, and pull the Neovim configuration.

```bash
# Clone this repository
git clone https://github.com/Rajeshpatel07/dotfiles.git
cd dotfiles

# Make the installation script executable
chmod +x install.sh

# Run the installer
./install.sh
```

# Hyprland Keybinds

**Legend:**

*   `super`: Windows/Cmd key
*   `→/←/↑/↓`: Arrow keys


---

## Application Launch & System Actions

| Keybind                | Action                                  |
| :--------------------- | :-------------------------------------- |
| `super` + `space`      | 🚀 Open app launcher `(rofi)`             |
| `super` + `b`          | 🦁 Open Brave in workspace            |
| `super` + `q`          | 🖥️ Open Kitty terminal                  |
| `super` + `c`          | ❌ Close current application             |
| `super` + `m`          | 🔒 Logout from Hyprland                 |
| `super` + `v`          | 🪟 Toggle floating window mode           |
| `super` + `Shift` + `l`    | 🔒 Open lock screen (hyprlock)             |

## Window Navigation

| Keybind                | Action                                  |
| :--------------------- | :-------------------------------------- |
| `super` + `j`          | ⬇️ Move focus to the window below        |
| `super` + `k`          | ⬆️ Move focus to the window above        |
| `super` + `l`          | ➡️ Move focus to the window on the right |
| `super` + `h`          | ⬅️ Move focus to the window on the left  |

## Mouse Actions

| Keybind                       | Action                                  |
| :---------------------------- | :-------------------------------------- |
| `super` + `Left Click`        | 🖱️↔️ Move app tiles                     |
| `super` + `Right Click`       | 🖱️↕️ Resize floating window             |

## Workspace & Layout

| Keybind                    | Action                                     |
| :------------------------- | :----------------------------------------- |
| `super` + `f`    | 🖥️⛶ Make app fullscreen                    |
| `super` + `w`    | 🆕 Toggle Waybar                         |
| `super` + `1-9`            | 🔢 Switch to workspace 1–9                 |
| `super` + `Shift` + `1-9`  | 📦 Move current app to workspace 1–9       |
| `super` + `Shift` + `s`    | 🌟 Move app to special workspace           |
| `super` + `s`              | 🔄 Toggle special workspace                |

## Audio

| Keybind                    | Action                                  |
| :------------------------- | :-------------------------------------- |
| `super` + `Shift` + `↑/↓`  | 🎤⬆️⬇️ Adjust microphone up/down        |


