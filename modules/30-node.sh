# shellcheck shell=bash
register node on off "base" "Node.js + npm + pnpm + bun"

mod_node_install() {
  apt_install nodejs npm
  have pnpm || as_root npm install -g pnpm
  if [[ -x "$HOME/.bun/bin/bun" ]]; then
    ok "bun déjà installé"
  else
    # SHELL=/bin/sh: stops the bun installer from appending to .zshrc (already has the bun lines).
    run env SHELL=/bin/sh bash -c "curl -fsSL https://bun.sh/install | bash"
  fi
}
