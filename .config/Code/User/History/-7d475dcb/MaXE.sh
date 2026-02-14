#!/bin/bash

# Toggle group
hyprctl dispatch togglegroup

sleep 0.2

# Lấy address của window hiện tại
current_addr=$(hyprctl activewindow | grep -oP '0x[0-9a-f]+' | head -1)

# Lấy tất cả windows trong group và gán tag + đổi title
hyprctl clients | awk -v curr="$current_addr" '
/^Window/ { addr = $2 }
/class:/ { class = $2 }
/grouped:/ { 
    if ($0 ~ curr || addr == curr) {
        if (addr != "" && class != "") {
            print addr " " class
        }
    }
}
' | while read addr class; do
    if [ -n "$addr" ]; then
        # Gán tag để đánh dấu window này đã group
        hyprctl dispatch tagwindow "+grouped" "$addr"
        # Đổi title
        hyprctl setprop "address:$addr" title "$class"
    fi
done