# Mon environnement Sway / SwayFX

Source : `dotfiles/sway/` (= `~/.config/sway`). Aide-mémoire rapide des groupes de fenêtres :
`see-sway-key` dans un terminal (affiche `~/.config/sway/simple.md`).

## Structure

```
sway/
├── config              # base : mod=Super, terminal kitty, lanceur wofi, couleurs, police, includes
├── swayfx.conf         # inclut config + effets SwayFX (coins, ombres, dim) — utilisé par swayfx-launch
├── config.d/
│   ├── workspaces      # focus/déplacement, workspaces 1-10, resize, layouts
│   ├── groups          # nommer / aplatir les groupes de fenêtres
│   ├── scratchpad
│   ├── multimedia      # volume, luminosité, captures, F8 thème kitty
│   ├── outputs         # eDP-1 / DP-1
│   ├── inputs          # clavier us,fr ; touchpad
│   ├── screenlock_powersave   # swayidle + swaylock
│   └── statusbar       # lance waybar + nm-applet
├── custom/             # matériel : daskeyboard4, mxmaster3, sony_wh700, touchpad_gestures
├── scripts/            # control-center, battery_alert, rename_group, flatten_workspace, swap_workspaces, sway_bar (ancien)
├── images/             # wallpaper.jpg, lockscreen_background.png…
└── simple.md           # aide-mémoire (see-sway-key)
```

Ordre d'inclusion : `config.d/*` (alphabétique), puis `custom/*`, puis `/etc/sway/config.d/*`.

## Démarrage automatique

