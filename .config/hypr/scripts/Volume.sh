#!/bin/bash

# Get Volume
get_volume() {
    volume=$(pamixer --get-volume)
    echo "$volume"
}

# Get icons based on volume level
get_icon() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        echo " "
    else
        current=$(get_volume)
        if [[ "$current" -lt 25 ]]; then
            echo ""
        elif [[ "$current" -lt 50 ]]; then
            echo ""
        elif [[ "$current" -lt 75 ]]; then
            printf "\u202F"
        else
            printf "\u202F"
        fi
    fi
}

# Get mic icon
get_mic_icon() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        echo ""
    else
        echo ""
    fi
}

# Notify using dunst
notify_user() {
    volume=$(get_volume)
    icon=$(get_icon)

    if [ "$(pamixer --get-mute)" == "true" ]; then
        notify-send -h string:x-dunst-stack-tag:volume \
            -h int:value:0 \
            -u low \
            "$icon Volume: Muted" ""
    else
        notify-send -h string:x-dunst-stack-tag:volume \
            -h int:value:"$volume" \
            -u low \
            "$icon Volume: ${volume}%" ""
    fi
}

# Notify for Microphone
notify_mic_user() {
    volume=$(pamixer --default-source --get-volume)
    icon=$(get_mic_icon)

    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        notify-send -h string:x-dunst-stack-tag:microphone \
            -h int:value:0 \
            -u low \
            "$icon Microphone: Muted" ""
    else
        notify-send -h string:x-dunst-stack-tag:microphone \
            -h int:value:"$volume" \
            -u low \
            "$icon Microphone: ${volume}%" ""
    fi
}

# Increase Volume
inc_volume() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        pamixer -u
    fi
    pamixer -i 1
    notify_user
}

# Decrease Volume
dec_volume() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        pamixer -u
    fi
    pamixer -d 1
    notify_user
}

# Toggle Mute
toggle_mute() {
    pamixer -t
    notify_user
}

# Toggle Mic
toggle_mic() {
    pamixer --default-source -t
    notify_mic_user
}

# Increase MIC Volume
inc_mic_volume() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        pamixer --default-source -u
    fi
    pamixer --default-source -i 1
    notify_mic_user
}

# Decrease MIC Volume
dec_mic_volume() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        pamixer --default-source -u
    fi
    pamixer --default-source -d 1
    notify_mic_user
}

# Execute accordingly
case "$1" in
    "--get")
        get_volume
        ;;
    "--inc")
        inc_volume
        ;;
    "--dec")
        dec_volume
        ;;
    "--toggle")
        toggle_mute
        ;;
    "--toggle-mic")
        toggle_mic
        ;;
    "--get-icon")
        get_icon
        ;;
    "--get-mic-icon")
        get_mic_icon
        ;;
    "--mic-inc")
        inc_mic_volume
        ;;
    "--mic-dec")
        dec_mic_volume
        ;;
    *)
        get_volume
        ;;
esac
