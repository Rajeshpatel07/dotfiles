#!/bin/bash
set -euo pipefail

# ------------------------------------------------------------------------------
# local-sync — pull live configs from ~/.config back into this repo
# Every overwrite is confirmed first.
# ------------------------------------------------------------------------------

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

step() { echo -e "\n${BLUE}━━ ${BOLD}$1${RESET}"; }
info() { echo -e "  ${DIM}→${RESET} $1"; }
ok()   { echo -e "  ${GREEN}✓${RESET} $1"; }
warn() { echo -e "  ${YELLOW}!${RESET} $1"; }
err()  { echo -e "  ${RED}✗${RESET} $1"; }
skip() { echo -e "  ${DIM}— skipped${RESET}"; }

ask() {
    local prompt="$1"
    echo -ne "  ${MAGENTA}?${RESET} ${prompt} ${DIM}[y/N]${RESET} "
    read -r reply || true
    [[ "$reply" =~ ^[Yy]$ ]]
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIRS=(hypr waybar kitty rofi mako)

echo -e "${BOLD}local-sync${RESET}"

# preview
for d in "${DIRS[@]}"; do
    if [[ -d "$HOME/.config/$d" ]]; then
        echo -e "    ${CYAN}$d${RESET}"
    else
        echo -e "    ${DIM}$d  (not found — skipping)${RESET}"
    fi
done
if [[ -f "$HOME/.tmux.conf" ]]; then
    echo -e "    ${CYAN}tmux${RESET}"
else
    echo -e "    ${DIM}tmux  (not found — skipping)${RESET}"
fi

echo ""
if ! ask "Sync configs from ~/.config?"; then
    info "Aborted."
    exit 0
fi

# ------------------------------------------------------------------------------
# 1. Config dirs
# ------------------------------------------------------------------------------
step "1/2  Config directories"

for dir in "${DIRS[@]}"; do
    src="$HOME/.config/$dir"
    dst="$SCRIPT_DIR/$dir"

    if [[ ! -d "$src" ]]; then
        warn "$dir not found — skipping"
        continue
    fi

    rm -rf "$dst"
    cp -r "$src" "$dst"
    ok "updated $dir"
done

# ------------------------------------------------------------------------------
# 2. Tmux
# ------------------------------------------------------------------------------
step "2/2  Tmux"

if [[ ! -f "$HOME/.tmux.conf" ]]; then
    warn "tmux not found — skipping"
else
    if ask "Sync tmux config?"; then
        mkdir -p "$SCRIPT_DIR/tmux"
        cp "$HOME/.tmux.conf" "$SCRIPT_DIR/tmux/.tmux.conf"
        ok "updated tmux"
    else
        skip
    fi
fi

# ------------------------------------------------------------------------------
# Done — show what changed
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}━━ ${BOLD}Done${RESET} ${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
ok "Sync complete"

if command -v git &>/dev/null && [[ -d "$SCRIPT_DIR/.git" ]]; then
    echo ""
    git -C "$SCRIPT_DIR" status --short || true
fi
