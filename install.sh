#!/usr/bin/env bash
# pc_conf_build — remet mon setup (Debian + GNOME + SwayFX + terminal) en place.
# Documentation : README.md et docs/
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$REPO_DIR/lib/common.sh"

# ---- Module registry --------------------------------------------------------
# Each modules/*.sh calls `register` once and defines:
#   mod_<id>_install   packages, builds, system changes (+ its own links)
#   mod_<id>_link      (optional) dotfile links only — used by `./install.sh link`
declare -a MOD_ORDER=()
declare -A MOD_DESC=() MOD_FULL=() MOD_VM=() MOD_DEPS=()

# register <id> <full: on|off> <vm: on|off|-> <deps "a b"> <description>
register() {
  MOD_ORDER+=("$1"); MOD_FULL[$1]="$2"; MOD_VM[$1]="$3"; MOD_DEPS[$1]="$4"; MOD_DESC[$1]="$5"
}

for f in "$REPO_DIR"/modules/*.sh; do
  # shellcheck source=/dev/null
  source "$f"
done

usage() {
  cat <<EOF
Usage : ./install.sh [mode] [options]

Modes
  full     PC complet : terminal + dev + SwayFX + barre + réseau/bluetooth...
  vm       Juste mes habitudes terminal (zsh, alias, dl, pwdc, tmux, git/gh, docker...)
  link     Ne fait QUE les symlinks des dotfiles (aucun paquet installé)
  (rien)   Menu interactif pour choisir le mode

Options
  -y, --yes          Pas de menu de choix : prend les modules cochés par défaut du mode
  --only a,b,c       Exactement ces modules (dépendances ajoutées automatiquement)
  --skip a,b         Retire ces modules de la sélection
  -n, --dry-run      Affiche les commandes sans rien exécuter
  -l, --list         Liste les modules et quitte
  -h, --help         Cette aide

Exemples
  ./install.sh                     # menu
  ./install.sh vm -y               # VM : tout le mode vm, sans question
  ./install.sh full --skip swayfx  # PC complet sans compiler SwayFX
  ./install.sh link                # re-créer les symlinks seulement
EOF
}

list_modules() {
  printf '%-16s %-5s %-5s %-22s %s\n' MODULE FULL VM DEPENDANCES DESCRIPTION
  local id
  for id in "${MOD_ORDER[@]}"; do
    printf '%-16s %-5s %-5s %-22s %s\n' "$id" "${MOD_FULL[$id]}" "${MOD_VM[$id]}" "${MOD_DEPS[$id]:--}" "${MOD_DESC[$id]}"
  done
}

# ---- Arguments ----------------------------------------------------------------
MODE="" ASSUME_YES=0 ONLY="" SKIP=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    full|vm|link) MODE="$1" ;;
    -y|--yes)     ASSUME_YES=1 ;;
    --only)       ONLY="${2:?--only attend une liste}"; shift ;;
    --skip)       SKIP="${2:?--skip attend une liste}"; shift ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -l|--list)    list_modules; exit 0 ;;
    -h|--help)    usage; exit 0 ;;
    *)            usage; die "argument inconnu : $1" ;;
  esac
  shift
done

[[ $EUID -eq 0 && -z "${SUDO_USER:-}" ]] && warn "Lancé en root : tout sera installé pour root."
[[ -n "${SUDO_USER:-}" ]] && die "Lance-moi SANS sudo (en ton utilisateur) : je demande sudo moi-même."
require_debian

USE_WHIPTAIL=0
[[ -t 0 && -t 1 ]] && have whiptail && USE_WHIPTAIL=1

# ---- Mode choice ------------------------------------------------------------------
if [[ -z "$MODE" ]]; then
  if [[ "$USE_WHIPTAIL" == 1 ]]; then
    MODE=$(whiptail --title "pc_conf_build" --menu "Que veux-tu installer ?" 15 72 3 \
      full "PC complet (terminal + dev + SwayFX + barre...)" \
      vm   "VM : seulement mes habitudes terminal" \
      link "Seulement les symlinks des dotfiles" 3>&1 1>&2 2>&3) || exit 0
  else
    echo "Mode ? 1) full  2) vm  3) link"
    read -r c
    case "$c" in 1|full) MODE=full ;; 2|vm) MODE=vm ;; 3|link) MODE=link ;; *) die "mode invalide" ;; esac
  fi
fi

# Modules visible in this mode, and their default state.
default_state() {   # default_state <id> -> on|off|-
  case "$MODE" in
    full) echo "${MOD_FULL[$1]}" ;;
    vm)   echo "${MOD_VM[$1]}" ;;
    link) if declare -F "mod_${1//-/_}_link" >/dev/null; then echo "${MOD_FULL[$1]}"; else echo -; fi ;;
  esac
}

declare -A SELECTED=()
contains() { [[ ",$1," == *",$2,"* ]]; }

if [[ -n "$ONLY" ]]; then
  for id in ${ONLY//,/ }; do
    [[ -n "${MOD_DESC[$id]:-}" ]] || die "module inconnu : $id (voir --list)"
    SELECTED[$id]=1
  done
elif [[ "$ASSUME_YES" == 1 ]]; then
  for id in "${MOD_ORDER[@]}"; do [[ "$(default_state "$id")" == on ]] && SELECTED[$id]=1; done
elif [[ "$USE_WHIPTAIL" == 1 ]]; then
  items=()
  for id in "${MOD_ORDER[@]}"; do
    st="$(default_state "$id")"; [[ "$st" == - ]] && continue
    items+=("$id" "${MOD_DESC[$id]}" "$st")
  done
  choice=$(whiptail --title "pc_conf_build — mode $MODE" --separate-output \
    --checklist "Espace = cocher/décocher, Entrée = valider" 24 100 16 "${items[@]}" 3>&1 1>&2 2>&3) || exit 0
  for id in $choice; do SELECTED[$id]=1; done
else
  for id in "${MOD_ORDER[@]}"; do
    st="$(default_state "$id")"; [[ "$st" == - ]] && continue
    def=n; [[ "$st" == on ]] && def=o
    read -r -p "$id — ${MOD_DESC[$id]} [o/n, défaut $def] " a
    [[ "${a:-$def}" =~ ^[oOyY] ]] && SELECTED[$id]=1
  done
fi

for id in ${SKIP//,/ }; do unset "SELECTED[$id]"; done

# Pull in dependencies (link mode only links, so it never needs any).
if [[ "$MODE" != link ]]; then
  changed=1
  while [[ "$changed" == 1 ]]; do
    changed=0
    for id in "${!SELECTED[@]}"; do
      for dep in ${MOD_DEPS[$id]}; do
        if [[ -z "${SELECTED[$dep]:-}" ]]; then
          SELECTED[$dep]=1; changed=1; info "ajout de « $dep » (requis par $id)"
        fi
      done
    done
  done
fi

PLAN=()
for id in "${MOD_ORDER[@]}"; do [[ -n "${SELECTED[$id]:-}" ]] && PLAN+=("$id"); done
[[ ${#PLAN[@]} -eq 0 ]] && { info "Rien de sélectionné."; exit 0; }

title "Mode $MODE — modules : ${PLAN[*]}"
info "Journal : $LOG_FILE"
[[ "$DRY_RUN" == 1 ]] && warn "dry-run : aucune commande ne sera exécutée"
[[ "$MODE" != link ]] && sudo_keepalive
trap 'rm -f "$APT_FRESH"' EXIT

# ---- Run ------------------------------------------------------------------------------
declare -a DONE=() FAILED=() SKIPPED=()
for id in "${PLAN[@]}"; do
  fn="mod_${id//-/_}_install"
  [[ "$MODE" == link ]] && fn="mod_${id//-/_}_link"
  if ! declare -F "$fn" >/dev/null; then SKIPPED+=("$id"); continue; fi
  title "[$id] ${MOD_DESC[$id]}"
  # Subshell: a failing module cannot kill the run or leak variables.
  # (Not inside `if`: bash would silently disable set -e there.)
  ( set -e; "$fn" ); rc=$?
  if [[ $rc -eq 0 ]]; then DONE+=("$id"); else FAILED+=("$id"); err "le module $id a échoué (voir le journal)"; fi
done

# ---- Summary --------------------------------------------------------------------------
title "Résumé"
[[ ${#DONE[@]}    -gt 0 ]] && ok   "réussis : ${DONE[*]}"
[[ ${#SKIPPED[@]} -gt 0 ]] && info "sans action dans ce mode : ${SKIPPED[*]}"
[[ ${#FAILED[@]}  -gt 0 ]] && err  "échoués : ${FAILED[*]} — relance : ./install.sh $MODE --only $(IFS=,; echo "${FAILED[*]}")"
[[ -d "$BACKUP_DIR" ]] && info "anciens fichiers sauvegardés dans : $BACKUP_DIR"
info "journal complet : $LOG_FILE"
if [[ "$MODE" != link && ${#DONE[@]} -gt 0 ]]; then
  echo
  info "À faire maintenant : déconnecte-toi puis reconnecte-toi (groupes docker/input, shell zsh, session SwayFX)."
fi
[[ ${#FAILED[@]} -eq 0 ]]
