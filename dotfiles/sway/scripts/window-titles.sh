#!/usr/bin/env bash
# Short tab/title-bar names, applied with sway's title_format (the real window
# title is untouched: waybar, claude-notify… still see it).
#   firefox → "firefox"   zim → "zim"   zed → "zed - <root folder>"
#   kitty   → its own title, set by zsh (see zshrc: "kitty <repo|program>")
#   other   → application name (app_id / X11 class, without the reverse-DNS prefix)
# Started by config.d/titles (exec_always): a reload replaces the previous instance.

pidfile="${XDG_RUNTIME_DIR:-/tmp}/sway-window-titles.pid"
if old=$(cat "$pidfile" 2>/dev/null) && [[ -n "$old" ]]; then
  pkill -P "$old" 2>/dev/null; kill "$old" 2>/dev/null
fi
echo $$ >"$pidfile"

# Reads windows as JSON lines {id, app, name} and sets their title_format.
apply() {
  local id app name label
  while IFS=$'\t' read -r id app name; do
    case "${app,,}" in
      kitty)     label='%title' ;;
      firefox*)  label=firefox ;;
      dev.zed.*) name="${name%% — *}"
                 [[ -z "$name" || "$name" == "empty project" ]] && label=zed || label="zed - $name" ;;
      '')        label='%title' ;;
      *)         label="${app##*.}"; label="${label,,}" ;;
    esac
    label="${label//\\/\\\\}"; label="${label//\"/\\\"}"
    swaymsg "[con_id=$id] title_format \"$label\"" >/dev/null
  done
}

fields='[.id, (.app_id // .window_properties.class // ""), (.name // "")] | @tsv'

# Windows already open, then every new window / title change.
swaymsg -t get_tree | jq -r ".. | objects | select((.type == \"con\" or .type == \"floating_con\") and (.pid // 0) > 0) | $fields" | apply
swaymsg -m -t subscribe '["window"]' |
  jq --unbuffered -r "select(.change == \"new\" or .change == \"title\") | .container | $fields" | apply
