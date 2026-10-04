#!/usr/bin/env bash

pkill -9 -x pipewire
pkill -9 -x pipewire-pulse
pkill -9 -x wireplumber
rm -f ${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/pipewire-0*
rm -rf ~/.local/state/wireplumber
pipewire &
sleep 1
pipewire-pulse &
wireplumber &
