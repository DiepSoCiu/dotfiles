#!/bin/bash

# Toggle group
hyprctl dispatch togglegroup

sleep 0.2

# Lấy workspace hiện tại
workspace=$(hyprctl activeworkspace | grep "workspace ID" | awk '{print $3}')

# Set title cho tất cả windows trong workspace này
hyprctl clients | awk -v ws="$workspace" '
/^Window/ {addr = $2}
/workspace:/ {if ($2 == ws) ws_match=1; else ws_match=0}
/class:/ {if (ws_match) class = $2}
/grouped: 0x/ {
    if (ws_match && addr != "" && class != "") {
        print addr " " class
    }
}
' | while read addr class; do
    [ -n "$addr" ] && hyprctl setprop address:$addr title "$class"
done