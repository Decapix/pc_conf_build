# shellcheck shell=bash
register docker on on "base" "Docker CE officiel (+ buildx, compose) + groupe docker"

mod_docker_install() {
  add_apt_repo docker https://download.docker.com/linux/debian/gpg \
    "deb [arch=$(dpkg --print-architecture) signed-by=KEYRING] https://download.docker.com/linux/debian $(os_codename) stable"
  apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  as_root systemctl enable --now docker || warn "docker non démarré (normal dans un conteneur)"
  add_user_to_group docker
}
