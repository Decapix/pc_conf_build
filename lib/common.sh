# shellcheck shell=bash
# Shared helpers for install.sh and the modules. Sourced, never executed.

REPO_DIR="${REPO_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
DOT="$REPO_DIR/dotfiles"

STAMP="$(date +%Y%m%d-%H%M%S)"
LOG_DIR="$HOME/.cache/pc_conf_build"
LOG_FILE="$LOG_DIR/install-$STAMP.log"
BACKUP_DIR="$HOME/.dotfiles-backup-$STAMP"   # created only if something is backed up

DRY_RUN="${DRY_RUN:-0}"
# Modules run in subshells, so "apt index is fresh" is a file, not a variable.
APT_FRESH="$LOG_DIR/.apt-fresh-$STAMP"

mkdir -p "$LOG_DIR"

# ---- Output ---------------------------------------------------------------
if [[ -t 1 ]]; then
  C_B=$'\e[1m'; C_G=$'\e[32m'; C_Y=$'\e[33m'; C_R=$'\e[31m'; C_C=$'\e[36m'; C_0=$'\e[0m'
else
  C_B=; C_G=; C_Y=; C_R=; C_C=; C_0=
fi

_log()  { printf '%s\n' "$*" >>"$LOG_FILE"; }
title() { printf '\n%s==> %s%s\n' "$C_B$C_C" "$*" "$C_0"; _log "==> $*"; }
info()  { printf '  %s\n' "$*"; _log "  $*"; }
ok()    { printf '  %s✓%s %s\n' "$C_G" "$C_0" "$*"; _log "  OK $*"; }
warn()  { printf '  %s!%s %s\n' "$C_Y" "$C_0" "$*"; _log "  WARN $*"; }
err()   { printf '  %s✗%s %s\n' "$C_R" "$C_0" "$*" >&2; _log "  ERR $*"; }
die()   { err "$*"; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

# Run a command (or just print it with --dry-run). Output goes to the log too.
run() {
  _log "  \$ $*"
  if [[ "$DRY_RUN" == 1 ]]; then
    printf '  %s[dry-run]%s %s\n' "$C_Y" "$C_0" "$*"
    return 0
  fi
  "$@" 2>&1 | tee -a "$LOG_FILE"
  return "${PIPESTATUS[0]}"
}

# Same as run, but with root rights (sudo unless we already are root).
as_root() {
  if [[ $EUID -eq 0 ]]; then run "$@"; else run sudo "$@"; fi
}

# Write stdin to a root-owned file.
root_write() {   # root_write <dest> [mode]
  local dest="$1" mode="${2:-644}" tmp
  tmp="$(mktemp)"; cat >"$tmp"
  as_root install -D -m "$mode" "$tmp" "$dest"
  rm -f "$tmp"
}

# ---- System ---------------------------------------------------------------
os_codename() { . /etc/os-release && echo "${VERSION_CODENAME:-trixie}"; }

require_debian() {
  [[ -r /etc/os-release ]] || die "/etc/os-release introuvable"
  . /etc/os-release
  [[ "${ID:-}" == debian ]] || die "Ce programme est prévu pour Debian (détecté : ${ID:-?})."
}

sudo_keepalive() {
  [[ $EUID -eq 0 || "$DRY_RUN" == 1 ]] && return 0
  info "Le mot de passe sudo est demandé une seule fois pour toute l'installation."
  sudo -v || die "sudo est nécessaire"
  ( while kill -0 "$$" 2>/dev/null; do sudo -n true; sleep 50; done ) 2>/dev/null &
}

apt_update() {
  [[ -f "$APT_FRESH" ]] && return 0
  as_root apt-get update && touch "$APT_FRESH"
}
apt_stale() { rm -f "$APT_FRESH"; }   # call after adding a repo

apt_install() {
  apt_update
  as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

# apt_key <name> <url>: store a repo signing key as /etc/apt/keyrings/<name>.gpg
apt_key() {
  local keyring="/etc/apt/keyrings/$1.gpg" key
  [[ -f "$keyring" ]] && return 0
  as_root install -d -m 755 /etc/apt/keyrings
  if [[ "$DRY_RUN" == 1 ]]; then run "curl $2 > $keyring"; return 0; fi
  key="$(mktemp)"
  curl -fsSL "$2" -o "$key" || { rm -f "$key"; return 1; }
  # Some vendors ship an ASCII-armored key, others an already binary one.
  if grep -q 'BEGIN PGP' "$key"; then
    gpg --dearmor <"$key" | root_write "$keyring" 644
  else
    root_write "$keyring" 644 <"$key"
  fi
  rm -f "$key"
}

# add_apt_repo <name> <key-url> <deb line, with KEYRING standing for the key path>
add_apt_repo() {
  local name="$1" keyring="/etc/apt/keyrings/$1.gpg"
  if [[ -f "/etc/apt/sources.list.d/$name.list" && -f "$keyring" ]]; then
    ok "dépôt $name déjà présent"; return 0
  fi
  apt_key "$name" "$2" || return 1
  printf '%s\n' "${3//KEYRING/$keyring}" | root_write "/etc/apt/sources.list.d/$name.list"
  apt_stale
  ok "dépôt $name ajouté"
}

# ---- Dotfiles -------------------------------------------------------------
# link <repo-relative source> <destination>
# Idempotent: an existing correct link is kept; anything else at the
# destination is moved into $BACKUP_DIR (same path relative to $HOME).
link() {
  local src="$DOT/$1" dst="$2"
  [[ -e "$src" ]] || { err "source absente : $src"; return 1; }
  if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
    ok "${dst/#$HOME/~} (déjà lié)"; return 0
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    local rel="${dst#"$HOME"/}"
    run mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
    run mv "$dst" "$BACKUP_DIR/$rel"
    info "ancien ${dst/#$HOME/~} sauvegardé dans ${BACKUP_DIR/#$HOME/~}/$rel"
  fi
  run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst"
  ok "${dst/#$HOME/~} -> ${src/#$HOME/~}"
}

# ---- Downloads ------------------------------------------------------------
# gh_asset_url <owner/repo> <regex>: download URL of the latest release asset matching regex.
gh_asset_url() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
    | jq -r --arg re "$2" '.assets[].browser_download_url | select(test($re))' | head -n1
}

# Install a single static binary into /usr/local/bin.
install_bin() {   # install_bin <url> <name>
  local tmp; tmp="$(mktemp)"
  run curl -fsSL "$1" -o "$tmp" && as_root install -m 755 "$tmp" "/usr/local/bin/$2"
  local rc=$?; rm -f "$tmp"; return $rc
}

add_user_to_group() {
  [[ $EUID -eq 0 ]] && return 0
  if id -nG "$USER" | tr ' ' '\n' | grep -qx "$1"; then
    ok "$USER est déjà dans le groupe $1"
  else
    as_root usermod -aG "$1" "$USER" && warn "ajouté au groupe $1 : effectif après déconnexion/reconnexion"
  fi
}

# install_tar_bin <url of .tar.gz> <binary name inside>: extract one binary into /usr/local/bin.
install_tar_bin() {
  local d; d="$(mktemp -d)"
  run bash -c "curl -fsSL '$1' | tar -xz -C '$d'" && as_root install -m 755 "$d/$2" "/usr/local/bin/$2"
  local rc=$?; rm -rf "$d"; return $rc
}

# install_deb_url <url>: download a .deb and install it with its dependencies.
install_deb_url() {
  local f; f="$(mktemp --suffix=.deb)"; chmod 644 "$f"
  run curl -fsSL "$1" -o "$f" && apt_install "$f"
  local rc=$?; rm -f "$f"; return $rc
}
