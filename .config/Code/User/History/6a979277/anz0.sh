#!/usr/bin/env bash
# Current Theme
dir="$HOME/.config/rofi/powermenu/type-1"
theme='style-2'
# CMDs
uptime=`uptime -p | sed -e 's/up //g'`
host=`hostname`
# Options
shutdown=' Shutdown'
reboot=' Reboot'
lock=' Lock'
suspend=' Sleep'
logout='󰍃 Logout'
yes='󰄴 Yes'
no=' No'
# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p "$host" \
        -mesg "Uptime: $uptime" \
        -theme ${dir}/${theme}.rasi
}
# Confirmation CMD
confirm_cmd() {
    rofi -theme-str 'window {location: northeast; anchor: center; fullscreen: false; width: 250px;}' \
        -theme-str 'mainbox {children:  ["mainboxb"];}' \
        -theme-str 'mainboxb {children: [ "mainboxc"];}' \
        -theme-str 'mainboxc {children: [ "mainboxd"];}' \
        -theme-str 'mainboxd {children: [ "mainboxe"];}' \
        -theme-str 'mainboxe {children: [ "mainboxf"];}' \
        -theme-str 'mainboxf {children: [ "mainboxg"];}' \
        -theme-str 'mainboxg {children: [ "message", "listview" ];}' \
        -theme-str 'listview {columns: 2; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'textbox {horizontal-align: 0.5;}' \
        -dmenu \
        -p 'Confirmation' \
        -mesg 'Are you Sure?' \
        -theme ${dir}/${theme}.rasi
}
# Ask for confirmation
confirm_exit() {
    echo -e "$yes\n$no" | confirm_cmd
}
# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}
# Execute Command
run_cmd() {
    if [[ $1 == '--shutdown' ]]; then
        systemctl poweroff
    elif [[ $1 == '--reboot' ]]; then
        systemctl reboot
    elif [[ $1 == '--suspend' ]]; then
        # Lock session before suspend
        loginctl lock-session
        # Pause music and mute
        mpc -q pause
        amixer set Master mute
        # Suspend
        systemctl suspend
        # Turn on display after wake up
        hyprctl dispatch dpms on
    elif [[ $1 == '--logout' ]]; then
        if [[ "$DESKTOP_SESSION" == 'openbox' ]]; then
            openbox --exit
        elif [[ "$DESKTOP_SESSION" == 'bspwm' ]]; then
            bspc quit
        elif [[ "$DESKTOP_SESSION" == 'i3' ]]; then
            i3-msg exit
        elif [[ "$DESKTOP_SESSION" == 'plasma' ]]; then
            qdbus org.kde.ksmserver /KSMServer logout 0 0 0
        elif [[ "$XDG_CURRENT_DESKTOP" == 'Hyprland' ]]; then
            hyprctl dispatch exit
        fi
    elif [[ $1 == '--lock' ]]; then
        if [[ -x '/usr/bin/hyprlock' ]]; then
            hyprlock
        elif [[ -x '/usr/bin/betterlockscreen' ]]; then
            betterlockscreen -l
        elif [[ -x '/usr/bin/i3lock' ]]; then
            i3lock
        fi
    fi
}
# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
        selected="$(confirm_exit)"
        if [[ "$selected" == "$yes" ]]; then
            run_cmd --shutdown
        fi
        ;;
    $reboot)
        selected="$(confirm_exit)"
        if [[ "$selected" == "$yes" ]]; then
            run_cmd --reboot
        fi
        ;;
    $lock)
        selected="$(confirm_exit)"
        if [[ "$selected" == "$yes" ]]; then
            run_cmd --lock
        fi
        ;;
    $suspend)
        selected="$(confirm_exit)"
        if [[ "$selected" == "$yes" ]]; then
            run_cmd --suspend
        fi
        ;;
    $logout)
        selected="$(confirm_exit)"
        if [[ "$selected" == "$yes" ]]; then
            run_cmd --logout
        fi
        ;;
esac