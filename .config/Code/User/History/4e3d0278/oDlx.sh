#!/usr/bin/env bash

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Lưu title gốc theo window address
CACHE="$XDG_RUNTIME_DIR/hypr-group-titles"
mkdir -p "$CACHE"

handle_group_added() {
    local addr="$1"

    # lấy title hiện tại
    title=$(hyprctl clients -j | jq -r ".[] | select(.address==\"$addr\") | .title")

    [[ -z "$title" ]] && return

    # cache title gốc
    echo "$title" > "$CACHE/$addr"

    # set title mới (gọn hơn)
    hyprctl dispatch settitle "[G] $title"
}

handle_group_removed() {
    local addr="$1"
    local file="$CACHE/$addr"

    if [[ -f "$file" ]]; then
        original=$(cat "$file")
        hyprctl dispatch settitle "$original"
        rm "$file"
    fi
}

socat -U UNIX-CONNECT:"$SOCKET" - | while read -r line; do
    case "$line" in
        groupadded*)
            addr=$(echo "$line" | awk '{print $2}')
            handle_group_added "$addr"
            ;;
        groupremoved*)
            addr=$(echo "$line" | awk '{print $2}')
            handle_group_removed "$addr"
            ;;
    esac
done
