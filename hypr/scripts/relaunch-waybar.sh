#!/bin/bash

WAYBAR_PROCESS="waybar"

if pgrep -x "$WAYBAR_PROCESS" > /dev/null
then
    pkill -x "$WAYBAR_PROCESS"
    exit 0
else
    waybar & disown
    exit 0
fi
