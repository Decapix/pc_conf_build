# shellcheck shell=bash
register python on off "base" "Python 3 (pip, venv, pipx) + uv"

mod_python_install() {
  apt_install python3 python3-pip python3-venv pipx
  if [[ -x "$HOME/.local/bin/uv" ]]; then
    ok "uv déjà installé"
  else
    # UV_NO_MODIFY_PATH: ~/.local/bin is already in the .zshrc PATH.
    run env UV_NO_MODIFY_PATH=1 sh -c "curl -LsSf https://astral.sh/uv/install.sh | sh"
  fi
}
