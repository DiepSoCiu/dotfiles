#!/bin/bash

# Nếu có tham số "toggle" thì đổi input method
if [ "$1" = "toggle" ]; then
    current=$(fcitx5-remote)
    if [ "$current" -eq 2 ]; then
        fcitx5-remote -c
    else
        fcitx5-remote -o
    fi
fi

# Hiển thị trạng thái hiện tại
current=$(fcitx5-remote)
if [ "$current" -eq 2 ]; then
    echo "󰌌 󰬝 "
else
    echo "󰌌 󰬌 "
fi
