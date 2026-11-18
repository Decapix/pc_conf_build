#!/usr/bin/env bash
# date-full — JSON pour le module waybar custom/date :
#   text    -> date courte affichée dans la barre
#   tooltip -> date complète affichée au survol (popup juste en dessous du module)
# La locale fr_FR n'est pas installée sur le système : noms des jours/mois en dur.
set -euo pipefail

jours=(lundi mardi mercredi jeudi vendredi samedi dimanche)  # date +%u : 1 = lundi
mois=(janvier février mars avril mai juin juillet août septembre octobre novembre décembre)

j=$(date +%u)
m=$(date +%-m)

printf '{"text":"  %s","tooltip":"%s %s %s %s"}' \
    "$(date '+%d/%m/%Y')" \
    "${jours[j-1]}" \
    "$(date +%-d)" \
    "${mois[m-1]}" \
    "$(date +%Y)"
