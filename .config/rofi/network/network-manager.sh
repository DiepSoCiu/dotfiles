#!/usr/bin/env bash

RASI="$HOME/.config/rofi/network/style3.rasi"
IFACE=$(nmcli device | awk '$2=="wifi" {print $1; exit}')

[[ -z "$IFACE" ]] && notify-send "WiFi Error" "No interface" && exit 1

# Menu icons
WIFI_LIST=" WiFi List"
OPTIONS=" Options"
PROPERTIES=" Properties"

show_main_menu() {
    while true; do
        MENU_OPTIONS="${WIFI_LIST}\n${OPTIONS}\n${PROPERTIES}"
        SELECTION=$(echo -e "$MENU_OPTIONS" | rofi -dmenu -i \
            -theme "$RASI" \
            -p "Network Manager" \
            -no-custom \
            -format s)

        # Nếu không chọn gì (ESC) thì thoát hẳn
        [[ -z "$SELECTION" ]] && exit 0

        case "$SELECTION" in
            "$WIFI_LIST")
                "$HOME/.config/rofi/network/network.sh" "from-manager"
                exit_code=$?
                # Exit code 0 = kết nối thành công -> thoát hẳn
                # Exit code 1 = ESC -> thoát hẳn
                # Exit code 2 = Back -> quay lại menu
                [[ $exit_code -eq 0 || $exit_code -eq 1 ]] && exit 0
                ;;
            "$OPTIONS")
                "$HOME/.config/rofi/network/options.sh" "from-manager"
                exit_code=$?
                # Exit code 0 = action thành công -> thoát hẳn
                # Exit code 1 = ESC -> thoát hẳn
                # Exit code 2 = Back -> quay lại menu
                [[ $exit_code -eq 0 || $exit_code -eq 1 ]] && exit 0
                ;;
            "$PROPERTIES")
                "$HOME/.config/rofi/network/properties.sh" "from-manager"
                exit_code=$?
                # Exit code 0 = action (QR/disconnect/forget) -> thoát hẳn
                # Exit code 1 = ESC -> thoát hẳn
                # Exit code 2 = Back -> quay lại menu
                [[ $exit_code -eq 0 || $exit_code -eq 1 ]] && exit 0
                ;;
        esac
    done
}

show_main_menu
