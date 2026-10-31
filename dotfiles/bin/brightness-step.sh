#!/usr/bin/env bash
# brightness-step up|down : pas géométrique (25 % de la valeur courante, au moins 1 cran),
# donc fin quand l'écran est sombre : 100 → 75 → 56 → 42 → 32 → 24 → 18 → 14 → 11 → 8 → 6 → 5 → 4 → 3 → 2 → 1 %.
# Plancher au cran 1 (jamais d'écran noir).
set -euo pipefail
dir=${1:?up|down}
cur=$(brightnessctl get)
max=$(brightnessctl max)
step=$(( (cur + 2) / 4 )); (( step < 1 )) && step=1
case $dir in
  up)   new=$(( cur + step )); (( new > max )) && new=$max ;;
  down) new=$(( cur - step )); (( new < 1 )) && new=1 ;;
  *)    echo "usage: ${0##*/} up|down" >&2; exit 1 ;;
esac
brightnessctl -q set "$new"
