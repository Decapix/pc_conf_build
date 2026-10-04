# shellcheck shell=bash
register cloud on off "base" "Cloud : OpenTofu (tofu) + Scaleway CLI (scw)"

mod_cloud_install() {
  # OpenTofu signs the repo metadata and the packages with two different keys.
  apt_key opentofu https://get.opentofu.org/opentofu.gpg
  apt_key opentofu-repo https://packages.opentofu.org/opentofu/tofu/gpgkey
  printf 'deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main\n' \
    | root_write /etc/apt/sources.list.d/opentofu.list
  apt_stale
  apt_install tofu
  if have scw; then ok "scw déjà installé"; else
    install_bin "$(gh_asset_url scaleway/scaleway-cli '_linux_amd64$')" scw
  fi
}
