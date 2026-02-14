hyprctl dispatch togglegroup

sleep 0.1

hyprctl clients | grep -A 20 "grouped:" | grep -B 1 "class:" | grep -v "^--$" | paste -d ' ' - - | while read -r line; do
    address=$(echo "$line" | grep -oP 'Window \K[0-9a-fx]+')
    class=$(echo "$line" | grep -oP 'class: \K[^,]+')
    
    if [ -n "$address" ] && [ -n "$class" ]; then
        hyprctl dispatch settitle "address:$address" "$class" 2>/dev/null
    fi
done