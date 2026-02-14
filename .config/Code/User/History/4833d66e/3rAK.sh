#!/bin/bash
# Script tự động cập nhật wallpaper trong hyprlock.conf khi thay đổi qua waypaper

# Lấy đường dẫn wallpaper hiện tại từ waypaper config
WALLPAPER=$(grep "^wallpaper = " ~/.config/waypaper/config.ini | cut -d' ' -f3)

# File hyprlock config
HYPRLOCK_CONF="$HOME/.config/hypr/hyprlock.conf"

# Kiểm tra file có tồn tại không
if [ ! -f "$HYPRLOCK_CONF" ]; then
    echo "Error: hyprlock.conf not found at $HYPRLOCK_CONF"
    exit 1
fi

# Backup config trước khi sửa (optional)
# cp "$HYPRLOCK_CONF" "$HYPRLOCK_CONF.bak"

# Cập nhật tất cả dòng "path = " trong background và image sections
sed -i '/^background {/,/^}/ s|path = .*|path = '"$WALLPAPER"'|' "$HYPRLOCK_CONF"
sed -i '/^# Profile-Photo/,/^}/ s|path = .*|path = '"$WALLPAPER"'|' "$HYPRLOCK_CONF"

echo "✓ Updated hyprlock wallpaper to: $WALLPAPER"