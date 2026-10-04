# Réinstaller mon PC de A à Z

Durée : ~20 min d'attention + ~15-30 min de compilation/téléchargements.

## 0. Avant de quitter l'ancien PC

- [ ] `cd ~/Tocuments/camputing/pc_conf_build && git status` → tout est commité et **poussé** ?
- [ ] Sauvegarder ce qui n'est **pas** dans le repo :
  - `~/.ssh/` (clés : fugax, julestoulet, hetzner, scw…) → sauvegarde **chiffrée**
  - `~/.secrets.zsh` (clés API) → gestionnaire de mots de passe
  - `~/.kube/config`, `~/.config/scw/config.yaml`, `~/.docker/config.json` si besoin
  - mes données (`~/Tocuments`, `~/Pictures`…)
- [ ] Noter la liste des apps graphiques à réinstaller à la main (elles ne sont pas dans le programme :
      Brave, VS Code, Zed, Beekeeper, MongoDB Compass, FreeCAD, KiCad, Inkscape, Bambu Studio…)

## 1. Installer Debian

1. Debian 13 (trixie), environnement de bureau **GNOME** (pour les invités).
2. Créer mon utilisateur (`solenopsis`) et l'ajouter à `sudo` (si l'installeur a demandé un mot de
   passe root, faire en root : `usermod -aG sudo solenopsis`, puis se reconnecter).
3. Se connecter dans GNOME, se connecter au Wi-Fi.

## 2. Lancer le programme

Ouvrir un terminal (GNOME Terminal), **en mon utilisateur, sans sudo** :

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/Decapix/pc_conf_build/main/bootstrap.sh)
```

- `bootstrap.sh` installe git, clone le repo dans `~/Tocuments/camputing/pc_conf_build`, lance `install.sh`.
- **Repo privé ?** Le clonage anonyme échoue : le script installe `gh` et lance `gh auth login`
  (choisir *GitHub.com → HTTPS → Login with a web browser*), puis clone.
- Menu 1 : choisir **full**.
- Menu 2 : la liste des modules, tout est coché. Décocher ce que je ne veux pas, `Entrée`.
- Mot de passe sudo demandé **une fois**.
- `git-gh` lance `gh auth login` si je ne suis pas encore connecté.
- La compilation SwayFX (`swayfx`) prend quelques minutes : normal.

## 3. À la fin

Le résumé liste les modules réussis / échoués. Si un module a échoué :

```sh
less ~/.cache/pc_conf_build/install-*.log        # voir pourquoi
./install.sh full --only <module>                # relancer juste lui
```

Puis :

1. **Se déconnecter** (pas juste fermer le terminal : les groupes `docker`, `input`, `video`
   et le shell zsh ne s'appliquent qu'à la reconnexion).
2. À l'écran de connexion GDM, la session **SwayFX** est présélectionnée (roue dentée en bas à
   droite après avoir cliqué sur mon nom). Les invités peuvent choisir *GNOME*.
3. Dans SwayFX : `Super+Entrée` → kitty + tmux + zsh.

## 4. Finitions manuelles

```sh
vim ~/.secrets.zsh             # remettre les clés API
cp -r /sauvegarde/.ssh ~/ && chmod 700 ~/.ssh && chmod 600 ~/.ssh/*   # clés SSH
sudo tailscale up              # connecter le PC au tailnet
gh auth status                 # vérifier GitHub
docker run hello-world         # vérifier docker (après reconnexion)
```

Écrans : `swaymsg -t get_outputs` donne les noms. Si l'écran interne n'est pas `eDP-1` ou
l'externe pas `DP-1`, corriger `dotfiles/sway/config.d/outputs`.

Matériel : les fichiers `dotfiles/sway/config.d/custom/` (DasKeyboard 4, MX Master 3, casque Sony,
gestes) sont inoffensifs si le matériel n'est pas branché.

## 5. Vérifier

| Test | Attendu |
|---|---|
| `Super+C` | centre de contrôle (wofi) |
| `Super+L` | écran verrouillé avec l'image de `sway/images/lockscreen_background.png` |
| Barre du haut | workspaces, ping, réseau, tray (icône Wi-Fi), mémoire, batterie, date, heure |
| `Super+S` | capture dans `~/Pictures` |
| `Super+F2/F3` | volume − / + |
| touches média | play/pause (playerctl) |
| 3 doigts gauche/droite | change de fenêtre ; 4 doigts : change de workspace |
| `dl`, `pwdc`, `cdc` dans un terminal | fonctionnent |
