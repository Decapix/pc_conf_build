# Mon terminal

Chaîne : **kitty** → lance **tmux** → **zsh** (oh-my-zsh, thème `lukerandall`, plugins `git`, `aliases`).

## Fonctions perso (`dotfiles/zsh/zshrc`)

| Commande | Effet |
|---|---|
| `pwdc` | sauve le dossier courant dans `~/.pwdc_output` **et** le copie dans le presse-papier |
| `cdc` | retourne dans le dossier sauvé par `pwdc` (marche entre terminaux) |
| `readlinkfc <fichier>` | copie le chemin absolu du fichier dans le presse-papier |
| `cpr [fichiers]` | copie stdin ou des fichiers dans le presse-papier (`cat x.txt \| cpr`) |
| `ran` | ranger, et le shell reste dans le dossier où on a quitté ranger |
| `dl …` / `dc …` | mon outil de favoris de dossiers avec notes (peut faire `cd`) |

Presse-papier : `wl-copy` sous Wayland, sinon `xclip`.

## Alias (`dotfiles/zsh/zsh_aliases` + `.zshrc`)

| Alias | Commande |
|---|---|
| `gad` `gcm` `gps` `gpl` `gcl` `gsw` | git add / commit -m / push / pull / clone / switch |
| `py` | python3 |
| `cl` | clear |
| `kl` | kubectl |
| `code` | VS Code en mode Wayland natif |
| `reboot-wifi` | coupe et rallume le Wi-Fi (nmcli) |
| `see-sway-key` | affiche l'aide-mémoire sway |
| `suspend` | mise en veille |
| `g++98` | g++ -std=c++98 |
| + tous les alias git d'oh-my-zsh (`gst`, `gco`, `glog`…) | `als` pour les lister (plugin aliases) |

## Clavier

| Touches | Action |
|---|---|
| `Ctrl+Suppr` | efface le mot à droite |
| `Ctrl+Retour arrière` | efface le mot à gauche |

## PATH (dans l'ordre d'ajout du `.zshrc`)

`~/.local/bin`, `~/go/bin`, `~/.bun/bin`, `~/.npm-global/bin`, `~/flutter/bin`, `~/.pub-cache/bin`,
Android SDK (`~/Android/Sdk/...`), `/opt/android-studio/bin`, `$JAVA_HOME/bin`…
Les dossiers qui n'existent pas sont simplement ignorés (sans effet sur une VM).

## Variables

`EDITOR=vim`, `VISUAL=vim`, `JAVA_HOME`, `ANDROID_HOME`, `TERM=xterm`, `QT_QPA_PLATFORMTHEME=qt5ct`,
`MAIL` (en-tête 42). Les **secrets** viennent de `~/.secrets.zsh` (hors repo).

Changement lors de la migration : la ligne `USER=solenopsis` a été retirée (elle forçait un mauvais
nom d'utilisateur sur toute autre machine ; `USER` est déjà défini par le système).

## tmux (`dotfiles/tmux/tmux.conf`)

- souris activée, mode vi dans le mode copie
- barre verte foncée
- **sélection à la souris = copiée** dans le presse-papier ; double-clic = mot ; triple-clic = ligne
- `y` en mode copie = copier

## kitty (`dotfiles/kitty/`)

- JetBrainsMono Nerd Font 11.5, opacité 0.95, pas de bip, pas de confirmation à la fermeture
- `shell tmux` : chaque fenêtre kitty ouvre tmux
- thèmes : `mocha.conf` (Catppuccin sombre), `light.conf` (Catppuccin Latte)
- kitty suit **tout seul** le thème du système grâce à `dark-theme.auto.conf` / `light-theme.auto.conf`
  (toutes les fenêtres ouvertes changent, pas besoin de les fermer) : `F8` ou `theme-switch`
- `theme.conf` (inclus par kitty.conf) n'est plus qu'un repli ; `switch-theme.sh` appelle `theme-switch`
