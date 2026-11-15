# shellcheck shell=bash
register firefox on - "" "Firefox : onglets sur 2 lignes (chrome/userChrome.css multi-lignes lié dans chaque profil)"

# Tab Mix Plus (github.com/onemen/TabMixPlus) est une extension XUL « legacy » :
# Firefox >= 57 ne peut plus l'installer. Sur Firefox moderne, la barre d'onglets
# en plusieurs lignes se fait avec chrome/userChrome.css + la pref
# toolkit.legacyUserProfileCustomizations.stylesheets (posée dans user.js).

FIREFOX_LEGACY_CSS_PREF='toolkit.legacyUserProfileCustomizations.stylesheets'

mod_firefox_install() {
  mod_firefox_link
  info "Redémarre Firefox : les onglets passent sur 2 lignes (--multirow-n-rows dans userChrome.css)."
}

mod_firefox_link() {
  local ini="$HOME/.mozilla/firefox/profiles.ini" path profile
  [[ -r "$ini" ]] || { warn "pas de ~/.mozilla/firefox/profiles.ini : rien à faire"; return 0; }
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    case "$path" in
      /*) profile="$path" ;;
      *)  profile="$HOME/.mozilla/firefox/$path" ;;
    esac
    [[ -d "$profile" ]] || { warn "profil introuvable : $profile"; continue; }
    run mkdir -p "$profile/chrome"
    link firefox/userChrome.css "$profile/chrome/userChrome.css"
    _firefox_ensure_userjs "$profile"
  done < <(awk -F= '/^Path=/ {print $2}' "$ini")
}

# user.js : jamais écrasé — pref ajoutée si absente, sinon lien vers celui du dépôt.
_firefox_ensure_userjs() {
  local profile="$1" userjs="$profile/user.js"
  local line="user_pref(\"$FIREFOX_LEGACY_CSS_PREF\", true);"
  if [[ -L "$userjs" ]]; then
    ok "${userjs/#$HOME/~} (déjà lié)"
    return 0
  fi
  if [[ -e "$userjs" ]]; then
    if grep -qF "$FIREFOX_LEGACY_CSS_PREF" "$userjs"; then
      ok "${userjs/#$HOME/~} : pref déjà présente"
    elif [[ "$DRY_RUN" == 1 ]]; then
      info "[dry-run] ajout de la pref dans ${userjs/#$HOME/~}"
    else
      printf '\n// pc_conf_build (module firefox) : charge chrome/userChrome.css\n%s\n' "$line" >>"$userjs"
      ok "${userjs/#$HOME/~} : pref ajoutée"
    fi
  else
    link firefox/user.js "$userjs"
  fi
}
