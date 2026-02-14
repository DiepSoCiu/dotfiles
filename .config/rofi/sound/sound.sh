#!/usr/bin/env bash
LANG="en_US.utf8"
IFS=$'\n'

# If script is run directly (not by rofi), launch rofi
if [ -z "$ROFI_RETV" ]; then
    rofi -show sound -modi "sound:$0" -theme ~/.config/rofi/sound/style.rasi
    exit 0
fi

# Get icon based on sink type
get_sink_icon() {
    local desc="$1"
    case "$desc" in
        *"Headphones"*|*"headphone"*|*"Headset"*|*"headset"*)
            printf "\u202F"
            ;;
        *"Speaker"*|*"speaker"*|*"Built-in"*)
            printf "\u202F"
            ;;
        *"HDMI"*|*"hdmi"*)
            printf "󰍹\u202F"
            ;;
        *"USB"*|*"usb"*)
            printf "󱇰\u202F"
            ;;
        *"Bluetooth"*|*"bluetooth"*)
            printf "󰂯\u202F"
            ;;
        *)
            printf "\u202F"
            ;;
    esac
}

# Notify using dunst with proper formatting
notify_user() {
    local desc="$1"
    local success="$2"
    local icon=$(get_sink_icon "$desc")

    if [ "$success" = "true" ]; then
        notify-send -h string:x-dunst-stack-tag:audio-output \
            -u low \
            -t 2000 \
            "$icon Audio Output" "$desc"
    else
        notify-send -h string:x-dunst-stack-tag:audio-output \
            -u critical \
            -t 2000 \
            "❌ Audio Error" "$desc"
    fi
}

# An option was passed, so let's check it
if [ "$@" ]; then
    # Remove status from description if present
    desc=$(echo "$*" | sed 's/^\[.*\] //')

    # Figure out what the device name is based on the description passed
    device=$(pactl list sinks|grep -C2 "Description: ${desc}$"|grep Name|cut -d: -f2|xargs)

    # Try to set the default to the device chosen
    if pactl set-default-sink "$device"; then
        notify_user "$desc" "true"
    else
        notify_user "$desc" "false"
    fi
else
    echo -en "\x00prompt\x1fSelect Output\n"
    echo -en "\x00no-custom\x1ftrue\n"

    # Get current default sink
    current_sink=$(pactl get-default-sink)

    # Get the list of outputs
    all_sinks=()
    current_desc=""

    for x in $(pactl list sinks | grep -ie "description:"|cut -d: -f2|sort); do
        sink_desc=$(echo "$x"|xargs)
        sink_name=$(pactl list sinks | grep -C2 "Description: ${sink_desc}$" | grep Name | cut -d: -f2 | xargs)

        # Only show status for current sink
        if [ "$sink_name" = "$current_sink" ]; then
            # Get volume and mute status
            volume=$(pactl list sinks | grep -A 15 "Name: $sink_name" | grep "Volume:" | head -1 | awk '{print $5}' | tr -d '%')
            mute=$(pactl list sinks | grep -A 15 "Name: $sink_name" | grep "Mute:" | awk '{print $2}')

            # Format status
            if [ "$mute" = "yes" ]; then
                status="[MUTED]"
            else
                status="[${volume}%]"
            fi
            current_desc="$status $sink_desc"
        else
            all_sinks+=("$sink_desc")
        fi
    done

    # Output current sink first, then others
    if [ -n "$current_desc" ]; then
        echo "$current_desc"
    fi
    for sink in "${all_sinks[@]}"; do
        echo "$sink"
    done
fi
