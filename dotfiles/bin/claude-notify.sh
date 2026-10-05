#!/usr/bin/env bash
# Hook Claude Code -> notification mako (sway). Reçoit le JSON du hook sur stdin.
#   Stop                          : Claude a fini de répondre
#   Notification/permission_prompt : Claude attend une autorisation
# Rien n'est envoyé si la discussion est déjà affichée à l'écran.
input="$(cat)"

# Is this Claude session already on screen? (focused sway window = the kitty showing it)
# Not checked while the screen is locked: then you can't see it, so always notify.
on_screen() {
  pgrep -x swaylock >/dev/null && return 1
  local focused; focused="$(swaymsg -t get_tree 2>/dev/null | jq -r '.. | objects | select(.focused==true) | .pid // empty' | head -n1)"
  [[ -n "$focused" ]] || return 1
  if [[ -n "${TMUX_PANE:-}" ]]; then
    # Inside tmux: the tmux client running in the focused kitty must currently
    # show this session's pane (list-clients gives each client's visible pane).
    local pid pane
    while read -r pid pane; do
      [[ "$(ps -o ppid= -p "$pid" | tr -d ' ')" == "$focused" && "$pane" == "$TMUX_PANE" ]] && return 0
    done < <(tmux list-clients -F '#{client_pid} #{pane_id}')
    return 1
  fi
  # Without tmux: is the focused window one of our ancestor processes?
  local p=$PPID
  while [[ -n "$p" && "$p" -gt 1 ]]; do
    [[ "$p" == "$focused" ]] && return 0
    p="$(ps -o ppid= -p "$p" | tr -d ' ')"
  done
  return 1
}
on_screen && exit 0
event="$(jq -r '.hook_event_name // empty' <<<"$input")"
project="$(basename "$(jq -r '.cwd // empty' <<<"$input")")"

case "$event" in
  Stop)         title="Claude a fini ✓"; body="$project"; urgency=normal ;;
  Notification) title="Claude attend ta réponse"; body="$project — $(jq -r '.message // empty' <<<"$input")"; urgency=critical ;;
  *)            exit 0 ;;
esac

notify-send -a "Claude Code" -u "$urgency" -t 6000 "$title" "$body"
