# shellcheck shell=bash
register gestures on - "base" "Gestes touchpad 3/4 doigts (libinput-gestures)"

mod_gestures_install() {
  apt_install libinput-tools wmctrl xdotool python3
  if have libinput-gestures; then ok "libinput-gestures déjà installé"; else
    local d; d="$(mktemp -d)"
    run git clone --depth 1 https://github.com/bulletmark/libinput-gestures.git "$d"
    as_root make -C "$d" install
    rm -rf "$d"
  fi
  add_user_to_group input
  mod_gestures_link
  # Starts it in GNOME too (sway starts it from custom/touchpad_gestures).
  run libinput-gestures-setup autostart || true
}

mod_gestures_link() { link gestures/libinput-gestures.conf "$HOME/.config/libinput-gestures.conf"; }
