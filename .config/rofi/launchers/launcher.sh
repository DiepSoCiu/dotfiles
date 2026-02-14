#!/usr/bin/env bash

dir="$HOME/.config/rofi/launchers"
theme='style'

# Nếu rofi đang chạy → tắt
if pgrep -x rofi >/dev/null; then
    pkill rofi
    exit 0
fi

# Nếu chưa chạy → mở
rofi \
    -show drun \
    -theme "${dir}/${theme}.rasi"
