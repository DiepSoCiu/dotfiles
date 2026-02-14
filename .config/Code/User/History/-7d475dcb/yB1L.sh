#!/bin/bash

# Script để đổi title của windows khi group trong Hyprland

# Toggle group trước
hyprctl dispatch togglegroup

# Đợi group được tạo
sleep 0.2

# Lấy address của window hiện tại
current_address=$(hyprctl activewindow | grep "0x" | head -1 | awk '{print $NF}')

echo "Current window: $current_address" > /tmp/hypr_group_debug.log

# Lấy tất cả windows trong cùng group
hyprctl clients | while read line; do
    if [[ "$line" =~ ^Window ]]; then
        addr=$(echo "$line" | grep -oP '0x[0-9a-f]+')
        current_win_addr="$addr"
    fi
    
    if [[ "$line" =~ class: ]]; then
        class=$(echo "$line" | awk '{print $2}')
    fi
    
    if [[ "$line" =~ grouped: ]]; then
        # Nếu window này có trong group hoặc chứa current address
        if [[ "$line" =~ $current_address ]] || [[ "$current_win_addr" == "$current_address" ]]; then
            echo "Found grouped window: $current_win_addr with class: $class" >> /tmp/hypr_group_debug.log
            
            if [ -n "$current_win_addr" ] && [ -n "$class" ]; then
                # Thử set title
                hyprctl setprop address:$current_win_addr title "$class"
                echo "Set title for $current_win_addr to $class" >> /tmp/hypr_group_debug.log
            fi
        fi
    fi
done

# Xem log
cat /tmp/hypr_group_debug.log