#!/bin/bash
set -euo pipefail

# ------------------------------------------------------------------------------
# optimize_services — interactively disable unused Fedora services
# Called from install.sh, or run standalone: ./optimize_services.sh
# ------------------------------------------------------------------------------

if [[ -t 1 ]]; then
    RESET='\033[0m'
    BOLD='\033[1m'
    DIM='\033[2m'
    CYAN='\033[1;36m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    RED='\033[1;31m'
    MAGENTA='\033[1;35m'
else
    RESET=''; BOLD=''; DIM=''; CYAN=''; GREEN=''; YELLOW=''; RED=''; MAGENTA=''
fi

ok()   { echo -e "  ${GREEN}✓${RESET} $1"; }
warn() { echo -e "  ${YELLOW}!${RESET} $1"; }
info() { echo -e "  ${DIM}→${RESET} $1"; }

ask() {
    local prompt="$1"
    echo -ne "  ${MAGENTA}?${RESET} ${prompt} ${DIM}[y/N]${RESET} "
    read -r reply || true
    [[ "$reply" =~ ^[Yy]$ ]]
}

manage_service() {
    local label="$1"
    local units="$2"
    local what="$3"
    local effect="$4"

    echo -e "${BOLD}${label}${RESET} ${DIM}—${RESET} ${what}"
    echo -e "  ${DIM}${effect}${RESET}"

    if ask "Disable ${label}?"; then
        for unit in $units; do
            sudo systemctl stop "$unit" 2>/dev/null || true
            sudo systemctl disable "$unit" 2>/dev/null || true
        done
        ok "disabled"
    else
        echo -e "  ${DIM}— skipped${RESET}"
    fi
    echo ""
}

echo -e "${BOLD}Service optimizer${RESET}\n"

manage_service \
    "sssd.service" \
    "sssd.service" \
    "Enterprise login (Active Directory / LDAP)" \
    "Safe to disable on a personal laptop. Local logins & sudo unaffected."

manage_service \
    "ModemManager.service" \
    "ModemManager.service" \
    "Cellular modem control (built-in WWAN / SIM slot)" \
    "If you use a physical SIM slot, it will stop working. Wi-Fi & phone hotspots unaffected."

manage_service \
    "cups" \
    "cups.service cups.socket cups.path" \
    "Printing subsystem" \
    "Disabling removes all printer support (local & network)."

manage_service \
    "abrt" \
    "abrtd.service abrt-oops.service" \
    "Automatic crash reporting & coredumps" \
    "Crashes will close silently without bug-report prompts or large dumps."

manage_service \
    "pcscd" \
    "pcscd.service pcscd.socket" \
    "Smart-card reader daemon" \
    "Corporate ID badge readers will stop. YubiKeys for WebAuthn/U2F unaffected."

echo -e "${GREEN}━━ ${BOLD}Done${RESET} ${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
ok "Optimization complete"
