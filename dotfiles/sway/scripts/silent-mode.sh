#!/usr/bin/env bash
# silent-mode [toggle|status] — mode silencieux : mako n'affiche plus aucune notification
# et les sons des onglets de messagerie (WhatsApp Web…) sont coupés. Le reste de l'audio
# (vidéo, visio) continue : Firefox nomme chaque flux d'après le titre de l'onglet
# (media.name), on ne mute que ceux qui matchent MUTE_TABS.
# toggle : bindé sur F11 ; status : JSON pour le module waybar custom/silent.
set -euo pipefail

MUTE_TABS='whatsapp'   # regex (insensible à la casse) sur le titre de l'onglet
PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/silent-mode-watch.pid"

is_on() { makoctl mode | grep -qx silent; }

# mute_tabs 1|0 [index] : (dé)mute les flux Firefox dont l'onglet matche MUTE_TABS.
mute_tabs() {
  pactl -f json list sink-inputs 2>/dev/null \
    | jq -r --arg re "$MUTE_TABS" --arg idx "${2:-}" '.[]
        | select($idx == "" or (.index | tostring) == $idx)
        | select(.properties["application.name"] == "Firefox")
        | select((.properties["media.name"] // "") | test($re; "i"))
        | .index' \
    | while read -r i; do pactl set-sink-input-mute "$i" "$1" || true; done
}

# Firefox ouvre un nouveau flux à chaque son : on surveille les créations tant que le
# mode est actif (et on s'arrête seul si mako a été relancé et a perdu le mode).
watch_streams() {
  pactl subscribe | while read -r line; do
    is_on || exit 0
    [[ $line =~ ^Event\ \'new\'\ on\ sink-input\ \#([0-9]+) ]] && mute_tabs 1 "${BASH_REMATCH[1]}"
  done
}

# Le watcher est lancé via setsid : tuer sa session emporte aussi `pactl subscribe`.
stop_watch() {
  [[ -f $PIDFILE ]] && pkill -s "$(cat "$PIDFILE")" 2>/dev/null || true
  rm -f "$PIDFILE"
}

case "${1:-toggle}" in
  toggle)
    makoctl mode -t silent > /dev/null
    stop_watch
    if is_on; then
      mute_tabs 1
      setsid "$0" watch > /dev/null 2>&1 &
      echo $! > "$PIDFILE"
    else
      mute_tabs 0
      # Leaving silent mode: drop what arrived meanwhile instead of popping it all up.
      makoctl dismiss --all
    fi
    pkill -RTMIN+9 waybar || true   # refresh custom/silent ("signal": 9)
    ;;
  watch) watch_streams ;;
  status)
    if is_on; then
      echo '{"text": "󰂛  silencieux", "tooltip": "Notifications et sons WhatsApp coupés (F11 pour réactiver)", "class": "on"}'
    else
      echo '{"text": ""}'
    fi
    ;;
  *) echo "usage: silent-mode [toggle|status]" >&2; exit 1 ;;
esac
