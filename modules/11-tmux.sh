# shellcheck shell=bash
register tmux on on "base" "tmux + .tmux.conf (souris, copie vers le presse-papier)"

mod_tmux_install() {
  apt_install tmux wl-clipboard
  mod_tmux_link
}

mod_tmux_link() { link tmux/tmux.conf "$HOME/.tmux.conf"; }
