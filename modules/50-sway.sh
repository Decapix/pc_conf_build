# shellcheck shell=bash
register sway on - "base" "Sway + waybar + wofi + mako + swaylock/swayidle + kitty + police Nerd Font + mes dotfiles"

mod_sway_install() {
  apt_install sway swaybg swaylock swayidle xwayland waybar wofi mako-notifier \
    libnotify-bin playerctl wl-clipboard grim slurp grimshot jq upower \
    xdg-desktop-portal-wlr xdg-desktop-portal-gtk kitty fontconfig xz-utils
  install_nerd_font
  mod_sway_link
}

mod_sway_link() {
  link sway   "$HOME/.config/sway"
  link waybar "$HOME/.config/waybar"
  link wofi   "$HOME/.config/wofi"
  link kitty  "$HOME/.config/kitty"
  link bin/change_wallpaper.sh "$HOME/.local/bin/change_wallpaper.sh"
  # theme.conf is local state (switched by F8 / switch-theme.sh), not tracked in git.
  if [[ ! -e "$DOT/kitty/theme.conf" ]]; then
    run ln -s "$HOME/.config/kitty/mocha.conf" "$DOT/kitty/theme.conf"
  fi
  run mkdir -p "$HOME/Pictures/Wallpapers"
  if [[ ! -e "$HOME/Pictures/Wallpapers/actual.jpg" ]]; then
    run cp "$DOT/sway/images/wallpaper.jpg" "$HOME/Pictures/Wallpapers/actual.jpg"
  fi
}

install_nerd_font() {
  local dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
  if fc-list | grep -qi 'JetBrainsMono Nerd Font'; then ok "JetBrainsMono Nerd Font déjà installée"; return 0; fi
  run mkdir -p "$dir"
  run bash -c "curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz | tar -xJ -C '$dir'"
  run fc-cache -f "$dir"
  ok "JetBrainsMono Nerd Font installée"
}
