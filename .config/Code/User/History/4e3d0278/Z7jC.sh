#!/bin/bash

hyprctl clients -j | jq -r '.[] | select(.grouped != []) | @json' | while read -r window; do
    address=$(echo "$window" | jq -r '.address')
    class=$(echo "$window" | jq -r '.class')
    hyprctl dispatch settitle "address:$address" "$class" 2>/dev/null
done