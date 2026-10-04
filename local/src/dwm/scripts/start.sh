#!/usr/bin/env bash

picom &
dunst &
redshift &
brightnessctl -d intel_backlight set 100%
setxkbmap -option ctrl:nocaps
dash ~/.fehbg &
xrdb merge ~/.Xresources &
tmux has-session -t scratchpad 2>/dev/null || tmux new-session -d -s scratchpad
sh ~/.local/src/dwm/scripts/bar.sh &
sh ~/.local/src/dwm/scripts/audio.sh &
