# shellcheck shell=bash
register network-bt on - "go" "Réseau + Bluetooth : NetworkManager, nm-applet, blueman, bluetuith"

mod_network_bt_install() {
  apt_install network-manager network-manager-gnome bluez bluez-tools blueman
  as_root systemctl enable --now bluetooth || true
  if [[ -x "$HOME/go/bin/bluetuith" ]]; then ok "bluetuith déjà installé"; else
    run env GOBIN="$HOME/go/bin" go install github.com/bluetuith-org/bluetuith@latest
  fi
}
