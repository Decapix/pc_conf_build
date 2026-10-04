# shellcheck shell=bash
register zsh on on "base" "zsh + oh-my-zsh + .zshrc/.zsh_aliases (pwdc, cdc, readlinkfc, cpr, ran...)"

mod_zsh_install() {
  apt_install zsh
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ok "oh-my-zsh déjà installé"
  else
    # KEEP_ZSHRC: the installer must not overwrite our .zshrc; CHSH/RUNZSH: no prompts.
    run env RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
  mod_zsh_link
  if [[ "$(getent passwd "$USER" | cut -d: -f7)" != */zsh ]]; then
    as_root chsh -s "$(command -v zsh)" "$USER" && ok "shell par défaut : zsh"
  else
    ok "zsh est déjà le shell par défaut"
  fi
}

mod_zsh_link() {
  link zsh/zshrc       "$HOME/.zshrc"
  link zsh/zsh_aliases "$HOME/.zsh_aliases"
  if [[ ! -f "$HOME/.secrets.zsh" ]]; then
    [[ "$DRY_RUN" == 1 ]] && { run "créer ~/.secrets.zsh"; return 0; }
    install -m 600 /dev/null "$HOME/.secrets.zsh"
    printf '# Secrets perso (jamais dans le repo). Exemple :\n# export OPENAI_API_KEY=...\n' \
      >>"$HOME/.secrets.zsh"
    info "~/.secrets.zsh créé (vide) : mets-y tes clés API"
  fi
}
