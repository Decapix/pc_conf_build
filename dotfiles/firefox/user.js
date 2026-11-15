// pc_conf_build (module firefox) — fait charger chrome/userChrome.css au démarrage
// de Firefox : barre d'onglets sur plusieurs lignes (voir dotfiles/firefox/userChrome.css).
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
