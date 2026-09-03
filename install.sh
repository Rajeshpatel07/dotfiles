#!/bin/bash
set -euo pipefail

# ------------------------------------------------------------------------------
# dotfiles installer — minimal, explicit, confirm-before-every-change
# ------------------------------------------------------------------------------

# -- colors (auto-disable if not a tty) ---------------------------------------
if [[ -t 1 ]]; then
    RESET='\033[0m'
    BOLD='\033[1m'
    DIM='\033[2m'
    BLUE='\033[1;34m'
    CYAN='\033[1;36m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    RED='\033[1;31m'
    MAGENTA='\033[1;35m'
else
    RESET=''; BOLD=''; DIM=''; BLUE=''; CYAN=''; GREEN=''; YELLOW=''; RED=''; MAGENTA=''
fi

# -- helpers ------------------------------------------------------------------
step()  { echo -e "\n${BLUE}━━ ${BOLD}$1${RESET}"; }
info()  { echo -e "  ${DIM}→${RESET} $1"; }
ok()    { echo -e "  ${GREEN}✓${RESET} $1"; }
warn()  { echo -e "  ${YELLOW}!${RESET} $1"; }
err()   { echo -e "  ${RED}✗${RESET} $1"; }
skip()  { echo -e "  ${DIM}— skipped${RESET}"; }

# ask <question> -> returns 0 on y/Y, 1 otherwise. Default is N.
ask() {
    local prompt="$1"
    echo -ne "  ${MAGENTA}?${RESET} ${prompt} ${DIM}[y/N]${RESET} "
    read -r reply || true
    [[ "$reply" =~ ^[Yy]$ ]]
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_PKGS=(hyprland hyprlock waybar kitty mako rofi nemo)
DOT_DIRS=(hypr waybar kitty rofi mako)
NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
NVIM_BAK="${HOME}/.config/nvim.bak"

# -- pre-flight ---------------------------------------------------------------
if ! command -v dnf &>/dev/null; then
    err "dnf not found — this installer targets Fedora."
    exit 1
fi

# ==============================================================================
# 1. Hyprland COPR
# ==============================================================================
step "1/9  Hyprland COPR"

if ask "Enable COPR repo ${BOLD}lionheartp/Hyprland${RESET}?"; then
    sudo dnf copr enable -y lionheartp/Hyprland
    ok "COPR enabled"
else
    skip
fi

# ==============================================================================
# 2. Core packages
# ==============================================================================
step "2/9  Core packages"

info "Packages: ${CYAN}${CORE_PKGS[*]}${RESET}"
if ask "Install core packages via dnf?"; then
    sudo dnf install -y "${CORE_PKGS[@]}"
    ok "Core packages installed"
else
    skip
fi

# ==============================================================================
# 3. bluetuith (Go)
# ==============================================================================
step "3/9  bluetuith  ${DIM}(Go — Bluetooth TUI)${RESET}"

if ! command -v go &>/dev/null; then
    warn "Go not found — skipping"
elif [[ -f "$HOME/go/bin/bluetuith" ]]; then
    ok "bluetuith already installed — skipping"
else
    if ask "Install bluetuith?"; then
        go install github.com/darkhz/bluetuith@latest
        ok "bluetuith installed"
    else
        skip
    fi
fi

# ==============================================================================
# 4. wiremix (Rust)
# ==============================================================================
step "4/9  wiremix  ${DIM}(Cargo — audio mixer)${RESET}"

if ! command -v cargo &>/dev/null; then
    warn "Cargo not found — skipping"
elif [[ -f "$HOME/.cargo/bin/wiremix" ]]; then
    ok "wiremix already installed — skipping"
else
    if ask "Install wiremix?"; then
        cargo install wiremix
        ok "wiremix installed"
    else
        skip
    fi
fi

# ==============================================================================
# 5. Dotfiles → ~/.config
# ==============================================================================
step "5/9  Dotfiles"

if ask "Deploy dotfiles to ~/.config?"; then
    mkdir -p "$HOME/.config"
    for dir in "${DOT_DIRS[@]}"; do
        if [[ -d "$SCRIPT_DIR/$dir" ]]; then
            rm -rf "$HOME/.config/$dir"
            cp -r "$SCRIPT_DIR/$dir" "$HOME/.config/"
            ok "deployed $dir"
        else
            warn "$dir not found — skipping"
        fi
    done
else
    skip
fi

# ==============================================================================
# 6. Tmux config
# ==============================================================================
step "6/9  Tmux"

if [[ ! -f "$SCRIPT_DIR/tmux/.tmux.conf" ]]; then
    warn "tmux config not found — skipping"
elif ask "Copy tmux config to ~/.tmux.conf?"; then
    cp "$SCRIPT_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    ok "tmux config copied"
else
    skip
fi

# ==============================================================================
# 7. TPM (Tmux Plugin Manager)
# ==============================================================================
step "7/9  TPM"

if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
    ok "TPM already installed — skipping"
elif ask "Install TPM (Tmux Plugin Manager)?"; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    ok "TPM installed"
else
    skip
fi

# ==============================================================================
# 8. Neovim (kickstart.nvim)
# ==============================================================================
step "8/9  Neovim"

if [[ -d "$NVIM_DIR" ]]; then
    warn "Existing nvim config will be backed up"
fi

if ask "Set up Neovim?"; then
    if [[ -d "$NVIM_DIR" ]]; then
        rm -rf "$NVIM_BAK"
        mv "$NVIM_DIR" "$NVIM_BAK"
        ok "backup saved"
    fi
    rm -rf "$NVIM_DIR"
    git clone https://github.com/Rajeshpatel07/kickstart.nvim.git "$NVIM_DIR"
    ok "Neovim ready"
else
    skip
fi

# ==============================================================================
# 9. Extras
# ==============================================================================

# -- Wallpaper ----------------------------------------------------------------
step "9a/9  Wallpaper  ${DIM}(optional)${RESET}"

if ask "Set a custom wallpaper?"; then
    echo -ne "  ${DIM}Path: ${RESET}"
    read -r wallpaper_path || true
    wallpaper_path="${wallpaper_path/#\~/$HOME}"
    if [[ -z "$wallpaper_path" ]]; then
        warn "No path entered — skipping"
    elif [[ -f "$wallpaper_path" ]]; then
        sudo mkdir -p /usr/share/hypr
        sudo cp "$wallpaper_path" /usr/share/hypr/wall0.png
        ok "wallpaper set"
    else
        err "File not found — skipping"
    fi
else
    skip
fi

# -- Memory optimization ------------------------------------------------------
step "9b/9  Memory optimization  ${DIM}(optional)${RESET}"

if ask "Optimize system services?"; then
    if [[ -f "$SCRIPT_DIR/optimize_services.sh" ]]; then
        chmod +x "$SCRIPT_DIR/optimize_services.sh"
        "$SCRIPT_DIR/optimize_services.sh"
    else
        err "optimizer not found — skipping"
    fi
else
    skip
fi

# -- Done ---------------------------------------------------------------------
echo -e "\n${GREEN}━━ ${BOLD}Done${RESET} ${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
ok "Setup complete"
echo -e "  Reboot to apply changes: ${BOLD}sudo reboot${RESET}"
