#!/usr/bin/env bash

RASI="$HOME/.config/rofi/network/style2.rasi"
IFACE=$(nmcli device | awk '$2=="wifi" {print $1; exit}')

[[ -z "$IFACE" ]] && notify-send "WiFi Error" "No interface" && exit 1

BACK_BUTTON=" Back"

# Check if called from network-manager
FROM_MANAGER="$1"

# Kiểm tra xem có đang kết nối WiFi không
WIFI_STATE=$(nmcli device status | grep "^$IFACE" | awk '{print $3}')
[[ "$WIFI_STATE" != "connected" ]] && notify-send "WiFi" "Not connected to any network" && exit 1

# Lấy thông tin như trong script gốc
SSID=$(nmcli dev wifi show-password | grep -oP '(?<=SSID: ).*' | head -1)
PASSWORD=$(nmcli dev wifi show-password | grep -oP '(?<=Password: ).*' | head -1)
ACTIVE_IP=$(nmcli -t -f IP4.ADDRESS dev show "$IFACE" | awk -F'[:/]' '{print $2}')

# Function to show QR Code
show_qrcode() {
    local ssid="$1"
    local password="$2"

    if ! command -v qrencode &> /dev/null; then
        notify-send "QR Code Error" "qrencode is not installed. Please install it first."
        return
    fi

    if [ -z "$password" ]; then
        notify-send "QR Code Error" "Cannot share network without saved password."
        return
    fi

    # Detect security type
    local conn_uuid=$(nmcli -t -f NAME,UUID connection show | grep "^${ssid}:" | cut -d':' -f2)
    local security="WPA"
    if [ -n "$conn_uuid" ]; then
        local key_mgmt=$(nmcli -g 802-11-wireless-security.key-mgmt connection show "$conn_uuid" 2>/dev/null)
        if [ -z "$key_mgmt" ] || [ "$key_mgmt" = "none" ]; then
            security="nopass"
        else
            security="WPA"
        fi
    fi

    local qr_string="WIFI:T:${security};S:${ssid};P:${password};;"
    local qr_file="/tmp/wifi-qr-${ssid}.png"

    qrencode -o "$qr_file" -s 10 -m 2 \
        --foreground=282828 \
        --background=ebdbb2 \
        "$qr_string"

    # Display QR code with Rofi (no text, only image)
    local rofi_override="
        window { width: 400px; }
        listview { lines: 1; scrollbar: false; }
        element { orientation: vertical; padding: 35px; children: [ element-icon ]; }
        element-icon { enabled: true; size: 300px; horizontal-align: 0.5; }
        entry { enabled: false; }
        inputbar { enabled: false; }
        element selected.normal {
            background-color:            @white;
            text-color:                  @white;
        }
    "

    echo -e "\0icon\x1f${qr_file}" | \
    rofi -dmenu -i -show-icons -p "WiFi QR Code" -theme "$RASI" \
         -theme-str "$rofi_override" >/dev/null

    # Cleanup
    rm -f "$qr_file" 2>/dev/null
}

# Tạo options với thông tin (3 dòng đầu + 3 actions)
# Thêm Back button nếu được gọi từ network-manager Ở CUỐI
if [[ "$FROM_MANAGER" == "from-manager" ]]; then
    OPTIONS="SSID: ${SSID}\nPassword: ${PASSWORD}\nIP Address: ${ACTIVE_IP}\n Disconnect\n Forget\n QR Code\n${BACK_BUTTON}"
    DISABLED_INDICES="0,1,2"
else
    OPTIONS="SSID: ${SSID}\nPassword: ${PASSWORD}\nIP Address: ${ACTIVE_IP}\n Disconnect\n Forget\n QR Code"
    DISABLED_INDICES="0,1,2"
fi

# Hiển thị menu
SELECTION=$(echo -e "$OPTIONS" | rofi -dmenu -i \
    -theme "$RASI" \
    -p "WiFi Properties" \
    -no-custom \
    -format s \
    -a "$DISABLED_INDICES")

# Kiểm tra nếu chọn Back - quay lại network-manager
if [[ "$SELECTION" == "$BACK_BUTTON" ]]; then
    exit 2
fi

# Nếu không chọn gì (ESC) - THOÁT HẲN
if [[ -z "$SELECTION" ]]; then
    exit 1
fi

disconnect_wifi() {
    ACTIVE_SSID=$(nmcli -t -f GENERAL.CONNECTION dev show "$IFACE" | cut -d':' -f2)
    nmcli con down id "$ACTIVE_SSID" &>/dev/null
    notify-send "WiFi" "Disconnected from $ACTIVE_SSID"
}

forget_wifi() {
    ACTIVE_SSID=$(nmcli -t -f GENERAL.CONNECTION dev show "$IFACE" | cut -d':' -f2)
    nmcli con down id "$ACTIVE_SSID" &>/dev/null
    nmcli con delete id "$ACTIVE_SSID" &>/dev/null
    notify-send "WiFi" "Forgot network $ACTIVE_SSID"
}

case "$SELECTION" in
    " Disconnect")
        disconnect_wifi
        exit 0
        ;;
    " Forget")
        forget_wifi
        exit 0
        ;;
    " QR Code")
        show_qrcode "$SSID" "$PASSWORD"
        exit 0
        ;;
esac
