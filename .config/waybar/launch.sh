#!/usr/bin/env bash

# Do not launch if disabled
if [ -f "$HOME/.config/waybar/disabled" ]; then
    exit 0
fi

# ----------------------------------
# Prevent duplicate launches
# ----------------------------------
exec 200>/tmp/waybar.lock
flock -n 200 || exit 0

# ----------------------------------
# Kill existing waybar
# ----------------------------------
pkill waybar
sleep 0.3

# ----------------------------------
# Launch waybar (Hyprland-safe)
# ----------------------------------
WAYBAR_CONFIG="$HOME/.config/waybar/config"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"

if command -v hyprctl >/dev/null; then
    HYPRLAND_SIGNATURE=$(hyprctl instances -j | jq -r '.[0].instance')
    HYPRLAND_INSTANCE_SIGNATURE="$HYPRLAND_SIGNATURE" \
        waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &
else
    waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &
fi

# ----------------------------------
# Release lock
# ----------------------------------
flock -u 200
exec 200>&-
