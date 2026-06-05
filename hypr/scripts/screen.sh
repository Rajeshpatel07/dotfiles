#!/bin/bash

LAPTOP="eDP-1"

# Check if jq is installed (required for reliable JSON parsing)
if ! command -v jq &> /dev/null; then
    notify-send "Error" "Please install 'jq' to run the monitor toggle script."
    exit 1
fi

# Fetch the list of currently active monitors in JSON format
MONITORS_JSON=$(hyprctl -j monitors)

# Check if the laptop screen is currently active
IS_LAPTOP_ACTIVE=$(echo "$MONITORS_JSON" | jq -r ".[] | select(.name == \"$LAPTOP\") | .name")

# Count the total number of active monitors
MONITOR_COUNT=$(echo "$MONITORS_JSON" | jq '. | length')

if [ "$IS_LAPTOP_ACTIVE" == "$LAPTOP" ]; then
    # The laptop screen is currently ON.
    # Check if there is an external monitor connected before disabling.
    if [ "$MONITOR_COUNT" -gt 1 ]; then
        hyprctl keyword monitor "$LAPTOP,disable"
        notify-send "Display Manager" "Laptop screen disabled."
    else
        notify-send "Display Manager" "Action denied: No external monitor detected."
    fi
else
    # The laptop screen is currently OFF. Turn it back on.
    hyprctl keyword monitor "$LAPTOP,preferred,auto,1"
    notify-send "Display Manager" "Laptop screen enabled."
fi
