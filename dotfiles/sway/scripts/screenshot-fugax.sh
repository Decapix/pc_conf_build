#!/usr/bin/env bash
# screenshot-fugax — capture d'une zone (comme Super+Shift+s) dans ~/Pictures, copiée aussi
# sur fugax (même chemin), puis ce chemin (identique sur les deux machines) dans le presse-papier.
# Bindé sur Super+Shift+d. Notification si tout a réussi, critique sinon.
set -euo pipefail

REMOTE=fugax
FILE="$HOME/Pictures/$(date '+%Y-%m-%d-%T')-screenshot.png"

fail() { notify-send -u critical "Capture → $REMOTE" "$1"; exit 1; }

# Échap pendant la sélection : grimshot échoue, on abandonne sans rien dire.
grimshot save area "$FILE" > /dev/null || exit 0

scp -q -o BatchMode=yes -o ConnectTimeout=5 "$FILE" "$REMOTE:$FILE" \
  || fail "Échec de la copie vers $REMOTE (capture gardée en local : $FILE)"

printf '%s' "$FILE" | wl-copy \
  || fail "Copiée sur $REMOTE, mais échec du presse-papier"

notify-send -i "$FILE" "Capture → $REMOTE" "$(basename "$FILE")\nchemin copié dans le presse-papier"
