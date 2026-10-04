# shellcheck shell=bash
register base on on "" "Outils CLI de base (git curl jq ripgrep btop ranger tree httpie vim...)"

mod_base_install() {
  apt_install ca-certificates curl wget gnupg git whiptail unzip zip xz-utils \
    build-essential make jq ripgrep tree rsync htop btop ranger httpie vim less \
    man-db bash-completion lsof traceroute bind9-dnsutils netcat-traditional \
    iputils-ping pciutils usbutils
}
