#!/bin/bash

# Script fake minimize cho Hyprland sử dụng special workspace
# Lưu trữ thứ tự các cửa sổ trong file để có thể restore theo LIFO (Last In First Out)

STACK_FILE="$HOME/.cache/hyprland_minimize_stack"

# Tạo file stack nếu chưa có
if [ ! -f "$STACK_FILE" ]; then
    touch "$STACK_FILE"
fi

minimize_window() {
    # Lấy address của cửa sổ đang focus
    ACTIVE_ADDRESS=$(hyprctl activewindow -j | jq -r '.address')

    if [ "$ACTIVE_ADDRESS" = "null" ] || [ -z "$ACTIVE_ADDRESS" ]; then
        exit 1
    fi

    # Thêm address vào đầu file (LIFO stack)
    echo "$ACTIVE_ADDRESS" | cat - "$STACK_FILE" > "$STACK_FILE.tmp"
    mv "$STACK_FILE.tmp" "$STACK_FILE"

    # Di chuyển cửa sổ đến special workspace
    hyprctl dispatch movetoworkspacesilent special:minimized,address:$ACTIVE_ADDRESS
}

restore_window() {
    # Đọc address của cửa sổ cuối cùng được minimize (đầu file)
    LAST_ADDRESS=$(head -n 1 "$STACK_FILE" 2>/dev/null)

    if [ -z "$LAST_ADDRESS" ]; then
        exit 1
    fi

    # Xóa address này khỏi stack
    tail -n +2 "$STACK_FILE" > "$STACK_FILE.tmp"
    mv "$STACK_FILE.tmp" "$STACK_FILE"

    # Di chuyển cửa sổ về workspace hiện tại và focus vào nó
    CURRENT_WORKSPACE=$(hyprctl activeworkspace -j | jq -r '.id')
    hyprctl dispatch movetoworkspace $CURRENT_WORKSPACE,address:$LAST_ADDRESS
    hyprctl dispatch focuswindow address:$LAST_ADDRESS
}

# Xử lý tham số
case "$1" in
    minimize|min|m)
        minimize_window
        ;;
    restore|res|r)
        restore_window
        ;;
    *)
        echo "Sử dụng: $0 {minimize|restore}"
        echo "  minimize (min, m) - Minimize cửa sổ hiện tại"
        echo "  restore (res, r)  - Restore cửa sổ minimize gần nhất"
        exit 1
        ;;
esac
