# Stop Doom Scroll — extension navigateur

Toutes les **1 minute** passée sur l'un de ces sites, l'extension met **toutes les vidéos
en pause** et affiche **« STOP DOOM SCROLL !!! »** (plein écran + notification système) :

- `https://www.youtube.com/shorts/...` (et `youtube.com/shorts/`, `m.youtube.com/shorts/`)
- `https://www.instagram.com/`
- `https://www.tiktok.com/`

Le bouton « OK, encore 1 minute » de l'overlay ferme le plein écran et repart pour 1 minute.
Le compteur repart aussi à zéro quand l'URL change (navigation sans rechargement sur ces SPA).
Durée réglable : `LIMIT_SECONDS` en haut de `content.js`.

## Fichiers

| Fichier | Rôle |
|---|---|
| `manifest.json` | MV3 **Firefox** (background en event page `scripts`, pas de service worker) |
| `manifest.chrome.json` | MV3 **Chrome/Edge/Brave** (service worker) — renommer en `manifest.json` pour Chrome |
| `content.js` | minuteur 60 s, `video.pause()` sur toutes les vidéos, overlay, message vers le background |
| `content.css` | style de l'overlay plein écran |
| `background.js` | notification système via `chrome.notifications` |
| `icon16/48/128.png` | icône de l'extension et des notifications |

## Installer dans Firefox (release)

1. `about:debugging` → onglet **« Ce Firefox »** → **« Charger un module temporaire »**
2. Choisir le `manifest.json` de ce dossier
   (déployé par le module `firefox` de pc_conf_build :
   `~/.mozilla/firefox/doomscroll-blocker/manifest.json`)

Le module temporaire disparaît au redémarrage de Firefox : à recharger à chaque fois.

## Install permanent sur Firefox release

Firefox release refuse les extensions non signées. Le chemin propre : **self-sign via AMO**
(compte gratuit, extension non listée, pas de review) :

```sh
cd dotfiles/firefox/extensions/doomscroll-blocker
zip -r ~/stop-doomscroll.xpi . -x 'README.md' -x 'manifest.chrome.json'
```

Uploader le `.xpi` sur https://addons.mozilla.org (distribution « Sur votre propre compte
seulement »), récupérer le `.xpi` signé, puis l'installer une fois dans Firefox
(glisser-déposer dans la fenêtre, ou `about:addons` → roue → « Installer un module depuis
un fichier »). Il persiste ensuite aux redémarrages.

Alternative : Firefox **Developer Edition** ou **Nightly** avec
`xpinstall.signatures.required=false` dans `about:config`, puis copier le `.xpi` dans
`<profil>/extensions/stop-doomscroll@decapix.github.io.xpi`.

## Chrome / Edge / Brave

Renommer `manifest.chrome.json` en `manifest.json`, puis `chrome://extensions` →
mode développeur → « Charger l'extension non empaquetée » → ce dossier.
