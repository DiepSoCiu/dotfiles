#!/usr/bin/env bash
#  _____                 _       __        __          _
# |_   _|__   __ _  __ _| | ___  \ \      / /_ _ _   _| |__   __ _ _ __
#   | |/ _ \ / _` |/ _` | |/ _ \  \ \ /\ / / _` | | | | '_ \ / _` | '__|
#   | | (_) | (_| | (_| | |  __/   \ V  V / (_| | |_| | |_) | (_| | |
#   |_|\___/ \__, |\__, |_|\___|    \_/\_/ \__,_|\__, |_.__/ \__,_|_|
#            |___/ |___/                         |___/
#

#!/usr/bin/env bash

WAYBAR_DISABLED="$HOME/.config/waybar/disabled"
WAYBAR_LAUNCH="$HOME/.config/waybar/launch.sh"

if [ -f "$WAYBAR_DISABLED" ]; then
    rm "$WAYBAR_DISABLED"
    echo "Waybar enabled"
    "$WAYBAR_LAUNCH" &
else
    touch "$WAYBAR_DISABLED"
    echo "Waybar disabled"
    pkill waybar
fi
