# shellcheck shell=bash
register cli-extra on on "base" "lazygit (dernière release GitHub), translate-shell (trans), ffmpeg (fonction mic : micro → mp3)"

mod_cli_extra_install() {
  apt_install translate-shell ffmpeg
  if have lazygit; then ok "lazygit déjà installé"; return 0; fi
  install_tar_bin "$(gh_asset_url jesseduffield/lazygit '[Ll]inux_x86_64[.]tar[.]gz$')" lazygit
}
