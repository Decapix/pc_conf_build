# shellcheck shell=bash
register audio-display on - "base" "Audio (pipewire, pavucontrol) + écran (brightnessctl, wdisplays) + captures"

mod_audio_display_install() {
  apt_install pipewire pipewire-pulse wireplumber pavucontrol pulseaudio-utils \
    brightnessctl wdisplays grim slurp grimshot
  add_user_to_group video
}
