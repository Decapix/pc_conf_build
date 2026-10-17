#!/usr/bin/env bash
# bt-audio-reset — débloque le son d'un casque/écouteurs Bluetooth resté muet alors que
# tout semble normal côté PC (sortie RUNNING, pas en sourdine) : coupe le profil de la
# carte bluez puis le remet, ce qui recrée le transport A2DP. Bindé sur Super+F4.
set -uo pipefail

done_any=""
for card in $(pactl list cards short | awk '$2 ~ /^bluez_card\./ {print $2}'); do
  profile=$(pactl list cards | awk -v c="$card" '
    $1 == "Name:" { in_card = ($2 == c) }
    in_card && /Active Profile:/ { print $3; exit }')
  [[ -z "$profile" || "$profile" == off ]] && profile=a2dp-sink
  pactl set-card-profile "$card" off
  sleep 1
  pactl set-card-profile "$card" "$profile"
  done_any=1
done

if [[ -z "$done_any" ]]; then
  notify-send -a son "Son Bluetooth" "Aucun appareil audio Bluetooth connecté"
  exit 1
fi

sleep 1
# The reset recreates the sink: make sure it is the default again.
sink=$(pactl list sinks short | awk '$2 ~ /^bluez_output\./ {print $2; exit}')
[[ -n "$sink" ]] && pactl set-default-sink "$sink"
notify-send -a son "Son Bluetooth" "Connexion audio réinitialisée"
paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null || true
