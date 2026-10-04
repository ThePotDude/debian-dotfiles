#!/usr/bin/env bash

shutdown="󰐥  Shutdown"
reboot="󰜉  Reboot"
suspend="󰒲  Suspend"

options="$suspend
$reboot
$shutdown"

selected=$(printf '%s\n' "$options" | wofi --dmenu \
    --insensitive \
    --width 300 \
    --lines 4 \
    --style "$HOME/.config/wofi/power_menu_style.css" \
    --cache-file /dev/null)

case "$selected" in
    "$shutdown")
        systemctl poweroff
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$suspend")
        systemctl suspend
        ;;
    *)
        exit 0
        ;;
esac
