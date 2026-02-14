#!/usr/bin/env bash

# Device Menu Script

CACHE_FILE="/tmp/rofi-bluetooth-device-cache"
SCRIPT_DIR="$HOME/.config/rofi/bluetooth"

# Read device info from cache
if [ ! -f "$CACHE_FILE" ]; then
    exit 0
fi

read -r device_info < "$CACHE_FILE"
mac=$(echo "$device_info" | cut -d '|' -f 1)
device_name=$(echo "$device_info" | cut -d '|' -f 2)

# Checks if a device is connected
device_connected() {
    device_info=$(bluetoothctl info "$1" 2>/dev/null)
    if echo "$device_info" | grep -q "Connected: yes"; then
        return 0
    else
        return 1
    fi
}

# Checks if a device is paired
device_paired() {
    device_info=$(bluetoothctl info "$1" 2>/dev/null)
    if echo "$device_info" | grep -q "Paired: yes"; then
        return 0
    else
        return 1
    fi
}

# Checks if a device is trusted
device_trusted() {
    device_info=$(bluetoothctl info "$1" 2>/dev/null)
    if echo "$device_info" | grep -q "Trusted: yes"; then
        return 0
    else
        return 1
    fi
}

# Display device options
show_device_options() {
    if device_connected "$mac"; then
        echo "󰂯 Connected: YES"
    else
        echo "󰂲 Connected: NO"
    fi

    if device_paired "$mac"; then
        echo "󰂱 Paired: YES"
    else
        echo "󰂲 Paired: NO"
    fi

    if device_trusted "$mac"; then
        echo "󰗹 Trusted: YES"
    else
        echo "󰗹 Trusted: NO"
    fi

    echo "──────────────────────"
    echo "󰆴 Remove Device"
}

# Handle device action
handle_device_action() {
    case "$1" in
        *"Connected:"*)
            if device_connected "$mac"; then
                bluetoothctl disconnect "$mac"
                notify-send "Bluetooth" "Device disconnected" -i bluetooth-disabled
            else
                bluetoothctl connect "$mac"
                if [ $? -eq 0 ]; then
                    notify-send "Bluetooth" "Connected successfully" -i bluetooth-active
                else
                    notify-send "Bluetooth" "Connection failed" -i dialog-error
                fi
            fi
            ;;
        *"Paired:"*)
            if device_paired "$mac"; then
                notify-send "Bluetooth" "Device already paired. Use 'Remove Device' to unpair." -i dialog-information
            else
                bluetoothctl pair "$mac"
                if [ $? -eq 0 ]; then
                    notify-send "Bluetooth" "Paired successfully" -i bluetooth-active
                    bluetoothctl trust "$mac"
                else
                    notify-send "Bluetooth" "Pairing failed" -i dialog-error
                fi
            fi
            ;;
        *"Trusted:"*)
            if device_trusted "$mac"; then
                bluetoothctl untrust "$mac"
                notify-send "Bluetooth" "Device untrusted" -i bluetooth
            else
                bluetoothctl trust "$mac"
                notify-send "Bluetooth" "Device trusted" -i bluetooth
            fi
            ;;
        *"Remove Device"*)
            bluetoothctl remove "$mac"
            notify-send "Bluetooth" "Device removed" -i bluetooth
            rm -f "$CACHE_FILE"
            exit 0
            ;;
    esac

    # Relaunch menu to show updated status
    "$SCRIPT_DIR/bluetooth-device-menu.sh"
}

# Main logic
if [ -n "$@" ]; then
    handle_device_action "$@"
else
    show_device_options | rofi -dmenu -theme "$SCRIPT_DIR/style.rasi" -p "$device_name"
fi
