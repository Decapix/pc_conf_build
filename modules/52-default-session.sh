# shellcheck shell=bash
register default-session on - "sway" "Met SwayFX (ou Sway) comme session par défaut dans GDM"

mod_default_session_install() {
  local session=sway f="/var/lib/AccountsService/users/$USER"
  [[ -f /usr/share/wayland-sessions/swayfx.desktop ]] && session=swayfx
  if as_root test -f "$f"; then
    if as_root grep -q '^Session=' "$f"; then
      as_root sed -i "s/^Session=.*/Session=$session/" "$f"
    else
      as_root sed -i "/^\[User\]/a Session=$session" "$f"
    fi
  else
    printf '[User]\nSession=%s\nSystemAccount=false\n' "$session" | root_write "$f" 600
  fi
  ok "session par défaut : $session (GDM la présélectionne au prochain login)"
}
