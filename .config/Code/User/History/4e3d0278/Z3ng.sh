#!/usr/bin/env bash

FLAG="/tmp/hypr-group-enabled"
CACHE="$XDG_RUNTIME_DIR/hypr-group-titles"

mkdir -p "$CACHE"

clients=$(hyprctl clients -j)

if [[ -f "$FLAG" ]]; then
    # ===== TẮT =====
    rm "$FLAG"

    for f in "$CACHE"/*; do
        [[ -f "$f" ]] || continue
        addr=$(basename "$f")
        title=$(cat "$f")
        hyprctl dispatch settitle "$title" >/dev/null 2>&1
        rm "$f"
    done

    notify-send "Hyprland" "Group title OFF"
else
    # ===== BẬT =====
    touch "$FLAG"

    echo "$clients" | jq -c '.[] | select(.grouped==true)' | while read -r win; do
        addr=$(jq -r '.address' <<< "$win")
        title=$(jq -r '.title' <<< "$win")

        [[ -z "$title" ]] && continue

        echo "$title" > "$CACHE/$addr"
        hyprctl dispatch settitle "[G] $title" >/dev/null 2>&1
    done

    notify-send "Hyprland" "Group title ON"
fi
