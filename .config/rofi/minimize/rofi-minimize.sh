#!/bin/bash

# Script rofi để hiển thị và restore các cửa sổ đã minimize
STACK_FILE="$HOME/.cache/hyprland_minimize_stack"
CONFIG_DIR="$HOME/.config/rofi/minimize"

# Tạo file stack nếu chưa có
if [ ! -f "$STACK_FILE" ]; then
    touch "$STACK_FILE"
fi

# Đọc tất cả các address từ stack
mapfile -t ADDRESSES < "$STACK_FILE"

# Nếu không có cửa sổ nào thì vẫn hiển thị rofi trống
WINDOW_LIST=""
declare -A WINDOW_MAP
INDEX=1

if [ ${#ADDRESSES[@]} -gt 0 ]; then
    # Tạo danh sách các cửa sổ để hiển thị trong rofi
    # Cửa sổ mới nhất (đầu file) sẽ hiển thị ở dòng đầu tiên
    for addr in "${ADDRESSES[@]}"; do
        # Lấy thông tin cửa sổ từ hyprctl
        WINDOW_INFO=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$addr\")")

        if [ -n "$WINDOW_INFO" ]; then
            TITLE=$(echo "$WINDOW_INFO" | jq -r '.title')
            CLASS=$(echo "$WINDOW_INFO" | jq -r '.class')

            # Tạo label hiển thị với số thứ tự (1 = mới nhất)
            LABEL="$INDEX. [$CLASS] $TITLE"
            WINDOW_LIST="$WINDOW_LIST$LABEL\n"
            WINDOW_MAP["$LABEL"]="$addr"
            ((INDEX++))
        fi
    done
fi

# Hiển thị rofi (có thể trống nếu không có cửa sổ)
SELECTED=$(echo -e "$WINDOW_LIST" | rofi -dmenu -i -p "Minimized Windows"  -theme ~/.config/rofi/minimize/style.rasi)

if [ -n "$SELECTED" ]; then
    # Lấy address tương ứng
    SELECTED_ADDR="${WINDOW_MAP[$SELECTED]}"

    if [ -n "$SELECTED_ADDR" ]; then
        # Xóa address này khỏi stack
        grep -v "^$SELECTED_ADDR$" "$STACK_FILE" > "$STACK_FILE.tmp"
        mv "$STACK_FILE.tmp" "$STACK_FILE"

        # Di chuyển cửa sổ về workspace hiện tại
        CURRENT_WORKSPACE=$(hyprctl activeworkspace -j | jq -r '.id')
        hyprctl dispatch movetoworkspace $CURRENT_WORKSPACE,address:$SELECTED_ADDR
        hyprctl dispatch focuswindow address:$SELECTED_ADDR
    fi
fi
