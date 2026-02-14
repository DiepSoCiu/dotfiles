#!/usr/bin/env bash

# Main Bluetooth launcher script with clickable tabs

SCRIPT_DIR="$HOME/.config/rofi/bluetooth"

rofi -show bluetooth \
    -modi "bluetooth:$SCRIPT_DIR/bluetooth-options.sh,devices:$SCRIPT_DIR/bluetooth-devices.sh" \
    -theme "$SCRIPT_DIR/style.rasi" \
    -kb-mode-next "Alt+Right,Alt+l,Alt+Tab" \
    -kb-mode-previous "Alt+Left,Alt+h,Alt+Shift+Tab" \
    -kb-custom-1 "Alt+1" \
    -kb-custom-2 "Alt+2" \
    -click-to-exit false
