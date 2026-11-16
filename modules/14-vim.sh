# shellcheck shell=bash
register vim on on "base" "vim + .vimrc (Alt+↑/↓ : déplacer la ligne)"

mod_vim_install() {
  apt_install vim
  mod_vim_link
}

mod_vim_link() { link vim/vimrc "$HOME/.vimrc"; }
