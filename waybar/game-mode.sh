#!/bin/bash
# ~/.config/waybar/game-mode.sh — Waybar toggle for input:touchpad:disable_while_typing
# Compromise: directly edit hyprland.lua and run hyprctl reload.
# Gaming ON  = disable_while_typing false (touchpad active with WASD)
# Gaming OFF = disable_while_typing true  (touchpad disabled while typing)
# Waybar shows correct status from the file, so click reflects reality.

set -u

HYPR_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.lua"

get_state() {
    local val=""
    if [[ -f "$HYPR_CONF" ]]; then
        val=$(grep -E "disable_while_typing\s*=" "$HYPR_CONF" 2>/dev/null | grep -oE "true|false" | tail -n1 || true)
        if [[ "$val" == "false" ]]; then echo "0"; return; fi
        if [[ "$val" == "true" ]]; then echo "1"; return; fi
    fi
    # Fallback to hyprctl if file not found / parse fails
    if command -v hyprctl >/dev/null 2>&1; then
        if command -v jq >/dev/null 2>&1; then
            val=$(hyprctl getoption input:touchpad:disable_while_typing -j 2>/dev/null | jq -r '.int // empty' 2>/dev/null || true)
        fi
        if [[ -z "$val" ]]; then
            val=$(hyprctl getoption input:touchpad:disable_while_typing 2>/dev/null | grep -i 'int' | head -n1 | grep -o '[01]' | head -n1 || true)
        fi
        [[ "$val" == "0" ]] && echo "0" || echo "1"
        return
    fi
    echo "1"
}

print_status() {
    local val; val=$(get_state)
    if [[ "$val" == "0" ]]; then
        printf '{"text":" ON","tooltip":"Gaming mode ON — touchpad active while typing","class":"on","alt":"on"}\n'
    else
        printf '{"text":" OFF","tooltip":"Gaming mode OFF — touchpad disabled while typing","class":"off","alt":"off"}\n'
    fi
}

toggle() {
    local val; val=$(get_state)
    if [[ ! -f "$HYPR_CONF" ]]; then
        # No file -> fallback to runtime keyword (should not happen)
        if [[ "$val" == "0" ]]; then
            hyprctl keyword input:touchpad:disable_while_typing true >/dev/null 2>&1 || true
            command -v notify-send >/dev/null 2>&1 && notify-send -i input-touchpad "Gaming Mode OFF" "Happy Coding!" || true
        else
            hyprctl keyword input:touchpad:disable_while_typing false >/dev/null 2>&1 || true
            command -v notify-send >/dev/null 2>&1 && notify-send -i input-gaming "Gaming Mode ON" "Enjoy Gaming!" || true
        fi
    else
        if [[ "$val" == "0" ]]; then
            # Gaming ON -> turn OFF: true
            sed -i -E 's/(disable_while_typing[[:space:]]*=[[:space:]]*)false/\1true/' "$HYPR_CONF"
            command -v notify-send >/dev/null 2>&1 && notify-send -i input-touchpad "Gaming Mode OFF" "Happy Coding!" || true
        else
            # Gaming OFF -> turn ON: false
            sed -i -E 's/(disable_while_typing[[:space:]]*=[[:space:]]*)true/\1false/' "$HYPR_CONF"
            command -v notify-send >/dev/null 2>&1 && notify-send -i input-gaming "Gaming Mode ON" "Enjoy Gaming!" || true
        fi
        hyprctl reload >/dev/null 2>&1 || true
    fi
    pkill -SIGRTMIN+8 waybar 2>/dev/null || pkill -RTMIN+8 waybar 2>/dev/null || true
    sleep 0.15 || true
}

case "${1:-status}" in
    toggle) toggle ;;
    *) ;;
esac

print_status
