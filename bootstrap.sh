#!/usr/bin/env bash
# Première commande sur une machine neuve : récupère ce repo puis lance install.sh.
#   bash <(curl -fsSL https://raw.githubusercontent.com/Decapix/pc_conf_build/main/bootstrap.sh) [mode] [options]
# (si le repo est privé : voir docs/NOUVEAU-PC.md, étape « repo privé »)
set -euo pipefail

REPO="Decapix/pc_conf_build"
DEST="${PC_CONF_DIR:-$HOME/Tocuments/camputing/pc_conf_build}"

sudo_() { if [[ $EUID -eq 0 ]]; then "$@"; else sudo "$@"; fi; }

if ! command -v git >/dev/null || ! command -v curl >/dev/null; then
  sudo_ apt-get update
  sudo_ apt-get install -y git curl ca-certificates
fi

if [[ -d "$DEST/.git" ]]; then
  echo "Repo déjà présent dans $DEST : mise à jour"
  git -C "$DEST" pull --ff-only
else
  mkdir -p "$(dirname "$DEST")"
  if ! git clone "https://github.com/$REPO.git" "$DEST" 2>/dev/null; then
    echo "Clonage anonyme impossible (repo privé ?) : connexion avec gh"
    if ! command -v gh >/dev/null; then
      sudo_ install -d -m 755 /etc/apt/keyrings
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo_ tee /etc/apt/keyrings/github-cli.gpg >/dev/null
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/github-cli.gpg] https://cli.github.com/packages stable main" \
        | sudo_ tee /etc/apt/sources.list.d/github-cli.list >/dev/null
      sudo_ apt-get update && sudo_ apt-get install -y gh
    fi
    gh auth status >/dev/null 2>&1 || gh auth login
    gh repo clone "$REPO" "$DEST"
  fi
fi

exec "$DEST/install.sh" "$@"
