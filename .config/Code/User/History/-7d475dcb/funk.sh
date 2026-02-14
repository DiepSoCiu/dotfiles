#!/bin/bash

# Lấy class của window hiện tại
current_class=$(hyprctl activewindow | grep "class:" | awk '{print $2}')

# Toggle group
hyprctl dispatch togglegroup

sleep 0.2

# Set title cho window hiện tại
hyprctl setprop title "$current_class"

# Chuyển sang window tiếp theo trong group và set title
hyprctl dispatch changegroupactive f
sleep 0.1
next_class=$(hyprctl activewindow | grep "class:" | awk '{print $2}')
hyprctl setprop title "$next_class"

# Quay lại window ban đầu
hyprctl dispatch changegroupactive b