| Quoi | Où |
|---|---|
| `dbus-update-activation-environment` (portails, partage d'écran) | `config` |
| mako (notifications) | `config` |
| alerte batterie (swaynag sous 10 %) | `config` → `scripts/battery_alert.sh` |
| waybar (relancé à chaque reload) | `config.d/statusbar` |
| nm-applet `--indicator` (Wi-Fi dans le tray) | `config.d/statusbar` |
| swayidle : verrouille à 10 min, éteint l'écran à 15 min, verrouille avant la veille | `config.d/screenlock_powersave` |
| libinput-gestures | `custom/touchpad_gestures` |
| capot fermé → écran interne éteint + verrouillage ; ouvert → rallumé | `config.d/screenlock_powersave` |

## Raccourcis

`Super` = touche Windows. `Alt` = Mod1.

### Essentiels
| Touches | Action |
|---|---|
| `Super+Entrée` | terminal (kitty → tmux → zsh) |
| `Super+x` | lanceur (wofi) |
| `Super+q` | fermer la fenêtre |
| `Super+c` | **centre de contrôle** |
| `Super+l` | verrouiller |
| `Super+f` | plein écran |
| `Super+Shift+c` | recharger la config |
| `Super+Shift+e` | quitter sway (confirmation) |
| `Super+Alt+↑` | fond d'écran Bing du jour |

### Fenêtres et workspaces
| Touches | Action |
|---|---|
| `Super+flèches` | focus |
| `Super+Shift+flèches` | déplacer la fenêtre |
| `Super+1…0` (ou pavé numérique) | workspace 1…10 |
| `Super+Shift+1…0` | envoyer la fenêtre au workspace |
| `Super+Tab` / `Super+Shift+Tab` | workspace suivant / précédent |
| `Super+r` | mode redimensionnement (flèches, `Entrée`/`Échap` pour sortir) |
| `Super+Shift+Espace` | flottant / tuile |
| `Super+Espace` | focus tuiles ↔ flottantes |
| `Super` + glisser | déplacer (clic gauche) / redimensionner (clic droit) |
| `Super+Shift+-` / `Super+-` | envoyer au / afficher le scratchpad |

### Layouts et groupes
| Touches | Action |
|---|---|
| `Super+b` / `Super+v` | split horizontal / vertical |
| `Super+w` | onglets (tabbed) |
| `Super+t` | pile (stacking) |
| `Super+e` | repasser en split |
| `Super+a` | sélectionner le parent (le groupe) |
| `Super+Shift+m` | nommer le groupe (affiché `[nom]`) |
| `Super+Alt+m` | enlever le nom |
| `Super+Shift+w` | **tout aplatir** en onglets (« je suis perdu ») |

### Son, écran, captures
| Touches | Action |
|---|---|
| `Super+F1` / `F2` / `F3` | muet / volume −5 % / +5 % |
| touches luminosité | ±5 % (même écran verrouillé) |
| `Super+s` | capture écran entier → `~/Pictures/DATE-screenshot.png` |
| `Super+Shift+s` | capture d'une zone |
| `Super+F7` / `Super+F8` | éteindre / rallumer l'écran du portable (eDP-1) |
| `F8` | thème kitty clair ↔ sombre |
| `Alt+Shift` | changer de disposition clavier us ↔ fr |

### Matériel
| Périphérique | Touches |
|---|---|
| DasKeyboard 4 | touches média (suivant, play/pause, précédent), muet, volume ±2 % |
| MX Master 3 | boutons latéraux = workspace précédent / suivant sur l'écran |
| Casque Sony WH700 | play / pause |
| Touchpad | 3 doigts ←/→ : fenêtre ; 4 doigts ←/→ : workspace (`~/.config/libinput-gestures.conf`) |

## Verrouillage, veille et tâches en cours

| Action | Les programmes continuent ? |
|---|---|
| `Super+L` | ✅ oui (swaylock ne fait que recouvrir l'écran) |
| 10 min d'inactivité (verrouillage) / 15 min (écran éteint) | ✅ oui |
| Capot fermé **sur secteur** (module `lid`) | ✅ oui : écran éteint + verrouillé |
| Capot fermé **sur batterie** | ❌ veille : tout est figé |
| Énergie → Mettre en veille, alias `suspend` | ❌ veille |

## Centre de contrôle (`Super+c`)

Menu wofi (`scripts/control-center.sh`) :

| Entrée | Contenu |
|---|---|
| Réseau | nm-connection-editor, panneau Wi-Fi GNOME, `ip a`, ping |
| Bluetooth | bluetuith, état du service |
| Énergie | veille, éteindre, redémarrer, verrouiller |
| Session | quitter sway, recharger, btop |
| Écran | wdisplays, `swaymsg -t get_outputs` |
| Son | volume, muet, choix de la sortie (déplace aussi les flux en cours), pavucontrol |
| Langue | clavier fr / us / es |
| Custom | mes scripts, listés dans `scripts/CUSTOM` (format : `Nom<espaces>chemin`) |

## Barre (waybar)

`dotfiles/waybar/config.jsonc` + `style.css` (fond noir 78 %, accent `#0D1A63`, JetBrainsMono 10px).

- Gauche : workspaces · Centre : titre de la fenêtre
- Droite : verr. maj · ping 1.1.1.1 (10 s) · réseau (SSID ou IP) · tray (nm-applet, blueman…) ·
  mémoire · batterie · date · heure (calendrier au survol)
- L'interface réseau et la batterie sont **détectées automatiquement** (avant : `wlo1` et `BAT0`
  en dur, faux sur un autre PC).

## Apparence

- Bordures 2px, fenêtre active `#0D1A63`, conteneur actif (onglets) `#6ebadd`, urgente `#c03c3c`
- Titres centrés, police JetBrainsMono Nerd Font 10
- SwayFX : coins arrondis 12px, ombres, fenêtres inactives assombries de 25 %
- wofi : fond `#282c34`, bordure `#61afef`, coins 8px

## Corrections faites lors de la migration vers ce repo

- `$lockscreenbg` n'était défini nulle part → swaylock n'avait pas d'image. Il vaut maintenant le
  **fond d'écran Bing du jour** (`~/Pictures/Wallpapers/actual.jpg`, couleur `#0d1640` si absent),
  dans `config.d/screenlock_powersave`.
- swaylock, swayidle, mako, playerctl n'étaient pas installés → verrouillage, veille auto,
  notifications et touches média ne marchaient pas. Le module `sway` les installe.
- `F8` lançait `theme-switcher`, qui n'existe pas (et capturait la touche F8 partout) → lance
  maintenant `~/.config/kitty/switch-theme.sh`.
- Chemins `/home/solenopsis/...` remplacés par `~` / `$HOME`.
- `config.d/custom/` déplacé en `custom/` : `include config.d/*` prenait aussi le dossier et sway
  affichait l'erreur « custom is a directory not a config file » à chaque rechargement.
