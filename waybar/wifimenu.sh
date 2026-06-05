#!/usr/bin/env bash

# Get a list of available Wi-Fi networks.
networks=$(nmcli -t -f SSID,BARS,SECURITY device wifi list --rescan yes | grep -v '^--' | uniq | grep . )

# Use Rofi to present the network list for selection.
selected_network=$(echo "$networks" | rofi -dmenu -i -p "WIFI:" -no-show-icons)

# Exit if no network is selected.
if [ -z "$selected_network" ]; then
    echo "No network selected. Exiting."
    exit 1
fi

# Parse the selected line.
IFS=':' read -r SSID BARS SECURITY <<< "$selected_network"
SSID=$(echo "$SSID" | xargs)

# Assume connection will fail until a successful command runs.
success=false

# Check if a connection profile for this SSID already exists.
if nmcli -g NAME connection show | grep -wq "$SSID"; then
    notify-send "Connecting..." "Using saved profile for '$SSID'"
    connection_output=$(nmcli connection up "$SSID" 2>&1)

    if [ $? -eq 0 ]; then
        success=true
    elif echo "$connection_output" | grep -q "Secrets were required"; then
        echo "Saved password for $SSID is incorrect. Asking for new one."
        wifi_password=$(rofi -dmenu -password -p "New Password for $SSID:")

        if [ -n "$wifi_password" ]; then
            # nmcli connection modify "$SSID" 802-11-wireless-security.psk "$wifi_password"

            nmcli connection up "$SSID" && success=true
        fi
    fi
else
    # If no profile exists, create a new one.
    if [ "$SECURITY" = "--" ] || [ -z "$SECURITY" ]; then
        nmcli device wifi connect "$SSID" && success=true
    else
        wifi_password=$(rofi -dmenu -password -p "   Password for $SSID:")
        if [ -n "$wifi_password" ]; then
            nmcli device wifi connect "$SSID" password "$wifi_password" && success=true
        fi
    fi
fi

# Final status notification based on the outcome.
if [ "$success" = true ]; then
    notify-send -t 3000 "Connection Successful" "You are now connected to '$SSID'"
else
    notify-send -t 3000 -u critical "Connection Failed" "Could not connect to '$SSID'"
fi
