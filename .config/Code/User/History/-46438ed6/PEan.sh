#!/usr/bin/env bash

FLAG="/tmp/hypr-group-enabled"
CACHE="$XDG_RUNTIME_DIR/hypr-group-titles"

if [[ -f "$FLAG" ]]; then
    # OFF → restore tất cả
    rm -f "$FLAG"
    for f in "$CACHE"/*; do
        [[ -f "$f" ]] || continue
        addr=$(basename "$f")
        hyprctl dispatch settitle "$(cat "$f")" >/dev/null 2>&1
        rm -f "$f"
    done
else
    # ON → đánh dấu, daemon sẽ xử lý event
    touch "$FLAG"
fi
