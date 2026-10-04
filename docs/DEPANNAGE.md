# Dépannage

## Général

- **Le journal** : `~/.cache/pc_conf_build/install-*.log` contient chaque commande et sa sortie.
- **Relancer un module** : `./install.sh full --only <module>` (le résumé donne la commande exacte).
- **Voir sans faire** : `./install.sh full -n`.
- « Lance-moi SANS sudo » : lancer `./install.sh` en utilisateur normal, il demande sudo lui-même.

## apt

| Symptôme | Cause / solution |
|---|---|
| `Conflicting values set for option Signed-By` | le même dépôt est déclaré dans 2 fichiers de `/etc/apt/sources.list.d/` (ex. un ancien `docker.list` + celui du programme). Supprimer le doublon. |
| `401 Unauthorized` sur deb.griffo.io | ce dépôt n'est plus public ; le programme ne l'utilise plus. Supprimer `/etc/apt/sources.list.d/deb.griffo.io.list` s'il reste. |
| `NO_PUBKEY` | supprimer `/etc/apt/keyrings/<nom>.gpg` et relancer le module (la clé est retéléchargée) |

## Sway / SwayFX

| Symptôme | Solution |
|---|---|
| La session SwayFX n'apparaît pas dans GDM | `ls /usr/share/wayland-sessions/` doit contenir `swayfx.desktop` ; relancer `--only swayfx` |
| Écran noir / retour à GDM en lançant SwayFX | tester dans un TTY (`Ctrl+Alt+F3`) : `swayfx-launch 2>&1 \| tee /tmp/swayfx.log`. Souvent : erreur de config → `sway -C -c ~/.config/sway/config` pour la valider. En secours, choisir la session **Sway** (Debian) dans GDM. |
| `libscenefx-0.4.so: cannot open shared object` | lancer via `swayfx-launch` (il règle `LD_LIBRARY_PATH`), ou `sudo ldconfig` |
| La compilation échoue (dépendance manquante) | le journal donne le `meson` qui échoue et le paquet `.pc` manquant : `apt-file search <nom>.pc` puis l'ajouter à `swayfx_build` dans `modules/51-swayfx.sh` |
| Nouvelle version de SwayFX | `SWAYFX_VER=… SCENEFX_VER=… WLROOTS_VER=… FORCE_SWAYFX=1 ./install.sh full --only swayfx` (versions compatibles : notes de version SwayFX) |
| Pas d'image au verrouillage | vérifier `~/.config/sway/images/lockscreen_background.png` |
| Pas d'icônes dans la barre (carrés) | police Nerd Font absente : `fc-list \| grep -i 'JetBrainsMono Nerd'`, sinon relancer `--only sway` |
| Wi-Fi absent du tray | `pgrep nm-applet` ; `nm-applet --indicator &` |
| Gestes touchpad sans effet | `groups` doit contenir `input` (se reconnecter) ; `libinput-gestures -d` pour déboguer |
| Mauvais écran éteint par `Super+F7` | `swaymsg -t get_outputs`, corriger `config.d/outputs` |
| Partage d'écran (Meet, Discord) impossible | vérifier que `xdg-desktop-portal-wlr` est installé et que la session a été redémarrée |

## Terminal

| Symptôme | Solution |
|---|---|
| `command not found: dl` | `ls ~/go/bin/dl` ; sinon `./install.sh full --only dl` |
| `pwdc` ne copie pas (VM en SSH) | normal : pas de presse-papier graphique ; `cdc` marche quand même |
| `docker: permission denied` | se reconnecter après l'ajout au groupe `docker` (ou `newgrp docker`) |
| oh-my-zsh a remplacé mon `.zshrc` | ne devrait pas arriver (`KEEP_ZSHRC=yes`) ; `./install.sh link` remet le lien |
| `gh` demande toujours de se connecter | `gh auth login` puis `gh auth setup-git` |

## Revenir en arrière

Tous les fichiers remplacés par un lien sont dans `~/.dotfiles-backup-DATE/` avec la même arborescence
que `~`. Pour revenir : supprimer le lien, puis `mv` le fichier sauvegardé à sa place.
