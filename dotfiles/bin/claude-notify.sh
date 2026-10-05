#!/usr/bin/env bash
# Hook Claude Code -> notification mako (sway). Reçoit le JSON du hook sur stdin.
#   Stop                          : Claude a fini de répondre
#   Notification/permission_prompt : Claude attend une autorisation
input="$(cat)"
event="$(jq -r '.hook_event_name // empty' <<<"$input")"
project="$(basename "$(jq -r '.cwd // empty' <<<"$input")")"

case "$event" in
  Stop)         title="Claude a fini ✓"; body="$project"; urgency=normal ;;
  Notification) title="Claude attend ta réponse"; body="$project — $(jq -r '.message // empty' <<<"$input")"; urgency=critical ;;
  *)            exit 0 ;;
esac

notify-send -a "Claude Code" -u "$urgency" -t 6000 "$title" "$body"
