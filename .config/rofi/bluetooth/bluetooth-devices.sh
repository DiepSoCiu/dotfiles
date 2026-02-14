#!/usr/bin/env bash

# Bluetooth Devices Tab Script

CACHE_FILE="/tmp/rofi-bluetooth-device-cache"

# Checks if bluetooth controller is powered on
power_on() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        return 0
    else
        return 1
    fi
}

# Checks if a device is connected
device_connected() {
    device_info=$(bluetoothctl info "$1" 2>/dev/null)
    if echo "$device_info" | grep -q "Connected: yes"; then
        return 0
    else
        return 1
    fi
}

# Display devices
show_devices() {
    if ! power_on; then
        echo "󰂑 Turn on Bluetooth first"
        return
    fi

    devices=$(bluetoothctl devices | grep Device)

    if [ -z "$devices" ]; then
        echo "󰂑 No devices found"
        echo " Start scanning to find devices"
        return
    fi

    while IFS= read -r device; do
        dev_mac=$(echo "$device" | cut -d ' ' -f 2)
        dev_name=$(echo "$device" | cut -d ' ' -f 3-)

        if device_connected "$dev_mac"; then
            echo "󰂱 $dev_name"
        else
            echo "󰂲 $dev_name"
        fi
    done <<< "$devices"
}

# Handle device selection
handle_device_selection() {
    selected="$1"

    # Skip info messages
    if [[ "$selected" == "󰂑"* ]] || [[ "$selected" == ""* ]]; then
        exit 0
    fi

    # Extract device name
    device_name=$(echo "$selected" | sed 's/^󰂱 //;s/^󰂲 //')

    # Get device MAC
    device=$(bluetoothctl devices | grep "$device_name")
    if [ -z "$device" ]; then
        exit 0
    fi

    mac=$(echo "$device" | cut -d ' ' -f 2)

    # Save device info to cache for submenu
    echo "$mac|$device_name" > "$CACHE_FILE"

    # Launch device submenu
    "$HOME/.config/rofi/bluetooth/bluetooth-device-menu.sh"
}

# Main logic
if [ -n "$@" ]; then
    handle_device_selection "$@"
else
    show_devices
fi
