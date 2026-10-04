#!/usr/bin/env bash

theme="$HOME/.config/rofi/power.rasi"
uptime="$(uptime -p | sed -e 's/up //g')"
host=$(hostname)
shutdown='⏻'
reboot=''
lock=''
suspend='󰤄'
logout='󰈆'
yes=''
no=''
rofi_cmd() {
    rofi -dmenu \
        -p "Uptime: $uptime" \
        -mesg "Uptime: $uptime" \
        -theme "${theme}"
}
confirm_cmd() {
    rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
        -theme-str 'mainbox {children: [ "message", "listview" ];}' \
        -theme-str 'listview {columns: 2; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'textbox {horizontal-align: 0.5;}' \
        -dmenu \
        -p 'Confirmation' \
        -mesg 'Are you Sure?' \
        -theme "${theme}"
}
confirm_exit() {
    echo -e "$yes\n$no" | confirm_cmd
}
run_rofi() {
    echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}
chosen="$(run_rofi)"
case ${chosen} in
$shutdown)
    if [[ "$(confirm_exit)" == "$yes" ]]; then
        poweroff
    fi
    ;;
$reboot)
    if [[ "$(confirm_exit)" == "$yes" ]]; then
        reboot
    fi
    ;;
$lock)
    swaylock
    ;;
$suspend)
    if [[ "$(confirm_exit)" == "$yes" ]]; then
        zzz 2>/dev/null || loginctl suspend || systemctl suspend
    fi
    ;;
$logout)
    if [[ "$(confirm_exit)" == "$yes" ]]; then
        pkill -KILL -u "$USER"
    fi
    ;;
esac
