#!/usr/bin/env bash
# silent-mode [toggle|status] — mode silencieux : mako n'affiche plus aucune notification.
# toggle : bindé sur F11 ; status : JSON pour le module waybar custom/silent.
set -euo pipefail

is_on() { makoctl mode | grep -qx silent; }

case "${1:-toggle}" in
  toggle)
    makoctl mode -t silent > /dev/null
    # Leaving silent mode: drop what arrived meanwhile instead of popping it all up.
    is_on || makoctl dismiss --all
    pkill -RTMIN+9 waybar || true   # refresh custom/silent ("signal": 9)
    ;;
  status)
    if is_on; then
      echo '{"text": "󰂛  silencieux", "tooltip": "Notifications masquées (F11 pour réactiver)", "class": "on"}'
    else
      echo '{"text": ""}'
    fi
    ;;
  *) echo "usage: silent-mode [toggle|status]" >&2; exit 1 ;;
esac
