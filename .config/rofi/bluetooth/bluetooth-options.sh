#!/usr/bin/env bash

# Bluetooth Options Tab Script

# Checks if bluetooth controller is powered on
power_on() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        return 0
    else
        return 1
    fi
}

# Checks if controller is scanning
scan_on() {
    if bluetoothctl show | grep -q "Discovering: yes"; then
        return 0
    else
        return 1
    fi
}

# Checks if controller is discoverable
discoverable_on() {
    if bluetoothctl show | grep -q "Discoverable: yes"; then
        return 0
    else
        return 1
    fi
}

# Display options
show_options() {
    if power_on; then
        power_status="ON"
        power_icon=""
    else
        power_status="OFF"
        power_icon=""
    fi

    echo "$power_icon Power: $power_status"

    # Only show scan and discoverable when bluetooth is ON
    if power_on; then
        if scan_on; then
            echo " Scanning..."
        else
            echo " Scan Devices"
        fi

        if discoverable_on; then
            echo "󰂯 Discoverable: ON"
        else
            echo "󰂯 Discoverable: OFF"
        fi
    fi
}

# Handle selection
handle_selection() {
    case "$1" in
        *"Power:"*)
            if power_on; then
                bluetoothctl power off
                notify-send "Bluetooth" "Bluetooth disabled" -i bluetooth-disabled
            else
                if rfkill list bluetooth | grep -q 'blocked: yes'; then
                    rfkill unblock bluetooth && sleep 3
                fi
                bluetoothctl power on
                # Auto enable pairable when turning on
                bluetoothctl pairable on
                notify-send "Bluetooth" "Bluetooth enabled" -i bluetooth-active
            fi
            ;;
        *"Scan"*)
            if scan_on; then
                kill $(pgrep -f "bluetoothctl scan on") 2>/dev/null
                bluetoothctl scan off
                notify-send "Bluetooth" "Scan stopped" -i bluetooth
            else
                bluetoothctl scan on &
                notify-send "Bluetooth" "Scanning for devices..." -i bluetooth
            fi
            ;;
        *"Discoverable:"*)
            if discoverable_on; then
                bluetoothctl discoverable off
                notify-send "Bluetooth" "Discoverable disabled" -i bluetooth
            else
                bluetoothctl discoverable on
                notify-send "Bluetooth" "Discoverable enabled" -i bluetooth
            fi
            ;;
    esac
}

# Main logic
if [ -n "$@" ]; then
    handle_selection "$@"
else
    show_options
fi
