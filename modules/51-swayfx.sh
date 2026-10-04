# shellcheck shell=bash
register swayfx on - "sway" "SwayFX compilé (coins arrondis, ombres, dim) : wlroots + scenefx + swayfx dans /usr/local"

# Versions that work together (SwayFX 0.5.2 = sway 1.10.1 + scenefx 0.4 + wlroots 0.19).
SWAYFX_VER="${SWAYFX_VER:-0.5.2}"
SCENEFX_VER="${SCENEFX_VER:-0.4.1}"
WLROOTS_VER="${WLROOTS_VER:-0.19.0}"

mod_swayfx_install() {
  if [[ -x /usr/local/lib/swayfx && "${FORCE_SWAYFX:-0}" != 1 ]] \
     && /usr/local/lib/swayfx --version 2>/dev/null | grep -q "swayfx version $SWAYFX_VER"; then
    ok "SwayFX $SWAYFX_VER déjà compilé (FORCE_SWAYFX=1 pour recompiler)"
  else
    swayfx_build
  fi
  swayfx_session
}

swayfx_build() {
  apt_install meson ninja-build pkg-config cmake scdoc wayland-protocols \
    libwayland-dev libwayland-bin libegl-dev libgles-dev libgbm-dev libdrm-dev \
    libinput-dev libxkbcommon-dev libxkbcommon-x11-dev libpixman-1-dev libseat-dev \
    libudev-dev libdisplay-info-dev libliftoff-dev hwdata glslang-tools libvulkan-dev \
    liblcms2-dev libxcb1-dev libx11-xcb-dev libxcb-composite0-dev libxcb-icccm4-dev \
    libxcb-res0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-xfixes0-dev \
    libxcb-xinput-dev libxcb-ewmh-dev libxcb-dri3-dev libxcb-present-dev \
    libxcb-errors-dev xwayland libjson-c-dev libpcre2-dev libpango1.0-dev \
    libcairo2-dev libgdk-pixbuf-2.0-dev libevdev-dev libsystemd-dev

  local b="$HOME/.cache/pc_conf_build/swayfx-build"
  export PKG_CONFIG_PATH="/usr/local/lib/x86_64-linux-gnu/pkgconfig:/usr/local/lib/pkgconfig"
  run rm -rf "$b"; run mkdir -p "$b"

  fetch_src "$b" "https://gitlab.freedesktop.org/wlroots/wlroots/-/archive/$WLROOTS_VER/wlroots-$WLROOTS_VER.tar.gz"
  fetch_src "$b" "https://github.com/wlrfx/scenefx/archive/refs/tags/$SCENEFX_VER.tar.gz"
  fetch_src "$b" "https://github.com/WillPower3309/swayfx/archive/refs/tags/$SWAYFX_VER.tar.gz"

  title "compilation wlroots $WLROOTS_VER"
  meson_build "$b/wlroots-$WLROOTS_VER" -Dexamples=false
  as_root ninja -C "$b/wlroots-$WLROOTS_VER/build" install

  title "compilation scenefx $SCENEFX_VER"
  meson_build "$b/scenefx-$SCENEFX_VER"
  as_root ninja -C "$b/scenefx-$SCENEFX_VER/build" install
  as_root ldconfig

  title "compilation swayfx $SWAYFX_VER"
  meson_build "$b/swayfx-$SWAYFX_VER"
  # Only the binary: a full `ninja install` would shadow Debian's sway in /usr/local/bin.
  as_root install -m 755 "$b/swayfx-$SWAYFX_VER/build/sway/sway" /usr/local/lib/swayfx
  ok "$(/usr/local/lib/swayfx --version 2>/dev/null || echo swayfx) installé dans /usr/local/lib/swayfx"
}

fetch_src() { run bash -c "curl -fsSL '$2' | tar -xz -C '$1'"; }

meson_build() {   # meson_build <src dir> [meson options]
  local src="$1"; shift
  run meson setup "$src/build" "$src" --prefix=/usr/local --buildtype=release "$@"
  run ninja -C "$src/build"
}

swayfx_session() {
  root_write /usr/local/bin/swayfx-launch 755 <<LAUNCH
#!/bin/sh
export LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu:\${LD_LIBRARY_PATH:-}
exec /usr/local/lib/swayfx -c "\$HOME/.config/sway/swayfx.conf" "\$@"
LAUNCH
  root_write /usr/share/wayland-sessions/swayfx.desktop <<'DESKTOP'
[Desktop Entry]
Name=SwayFX
Comment=An i3-compatible Wayland compositor (with effects)
Exec=dbus-run-session /usr/local/bin/swayfx-launch
Type=Application
DesktopNames=sway
DESKTOP
  ok "session « SwayFX » ajoutée à l'écran de connexion"
}
