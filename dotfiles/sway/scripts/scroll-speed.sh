#!/usr/bin/env bash
# scroll-speed [up|down|reset|restore] — vitesse de défilement des souris (pas le touchpad).
# Bindé sur les boutons latéraux de la souris (custom/mxmaster3).
# La dernière vitesse est gardée dans ~/.local/state/scroll-speed et réappliquée
# au démarrage de sway (restore).
set -euo pipefail

steps=(0.25 0.5 0.75 1 1.5 2 3 4 6 10 15)
state="${XDG_STATE_HOME:-$HOME/.local/state}/scroll-speed"

apply() { swaymsg -q input type:pointer scroll_factor "$1"; }

if [[ "${1:-}" == restore ]]; then
  [[ -s "$state" ]] && apply "$(cat "$state")"
  exit 0
fi

current=$(swaymsg -t get_inputs -r | jq -r '[.[] | select(.type == "pointer") | .scroll_factor // empty][0] // 1')

# Index of the step closest to the current factor.
idx=$(printf '%s\n' "${steps[@]}" | awk -v c="$current" '{d=$1-c; if (d<0) d=-d; if (NR==1 || d<best) {best=d; i=NR-1}} END {print i}')

case "${1:-}" in
  up)    (( idx < ${#steps[@]} - 1 )) && idx=$((idx + 1)) ;;
  down)  (( idx > 0 )) && idx=$((idx - 1)) ;;
  reset) idx=3 ;;
  *)     echo "usage: scroll-speed up|down|reset|restore" >&2; exit 1 ;;
esac

factor=${steps[$idx]}
apply "$factor"
mkdir -p "$(dirname "$state")"
echo "$factor" > "$state"

# Replace the previous notification instead of stacking them.
id_file="${XDG_RUNTIME_DIR:-/tmp}/scroll-speed.notify-id"
id=$(cat "$id_file" 2>/dev/null || echo 0)
notify-send -p -r "$id" -t 1500 -a scroll-speed "Défilement souris" "×$factor" > "$id_file"
