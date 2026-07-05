#!/bin/bash

# Define colors
NAME_COLOR='\033[1;36m'   # Bold Cyan
DESC_COLOR='\033[0;32m'   # Green
EFFECT_COLOR='\033[0;33m' # Yellow
PROMPT_COLOR='\033[1;35m' # Bold Magenta
NC='\033[0m'              # No Color

# Helper function to prompt and disable services
manage_service() {
    local service_name="$1"
    local systemd_units="$2"
    local description="$3"
    local effects="$4"

    # Display formatted information
    echo -e "${NAME_COLOR}[${service_name}]${NC}: ${DESC_COLOR}${description}${NC} ${EFFECT_COLOR}${effects}${NC}"
    
    # Prompt user
    echo -ne "${PROMPT_COLOR}Press (y/n): ${NC}"
    read -n 1 -r
    echo -e "\n" # Move to next line after keypress

    # Action if 'y' or 'Y' is pressed
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Stopping and disabling ${service_name}..."
        for unit in $systemd_units; do
            sudo systemctl stop "$unit" 2>/dev/null || true
            sudo systemctl disable "$unit" 2>/dev/null || true
        done
        echo -e "Done.\n"
    else
        echo -e "Skipped.\n"
    fi
    echo "----------------------------------------------------------------------"
}

echo "======================================================================"
echo "                   Fedora 44 Service Optimizer                        "
echo "======================================================================"
echo ""

# 1. SSSD
manage_service \
    "sssd.service" \
    "sssd.service" \
    "Manages remote enterprise network logins (like Active Directory)." \
    "No effect for a personal laptop. Your local password and sudo will work perfectly."

# 2. ModemManager
manage_service \
    "ModemManager.service" \
    "ModemManager.service" \
    "Controls internal cellular network cards." \
    "CRITICAL HARDWARE NOTE: If a physical SIM card slot is available on your laptop, you lose the ability to use it directly. Normal Wi-Fi and mobile phone Wi-Fi hotspots are completely unaffected."

# 3. CUPS (Printing)
manage_service \
    "cups" \
    "cups.service cups.socket cups.path" \
    "The Linux printing subsystem engine." \
    "You will completely lose the ability to use or connect to physical and network printers."

# 4. ABRT (Bug Reporting)
manage_service \
    "abrt" \
    "abrtd.service abrt-oops.service" \
    "Fedora's automatic crash and bug reporting utility." \
    "Crashed applications will close silently instead of creating massive diagnostic memory dumps or prompting you to file bugs."

# 5. PCSCD (Smart Cards)
manage_service \
    "pcscd" \
    "pcscd.service pcscd.socket" \
    "Drivers for physical smart card readers." \
    "CRITICAL HARDWARE NOTE: If you plug in a physical corporate Smart Card / ID Badge reader, it will stop working. Standard USB security keys (like a YubiKey for website logins) are unaffected."

echo "Optimization complete! Any changes made will persist across reboots."
