#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script for Monitor backlights (if supported) using brightnessctl

notification_timeout=1000
step=1  # INCREASE/DECREASE BY THIS VALUE

# Get current brightness as an integer (without %)
get_brightness() {
    brightnessctl -m | cut -d, -f4 | tr -d '%'
}

# Get icon based on brightness level
get_icon() {
    local brightness=$(get_brightness)

    if [[ "$brightness" -lt 25 ]]; then
        echo "󰃞"
    elif [[ "$brightness" -lt 50 ]]; then
        echo "󰃝"
    elif [[ "$brightness" -lt 75 ]]; then
        echo "󰃟"
    else
        echo "󰃠"
    fi
}

# Send notification
send_notification() {
    local brightness=$(get_brightness)
    local icon=$(get_icon)

    notify-send -h string:x-dunst-stack-tag:brightness \
        -h int:value:"$brightness" \
        -u low \
        "$icon Brightness: ${brightness}%" ""
}

# Change brightness and notify
change_brightness() {
    local delta=$1
    local current new
    current=$(get_brightness)
    new=$((current + delta))

    # Clamp between 5 and 100
    (( new < 5 )) && new=5
    (( new > 100 )) && new=100

    brightnessctl set "${new}%"
    send_notification
}

# Main
case "$1" in
    "--get")
        get_brightness
        ;;
    "--inc")
        change_brightness "$step"
        ;;
    "--dec")
        change_brightness "-$step"
        ;;
    *)
        get_brightness
        ;;
esac
