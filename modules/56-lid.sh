# shellcheck shell=bash
register lid on - "" "Capot fermé sur secteur = pas de veille (le travail continue) ; sur batterie = veille"

mod_lid_install() {
  # HandleLidSwitch (battery) keeps Debian's default: suspend.
  root_write /etc/systemd/logind.conf.d/10-lid.conf <<'CONF'
# pc_conf_build (module lid): closing the lid on AC power must not suspend,
# so long jobs (builds, Claude Code...) keep running. Sway locks the screen instead.
[Login]
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
CONF
  # SIGHUP makes logind re-read its config without killing the session (a restart would).
  as_root systemctl kill -s HUP systemd-logind || warn "redémarre le PC pour appliquer"
  ok "capot : ignoré sur secteur, veille sur batterie"
}
