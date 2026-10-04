# shellcheck shell=bash
register tailscale on off "base" "Tailscale (VPN vers fugax, julestoulet...) puis « tailscale up »"

mod_tailscale_install() {
  local c; c="$(os_codename)"
  add_apt_repo tailscale "https://pkgs.tailscale.com/stable/debian/$c.noarmor.gpg" \
    "deb [signed-by=KEYRING] https://pkgs.tailscale.com/stable/debian $c main"
  apt_install tailscale
  as_root systemctl enable --now tailscaled || true
  info "connecte la machine avec : sudo tailscale up"
}
