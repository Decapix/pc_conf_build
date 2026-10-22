# shellcheck shell=bash
register nautilus-recent on - "base" "Les 5 derniers dossiers ouverts dans Nautilus en signets de la barre latérale"

mod_nautilus_recent_install() {
  apt_install python3-gi
  mod_nautilus_recent_link
  run systemctl --user daemon-reload
  run systemctl --user enable --now nautilus-recent.service
}

mod_nautilus_recent_link() {
  link bin/nautilus-recent.py "$HOME/.local/bin/nautilus-recent"
  link systemd/nautilus-recent.service "$HOME/.config/systemd/user/nautilus-recent.service"
}
