# shellcheck shell=bash
register go on on "base" "Go (golang) — nécessaire pour dl et bluetuith"

mod_go_install() {
  apt_install golang
  run mkdir -p "$HOME/go/bin"
}
