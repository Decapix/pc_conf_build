#!/usr/bin/env bash
# theme-switch [toggle|dark|light|status] — passe tout le PC en clair / sombre.
#
# Un seul réglage système (le même que GNOME), relayé par xdg-desktop-portal-gtk.
# Chaque appli le suit en direct, sans redémarrer :
#   - color-scheme  -> Firefox, Zed (theme mode "system"), kitty (*-theme.auto.conf), apps GTK4/libadwaita
#   - gtk-theme     -> apps GTK3 : Zim, pavucontrol, nm-connection-editor, blueman...
set -euo pipefail

iface=org.gnome.desktop.interface
current() { [[ "$(gsettings get $iface color-scheme)" == "'prefer-dark'" ]] && echo dark || echo light; }

case "${1:-toggle}" in
  dark|light) want="$1" ;;
  toggle)     [[ "$(current)" == dark ]] && want=light || want=dark ;;
  status)     current; exit 0 ;;
  *)          echo "usage: theme-switch [toggle|dark|light|status]" >&2; exit 1 ;;
esac

if [[ "$want" == dark ]]; then
  gsettings set $iface color-scheme prefer-dark
  gsettings set $iface gtk-theme Adwaita-dark
  kitty_theme=mocha
else
  gsettings set $iface color-scheme prefer-light
  gsettings set $iface gtk-theme Adwaita
  kitty_theme=light
fi

# Fallback for kitty when no auto theme applies (kitty.conf includes theme.conf).
ln -sfn "$HOME/.config/kitty/$kitty_theme.conf" "$HOME/.config/kitty/theme.conf"

command -v notify-send >/dev/null && notify-send -t 1500 "Thème" "$([[ $want == dark ]] && echo 'Sombre 🌙' || echo 'Clair ☀️')"
exit 0
