#!/bin/bash

# Script để đổi title của windows khi group trong Hyprland
# Bind với Super+G

# Lấy address của window hiện tại
current_address=$(hyprctl activewindow | grep -oP 'at 0x\K[0-9a-f]+')

# Toggle group cho window hiện tại
hyprctl dispatch togglegroup

# Đợi một chút để group được tạo
sleep 0.1

# Lấy tất cả windows và xử lý
hyprctl clients | awk -v current="0x$current_address" '
/^Window/ { 
    addr = $2
}
/class:/ {
    class = $2
    # Loại bỏ khoảng trắng thừa
    gsub(/^[ \t]+|[ \t]+$/, "", class)
}
/grouped:/ {
    grouped = $0
    # Kiểm tra xem window có trong group không
    if (grouped ~ current || addr == current) {
        if (addr != "") {
            print addr ":::" class
        }
    }
}
' | while IFS=':::' read -r addr class; do
    if [ -n "$addr" ] && [ -n "$class" ]; then
        # Set title ngắn gọn dựa trên class
        hyprctl setprop address:$addr title "$class" lock
    fi
done