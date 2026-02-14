#!/bin/bash

# Toggle group trước
hyprctl dispatch togglegroup

sleep 0.3

# Lấy address window hiện tại
current=$(hyprctl activewindow -j | grep -oP '"address":"0x\K[^"]+')

echo "Current: 0x$current"

# Duyệt qua tất cả clients và tìm những window có grouped
hyprctl clients -j | grep -oP '"address":"0x\K[^"]+|"class":"[^"]+"|"grouped":\[[^\]]+\]' | \
paste - - - | while read addr class grouped; do
    addr=$(echo $addr | cut -d'"' -f1)
    class=$(echo $class | cut -d'"' -f2)
    
    # Kiểm tra nếu grouped chứa current address hoặc address này là current
    if echo "$grouped" | grep -q "$current" || [ "$addr" = "$current" ]; then
        echo "Setting: 0x$addr -> $class"
        hyprctl setprop "address:0x$addr" title "$class"
    fi
done