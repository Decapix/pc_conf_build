#!/usr/bin/env bash
# Block idle (lock + screen off) while any audio is playing (YouTube in a
# non-fullscreen Firefox tab, mpv, Spotify...). Firefox doesn't inhibit idle
# by itself on this sway setup, so we ask the players via MPRIS (playerctl).
# Audio streams can't be used: Firefox keeps them running even when paused.

state=""
while true; do
    if playerctl -a status 2>/dev/null | grep -qx Playing; then
        new="open"
    else
        new="fullscreen"
    fi
    if [ "$new" != "$state" ]; then
        swaymsg "[shell=\".*\"] inhibit_idle $new" >/dev/null 2>&1 && state=$new
    fi
    sleep 20
done
