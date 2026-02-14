# Thay dòng này:
hyprctl setprop address:$addr title "$class" lock

# Bằng một trong các cách sau:

# Lấy 5 ký tự đầu
short_title=$(echo "$class" | cut -c1-5)
hyprctl setprop address:$addr title "$short_title" lock

# Hoặc lấy chữ cái đầu tiên (viết hoa)
short_title=$(echo "$class" | head -c 1 | tr '[:lower:]' '[:upper:]')
hyprctl setprop address:$addr title "$short_title" lock

# Hoặc tự map theo ý bạn
case "$class" in
    firefox) short_title="FF" ;;
    kitty) short_title="Term" ;;
    *) short_title="$class" ;;
esac
hyprctl setprop address:$addr title "$short_title" lock