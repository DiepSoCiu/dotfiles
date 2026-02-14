#!/usr/bin/env bash

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
FLAG="/tmp/hypr-group-enabled"
CACHE="$XDG_RUNTIME_DIR/hypr-group-titles"

mkdir -p "$CACHE"

restore() {
    local addr="$1"
    if [[ -f "$CACHE/$addr" ]]; then
        hyprctl dispatch settitle "$(cat "$CACHE/$addr")" >/dev/null 2>&1
        rm -f "$CACHE/$addr"
    fi
}

apply() {
    local addr="$1"
    local title
    title=$(hyprctl clients -j | jq -r ".[] | select(.address==\"$addr\") | .title")
    [[ -z "$title" ]] && return
    echo "$title" > "$CACHE/$addr"
    hyprctl dispatch settitle "[G] $title" >/dev/null 2>&1
}

socat -U UNIX-CONNECT:"$SOCKET" - | while read -r line; do
    case "$line" in
        groupadded*)
            [[ -f "$FLAG" ]] || continue
            apply "$(awk '{print $2}' <<< "$line")"
            ;;
        groupremoved*)
            restore "$(awk '{print $2}' <<< "$line")"
            ;;
        closewindow*)
            rm -f "$CACHE/$(awk '{print $2}' <<< "$line")"
            ;;
    esac
done
