#!/usr/bin/env bash
# screenshot-area [fugax] — capture d'une zone dans ~/Pictures/DATE-zone.png, avec un lien
# ~/DATE-zone.png pendant 2 min. Avec « fugax » (Super+Shift+d) : copiée aussi sur fugax
# (même chemin) et ce chemin dans le presse-papier. Bindé sur Super+Shift+s / Super+Shift+d.
# Les captures *-zone.png sont supprimées au bout de 20 jours, ici et sur fugax (à chaque
# capture et au démarrage de sway : screenshot-area clean).
set -euo pipefail

REMOTE=fugax
DIR="$HOME/Pictures"
KEEP_MIN=$((20 * 24 * 60))
LINK_SEC=120
SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=5)

clean_local() {
  find "$DIR" -maxdepth 1 -type f -name '*-zone.png' -mmin +"$KEEP_MIN" -delete
  # Liens restés si la session s'est terminée avant leurs 2 min.
  find "$HOME" -maxdepth 1 -type l -name '*-zone.png' -mmin +2 -delete
}
clean_remote() {
  ssh "${SSH_OPTS[@]}" "$REMOTE" \
    "find ~/Pictures -maxdepth 1 -type f -name '*-zone.png' -mmin +$KEEP_MIN -delete"
}

if [[ "${1:-}" == clean ]]; then
  clean_local
  clean_remote || true
  exit 0
fi

FILE="$DIR/$(date '+%Y-%m-%d-%T')-zone.png"
LINK="$HOME/$(basename "$FILE")"

fail() { notify-send -u critical "Capture → $REMOTE" "$1"; exit 1; }

# Échap pendant la sélection : grimshot échoue, on abandonne sans rien dire.
grimshot save area "$FILE" > /dev/null || exit 0

ln -s "$FILE" "$LINK"
systemd-run --user --quiet --on-active="$LINK_SEC" rm -f "$LINK" \
  || (sleep "$LINK_SEC"; rm -f "$LINK") > /dev/null 2>&1 &

clean_local

[[ "${1:-}" == fugax ]] || exit 0

scp -q "${SSH_OPTS[@]}" "$FILE" "$REMOTE:$FILE" \
  || fail "Échec de la copie vers $REMOTE (capture gardée en local : $FILE)"
clean_remote || true

printf '%s' "$FILE" | wl-copy \
  || fail "Copiée sur $REMOTE, mais échec du presse-papier"

notify-send -i "$FILE" "Capture → $REMOTE" "$(basename "$FILE")\nchemin copié dans le presse-papier"
