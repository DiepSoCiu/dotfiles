#!/bin/bash

# Script để đổi title của windows khi group trong Hyprland
# Bind với Super+G

# Lấy thông tin window hiện tại
current_window=$(hyprctl activewindow -j)
current_address=$(echo "$current_window" | jq -r '.address')
current_class=$(echo "$current_window" | jq -r '.class')

# Toggle group cho window hiện tại
hyprctl dispatch togglegroup

# Đợi một chút để group được tạo
sleep 0.1

# Lấy tất cả windows trong group
group_windows=$(hyprctl clients -j | jq -r --arg addr "$current_address" '.[] | select(.grouped[] | contains($addr)) | .address')

# Nếu không có group windows, thử lấy chính window hiện tại
if [ -z "$group_windows" ]; then
    group_windows=$(hyprctl clients -j | jq -r --arg addr "$current_address" '.[] | select(.address == $addr and (.grouped | length > 0)) | .grouped[]')
fi

# Đổi title cho mỗi window trong group
echo "$group_windows" | while read -r addr; do
    if [ -n "$addr" ]; then
        # Lấy class của window này
        win_class=$(hyprctl clients -j | jq -r --arg a "$addr" '.[] | select(.address == $a) | .class')
        
        # Set title ngắn gọn dựa trên class
        hyprctl setprop address:$addr title "$win_class" lock
    fi
done