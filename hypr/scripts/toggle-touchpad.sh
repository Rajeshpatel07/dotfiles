#!/usr/bin/env bash
# toggle-touchpad.sh — Hyprland >=0.55 replaced the old hyprlang
# `device[name]:enabled` keyword path with a Lua-based config API.
# On 0.55+/0.56+, the correct way to flip a device's enabled state at
# runtime is: hyprctl eval "hl.device({ name = 'NAME', enabled = false })"
# (the old `hyprctl keyword "device[name]:enabled" false` can silently
# no-op even though it returns success — that's what was happening here).

set -uo pipefail

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr_touchpad_state"

# Discover the touchpad device(s) + any sibling node sharing its ID prefix
# (e.g. an Elan "...-mouse" node alongside "...-touchpad").
mapfile -t ALL_MICE < <(hyprctl devices | awk '
    /^mice:/ {inmice=1; next}
    /^[A-Za-z]/ {inmice=0}
    inmice && /^\t\t[^\t]/ {
        gsub(/^\t+|\t+$/, "");
        print
    }
')

ANCHORS=()
for dev in "${ALL_MICE[@]}"; do
    [[ "${dev,,}" == *touchpad* ]] && ANCHORS+=("$dev")
done

if [ "${#ANCHORS[@]}" -eq 0 ]; then
    command -v notify-send >/dev/null 2>&1 && notify-send "Touchpad" "No touchpad device found"
    exit 1
fi

declare -A SEEN
TARGETS=()
for anchor in "${ANCHORS[@]}"; do
    if [[ -z "${SEEN[$anchor]+x}" ]]; then
        TARGETS+=("$anchor")
        SEEN[$anchor]=1
    fi
    prefix="${anchor%-touchpad}"
    for dev in "${ALL_MICE[@]}"; do
        if [[ "$dev" == "$prefix"-* && -z "${SEEN[$dev]+x}" ]]; then
            TARGETS+=("$dev")
            SEEN[$dev]=1
        fi
    done
done

CURRENT="1"
[[ -f "$STATE_FILE" ]] && CURRENT=$(cat "$STATE_FILE")

if [[ "$CURRENT" == "1" ]]; then
    NEW="0"; HYPR_VAL="false"; MSG="Touchpad disabled"
else
    NEW="1"; HYPR_VAL="true"; MSG="Touchpad enabled"
fi

for tp in "${TARGETS[@]}"; do
    OUT=$(hyprctl eval "hl.device({ name = '$tp', enabled = $HYPR_VAL })" 2>&1)
    # Print what Hyprland actually returned, useful when run manually
    # in a terminal to confirm it's not erroring (e.g. "nil" issues).
    echo "eval [$tp] -> $OUT" >&2
done

echo "$NEW" > "$STATE_FILE"
command -v notify-send >/dev/null 2>&1 && \
    notify-send -i input-touchpad "Touchpad" "$MSG"
