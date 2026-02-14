#!/usr/bin/env bash

RASI="$HOME/.config/rofi/network/style3.rasi"
IFACE=$(nmcli device | awk '$2=="wifi" {print $1; exit}')

[[ -z "$IFACE" ]] && notify-send "WiFi Error" "No interface" && exit 1

# Icons/Labels (KHÔNG có khoảng trắng sau $)
WIFI_ON=" WiFi ON"
WIFI_OFF=" WiFi OFF"
SCAN=" Scan WiFi"
BACK_BUTTON=" Back"

# Check if called from network-manager
FROM_MANAGER="$1"

check_wifi_state() {
    WIFI_STATE=$(nmcli radio wifi)
}

build_menu() {
    check_wifi_state
    if [[ "$WIFI_STATE" == "enabled" ]]; then
        OPTIONS="${WIFI_OFF}\n${SCAN}"
    else
        OPTIONS="${WIFI_ON}\n${SCAN}"
    fi
    # Thêm Back button nếu được gọi từ network-manager ở CUỐI menu
    [[ "$FROM_MANAGER" == "from-manager" ]] && OPTIONS="${OPTIONS}\n${BACK_BUTTON}"
}

rofi_menu() {
    while true; do
        build_menu
        SELECTION=$(echo -e "$OPTIONS" | rofi -dmenu -i -theme "$RASI" -p "WiFi Options" -no-custom -format s)

        # Kiểm tra nếu chọn Back - quay lại network-manager
        if [[ "$SELECTION" == "$BACK_BUTTON" ]]; then
            exit 2
        fi

        # Nếu không chọn gì (ESC) - THOÁT HẲN
        if [[ -z "$SELECTION" ]]; then
            exit 1
        fi

        selection_action

        # Nếu không phải từ manager thì thoát sau khi thực hiện action
        [[ "$FROM_MANAGER" != "from-manager" ]] && exit 0
    done
}

wifi_toggle() {
    if [[ "$1" == "on" ]]; then
        notify-send "WiFi" "Turning WiFi ON..."
        nmcli radio wifi on
        sleep 2
        # Scan WiFi sau khi bật
        notify-send "WiFi" "Scanning networks..."
        nmcli device wifi rescan ifname "$IFACE" 2>/dev/null
        sleep 1
        notify-send "WiFi" "WiFi is now ON"
        # Nếu từ manager, chuyển sang WiFi List panel
        if [[ "$FROM_MANAGER" == "from-manager" ]]; then
            exec "$HOME/.config/rofi/network/network.sh" "from-manager"
        fi
    else
        notify-send "WiFi" "Turning WiFi OFF..."
        nmcli radio wifi off
        notify-send "WiFi" "WiFi is now OFF"
        # Tắt WiFi thành công - thoát hẳn
        exit 0
    fi
}

scan_wifi() {
    check_wifi_state
    # Nếu WiFi đang tắt, bật lên trước
    if [[ "$WIFI_STATE" == "disabled" ]]; then
        notify-send "WiFi" "Turning WiFi ON for scanning..."
        nmcli radio wifi on
        sleep 2
    fi
    notify-send "WiFi" "Scanning networks..."
    nmcli device wifi rescan ifname "$IFACE" 2>/dev/null
    sleep 2
    notify-send "WiFi" "Scan complete"
    # Nếu từ manager, chuyển sang WiFi List panel
    if [[ "$FROM_MANAGER" == "from-manager" ]]; then
        exec "$HOME/.config/rofi/network/network.sh" "from-manager"
    fi
}

selection_action() {
    case "$SELECTION" in
        "$WIFI_ON")
            wifi_toggle "on"
            ;;
        "$WIFI_OFF")
            wifi_toggle "off"
            ;;
        "$SCAN")
            scan_wifi
            ;;
    esac
}

rofi_menu
