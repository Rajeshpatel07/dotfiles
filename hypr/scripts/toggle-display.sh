#!/bin/bash

set -u

LAPTOP="eDP-1"

notify() {
    notify-send "Display Manager" "$1"
}

fail() {
    notify-send "Display Manager" "$1"
    exit 1
}

command -v hyprctl >/dev/null 2>&1 || \
fail "hyprctl was not found."

command -v jq >/dev/null 2>&1 || \
fail "Please install 'jq'."

command -v notify-send >/dev/null 2>&1 || \
fail "Please install 'libnotify' / 'notify-send'."

MONITORS_JSON=$(hyprctl -j monitors all 2>/dev/null) || \
fail "Unable to read monitor information from Hyprland."

# Make sure we actually received valid JSON.
if ! jq -e . >/dev/null 2>&1 <<<"$MONITORS_JSON"; then
    fail "Hyprland returned invalid monitor information."
fi

LAPTOP_EXISTS=$(jq -r \
    --arg laptop "$LAPTOP" \
    'any(.[]; .name == $laptop)' \
    <<<"$MONITORS_JSON")

if [[ "$LAPTOP_EXISTS" != "true" ]]; then
    fail "Laptop display '$LAPTOP' was not found."
fi

LAPTOP_DISABLED=$(jq -r \
    --arg laptop "$LAPTOP" \
    'any(.[]; .name == $laptop and .disabled == true)' \
    <<<"$MONITORS_JSON")

if [[ "$LAPTOP_DISABLED" == "true" ]]; then
    if hyprctl reload >/dev/null 2>&1; then
        notify "Laptop display enabled."
    else
        fail "Failed to restore the normal display configuration."
    fi

    exit 0
fi

HDMI_FOUND=$(jq -r '
    any(.[];
    (.disabled != true) and
    (
    (.name | startswith("HDMI-A-")) or
    (.name | startswith("HDMI-"))
    )
    )
    ' <<<"$MONITORS_JSON")

if [[ "$HDMI_FOUND" != "true" ]]; then
    notify "No Device found"
    exit 0
fi

if hyprctl eval \
    "hl.monitor({ output = \"$LAPTOP\", disabled = true })" \
    >/dev/null 2>&1; then

    notify "Laptop display disabled. HDMI monitor is active."

else
    fail "Failed to disable the laptop display."
fi
