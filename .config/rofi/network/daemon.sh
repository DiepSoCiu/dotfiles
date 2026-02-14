#!/usr/bin/env bash
IFACE=$(nmcli device | awk '$2=="wifi" {print $1; exit}')
CACHE_DIR="/tmp/rofi-wifi"
DAEMON_PID="$CACHE_DIR/daemon.pid"
[[ -z "$IFACE" ]] && exit 1
# Check if already running
[[ -f "$DAEMON_PID" ]] && kill -0 $(cat "$DAEMON_PID") 2>/dev/null && exit 0
mkdir -p "$CACHE_DIR"
while true; do
    ACTIVE=$(nmcli device status | grep "^$IFACE" | awk '{print $4}')
    RAW=$(nmcli -f SSID,SECURITY,BARS dev wifi list ifname "$IFACE" 2>/dev/null)

    LIST=$(echo "$RAW" | awk -F'  +' -v active="$ACTIVE" '
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
    echo "$LIST" > "$CACHE_DIR/list"
    echo "$ACTIVE" > "$CACHE_DIR/state"
    sleep 2
done &
echo $! > "$DAEMON_PID"
