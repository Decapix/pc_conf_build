# shellcheck shell=bash
register claude-notify on - "sway" "Notification sway quand Claude Code a fini de répondre ou attend une autorisation"

mod_claude_notify_install() {
  mod_claude_notify_link
  local f="$HOME/.claude/settings.json" cmd="~/.local/bin/claude-notify 2>/dev/null || true"
  run mkdir -p "$HOME/.claude"
  [[ -f "$f" ]] || echo '{}' >"$f"
  if jq -e '.hooks.Stop[]?.hooks[]? | select(.command | test("claude-notify"))' "$f" >/dev/null; then
    ok "hooks Claude Code déjà présents"; return 0
  fi
  [[ "$DRY_RUN" == 1 ]] && { run "ajout des hooks Stop/Notification dans $f"; return 0; }
  cp "$f" "$f.bak-$STAMP"
  # Appends to existing hook lists instead of replacing them.
  jq --arg c "$cmd" '
    .hooks.Stop = ((.hooks.Stop // []) + [{"hooks":[{"type":"command","command":$c,"async":true}]}])
    | .hooks.Notification = ((.hooks.Notification // []) + [{"matcher":"permission_prompt","hooks":[{"type":"command","command":$c,"async":true}]}])
  ' "$f.bak-$STAMP" >"$f"
  ok "hooks ajoutés à $f (ancien fichier : $f.bak-$STAMP)"
}

mod_claude_notify_link() { link bin/claude-notify.sh "$HOME/.local/bin/claude-notify"; }
