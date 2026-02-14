#!/usr/bin/env bash

RASI="$HOME/.config/rofi/network/style.rasi"
IFACE=$(nmcli device | awk '$2=="wifi" {print $1; exit}')
PASSWORD_ENTER=" Connect"
BACK_BUTTON=" Back"
SCAN_BUTTON=" Scan WiFi"

# Daemon files
CACHE_DIR="/tmp/rofi-wifi"
WIFI_CACHE="$CACHE_DIR/list"
STATE_CACHE="$CACHE_DIR/state"

[[ -z "$IFACE" ]] && notify-send "WiFi Error" "No interface" && exit 1

# Check if called from network-manager
FROM_MANAGER="$1"

wireless_interface_state() {
    ACTIVE_SSID=$(cat "$STATE_CACHE" 2>/dev/null)
    WIFI_LIST=$(cat "$WIFI_CACHE" 2>/dev/null)

    [[ -z "$WIFI_LIST" ]] && {
        ACTIVE_SSID=$(nmcli device status | grep "^$IFACE" | awk '{print $4}')
        RAW=$(nmcli -f SSID,SECURITY,BARS dev wifi list ifname "$IFACE" 2>/dev/null)
        wifi_list
    }
}

wifi_list() {
    WIFI_LIST=$(echo "$RAW" | awk -F'  +' -v active="$ACTIVE_SSID" '
        NR>1 && !seen[$1]++ && $1!="--" && $1!=active {
            ssid = $1
            security = $2
            bars = $3

            # Chuyển đổi bars
            gsub(/\*\*\*\*/, "▂▄▆█", bars)
            gsub(/\*\*\*/, "▂▄▆_", bars)
            gsub(/\*\*/, "▂▄__", bars)
            gsub(/\*/, "▂___", bars)

            # Cắt SSID nếu quá dài
            if(length(ssid) > 25) ssid = substr(ssid, 1, 22) "..."

            # Format: BARS SSID
            printf "%-5s %-28s\n", bars, ssid
        }
    ')
}

scan_wifi() {
    local wifi_state=$(nmcli radio wifi)

    # Nếu WiFi đang tắt, bật lên trước
    if [[ "$wifi_state" == "disabled" ]]; then
        notify-send "WiFi" "Turning WiFi ON for scanning..."
        nmcli radio wifi on
        sleep 2
    fi

    notify-send "WiFi" "Scanning networks..."
    nmcli device wifi rescan ifname "$IFACE" 2>/dev/null
    sleep 2

    # Refresh lại danh sách WiFi
    ACTIVE_SSID=$(nmcli device status | grep "^$IFACE" | awk '{print $4}')
    RAW=$(nmcli -f SSID,SECURITY,BARS dev wifi list ifname "$IFACE" 2>/dev/null)
    wifi_list

    notify-send "WiFi" "Scan complete"
}

rofi_menu() {
    while true; do
        wireless_interface_state

        local h="Searching:"
        local m="Connected"
        [[ -n "$ACTIVE_SSID" && "$ACTIVE_SSID" != "--" ]] && m="Connected: $ACTIVE_SSID" || m="Connected: None"

        # Thêm Scan và Back button nếu được gọi từ network-manager
        local menu_content=""
        if [[ "$FROM_MANAGER" == "from-manager" ]]; then
            menu_content="$SCAN_BUTTON\n$BACK_BUTTON\n"
        fi
        menu_content="${menu_content}${WIFI_LIST}"

        SELECTION=$(echo -e "$menu_content" | rofi -dmenu -i -theme "$RASI" -p "$h" -mesg "$m" -no-custom -format s)

        # Kiểm tra nếu chọn Scan
        if [[ "$SELECTION" == "$SCAN_BUTTON" ]]; then
            scan_wifi
            continue
        fi

        # Kiểm tra nếu chọn Back - quay lại network-manager
        if [[ "$SELECTION" == "$BACK_BUTTON" ]]; then
            exit 2
        fi

        # Nếu không chọn gì (ESC) - THOÁT HẲN
        if [[ -z "$SELECTION" ]]; then
            exit 1
        fi

        # Parse SSID: bỏ BARS, chỉ lấy tên
        SSID=$(echo "$SELECTION" | sed 's/^[▂▄▆█_]\+  *//' | sed 's/^[ ]*//' | sed 's/  *$//')

        # Lấy security từ nmcli
        SECURITY=$(nmcli -f SSID,SECURITY dev wifi list ifname "$IFACE" | grep "^$SSID" | awk '{for(i=2;i<=NF;i++) printf "%s ", $i}')

        selection_action

        # Nếu không phải từ manager thì thoát sau khi kết nối
        [[ "$FROM_MANAGER" != "from-manager" ]] && exit 0
    done
}

disconnect_current() {
    [[ "$(nmcli device status | grep "^$IFACE" | awk '{print $3}')" == "connected" ]] && {
        PREVIOUS_SSID=$(nmcli -t -f GENERAL.CONNECTION dev show "$IFACE" | cut -d':' -f2)
        nmcli con down id "$PREVIOUS_SSID" &>/dev/null
    }
}

reconnect_previous() {
    [[ -n "$PREVIOUS_SSID" ]] && {
        nmcli con up "$PREVIOUS_SSID" ifname "$IFACE" &>/dev/null
        PREVIOUS_SSID=""
    }
}

connect() {
    disconnect_current

    # Xóa connection cũ nếu tồn tại (fix bug kết nối lần đầu)
    nmcli con delete "$1" &>/dev/null

    notify-send "WiFi" "Connecting to $1..."

    local result=$(nmcli dev wifi con "$1" password "$2" ifname "$IFACE" 2>&1)

    if echo "$result" | grep -q "successfully activated"; then
        notify-send "WiFi" "Connected to $1"
        PREVIOUS_SSID=""
        return 0
    else
        reconnect_previous
        return 1
    fi
}

stored_connection() {
    disconnect_current
    notify-send "WiFi" "Connecting to $1..."

    local result=$(nmcli dev wifi con "$1" ifname "$IFACE" 2>&1)

    if echo "$result" | grep -q "successfully activated"; then
        notify-send "WiFi" "Connected to $1"
        PREVIOUS_SSID=""
        return 0
    else
        reconnect_previous
        return 1
    fi
}

enter_password() {
    # Kiểm tra xem đã có profile lưu chưa VÀ đã từng kết nối thành công
    local has_profile=false
    local icon=""  # Mặc định: khóa (chưa kết nối)

    # Kiểm tra profile tồn tại
    if nmcli -t -f NAME con show | grep -qxF "$SSID"; then
        # Kiểm tra xem profile có timestamp (đã từng kết nối thành công)
        local timestamp=$(nmcli -g connection.timestamp con show "$SSID" 2>/dev/null)
        if [[ -n "$timestamp" && "$timestamp" != "0" ]]; then
            has_profile=true
            icon=""  # Mở khóa (đã lưu và đã kết nối thành công)
        fi
    fi

    while true; do
        # Tạo menu CHỈ CÓ nút Connect
        local menu_options="$PASSWORD_ENTER"

        PASS=$(echo -e "$menu_options" | rofi -dmenu -theme "$RASI" \
            -p "Password:" \
            -mesg "WiFi: $SSID <span font_family='JetBrainsMono Nerd Font'
                                     size='9000'
                                     rise='2000'>$icon</span>" \
            -theme-str 'message{enabled:true;}' \
            -theme-str 'listview{lines:1;}' \
            -format "s" \
            -filter "")

        # ESC - QUAY VỀ WIFI LIST
        if [[ -z "$PASS" ]]; then
            return
        fi

        # Nếu chọn Connect (kết nối với profile đã lưu)
        if [[ "$PASS" == "$PASSWORD_ENTER" ]]; then
            if stored_connection "$SSID"; then
                # Kết nối thành công - THOÁT HẲN
                exit 0
            else
                # Kết nối thất bại - HIỆN LẠI PANEL để thử lại
                notify-send "WiFi Error" "Connection failed, try again"
            fi
            continue
        fi

        # Còn lại: coi như nhập password
        if connect "$SSID" "$PASS"; then
            # Kết nối thành công - THOÁT HẲN
            exit 0
        else
            # Mật khẩu sai - HIỆN LẠI PANEL để thử lại
            notify-send "WiFi Error" "Wrong password, try again"
        fi
    done
}

selection_action() {
    [[ -n "$SELECTION" ]] && {
        if [[ "$ACTIVE_SSID" == "$SSID" ]]; then
            nmcli con up "$SSID" ifname "$IFACE" &>/dev/null
            # Kết nối lại WiFi hiện tại - THOÁT HẲN
            exit 0
        else
            if [[ "$SECURITY" =~ "WPA" ]] || [[ "$SECURITY" =~ "WEP" ]]; then
                # Mở password panel (sẽ tự exit 0 khi thành công)
                enter_password
            else
                # WiFi không có security
                stored_connection "$SSID"
                # Kết nối thành công - THOÁT HẲN
                exit 0
            fi
        fi
    }
}

rofi_menu
