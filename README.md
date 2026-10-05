# pc_conf_build

Remet **mon setup complet** en place sur un PC neuf (Debian + GNOME pour les invités + **SwayFX** pour moi),
ou seulement **mes habitudes terminal** sur une VM.

Tout est dans ce repo : le programme d'installation **et** mes dotfiles. Sur mon PC, les fichiers de config
(`~/.config/sway`, `~/.zshrc`…) sont des **symlinks vers ce repo** : modifier ma config = modifier le repo,
puis `git commit` + `git push`.

---

## Sommaire

1. [En 30 secondes](#en-30-secondes)
2. [Les 3 modes](#les-3-modes)
3. [Les modules](#les-modules)
4. [Options de la ligne de commande](#options-de-la-ligne-de-commande)
5. [Organisation du repo](#organisation-du-repo)
6. [Ce qui est installé où](#ce-qui-est-installé-où)
7. [Secrets](#secrets)
8. [Au quotidien : modifier ma config](#au-quotidien--modifier-ma-config)
9. [Ajouter un module](#ajouter-un-module)
10. [Documentation détaillée](#documentation-détaillée)

---

## En 30 secondes

**PC neuf** (Debian 13 installé avec GNOME, connecté à Internet, en mon utilisateur, *pas* en root) :

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/Decapix/pc_conf_build/main/bootstrap.sh)
```

→ un menu demande le mode, puis une liste à cocher des modules. À la fin : **se déconnecter**, et à
l'écran de connexion la session **SwayFX** est déjà présélectionnée.

**VM** (Debian, terminal seulement, sans question) :

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/Decapix/pc_conf_build/main/bootstrap.sh) vm -y
```

**Le repo est déjà cloné** :

```sh
cd ~/Tocuments/camputing/pc_conf_build
./install.sh          # menu
```

Pas-à-pas complet avec les pièges à éviter : [docs/NOUVEAU-PC.md](docs/NOUVEAU-PC.md).

---

## Les 3 modes

| Mode | Pour quoi | Ce qui se passe |
|---|---|---|
| `full` | Mon PC principal | Tous les modules proposés, tous cochés par défaut : terminal, langages, k8s/cloud, Sway/SwayFX, barre, réseau, bluetooth, audio, gestes |
| `vm` | Une VM / un serveur | Seulement les modules terminal : outils CLI, zsh + alias + fonctions (`dl`, `pwdc`, `cdc`, `readlinkfc`, `cpr`…), tmux, git + gh, lazygit, Go, `dl`, Docker. Les langages et k8s sont proposés **décochés** ; tout le graphique est **caché** |
| `link` | Re-brancher les dotfiles | Aucun paquet, aucun sudo : ne fait que les symlinks (avec sauvegarde de ce qui existait) |

Dans chaque mode, une liste à cocher (whiptail) permet de choisir. `Espace` coche/décoche, `Entrée` valide.
Sans terminal interactif (ou sans whiptail), le programme pose les questions une par une (o/n).

---

## Les modules

Ordre d'exécution = ordre du tableau. Les dépendances sont ajoutées automatiquement
(ex. cocher `dl` ajoute `go` et `zsh`).

| Module | full | vm | Dépend de | Contenu |
|---|:-:|:-:|---|---|
| `base` | ✔ | ✔ | — | git, curl, wget, jq, ripgrep, btop, htop, ranger, tree, httpie, rsync, vim, build-essential, whiptail… |
| `zsh` | ✔ | ✔ | base | zsh, oh-my-zsh (thème `lukerandall`), **liens** `~/.zshrc` et `~/.zsh_aliases`, zsh comme shell par défaut, crée `~/.secrets.zsh` |
| `tmux` | ✔ | ✔ | base | tmux + **lien** `~/.tmux.conf` (souris, mode vi, copie → presse-papier Wayland) |
| `git-gh` | ✔ | ✔ | base | dépôt officiel GitHub CLI, `gh`, **lien** `~/.gitconfig` (gh comme gestionnaire d'identifiants), puis `gh auth login` |
| `cli-extra` | ✔ | ✔ | base | lazygit (dernière release GitHub) |
| `go` | ✔ | ✔ | base | golang (Debian), crée `~/go/bin` |
| `dl` | ✔ | ✔ | go, zsh | `go install github.com/Decapix/dl-organisation/cmd/dl@latest` |
| `docker` | ✔ | ✔ | base | Docker CE (dépôt officiel) + buildx + compose, ajout au groupe `docker` |
| `node` | ✔ | ☐ | base | nodejs, npm, pnpm (npm -g), bun |
| `python` | ✔ | ☐ | base | python3, pip, venv, pipx, uv |
| `rust` | ✔ | ☐ | base | cargo, rustc (Debian) |
| `java` | ✔ | ☐ | base | openjdk-21-jdk |
| `k8s` | ✔ | ☐ | base | kubectl (Debian), k9s (.deb GitHub), helm (script officiel), minikube |
| `cloud` | ✔ | ☐ | base | OpenTofu (`tofu`, dépôt officiel), Scaleway CLI (`scw`) |
| `tailscale` | ✔ | ☐ | base | Tailscale (dépôt officiel) — ensuite `sudo tailscale up` |
| `sway` | ✔ | — | base | sway, swaybg, **swaylock, swayidle, mako, playerctl**, waybar, wofi, grim/slurp/grimshot, portails, kitty, police JetBrainsMono Nerd Font, **liens** sway/waybar/wofi/kitty + `change_wallpaper.sh` |
| `swayfx` | ✔ | — | sway | compile wlroots 0.19.0 → scenefx 0.4.1 → SwayFX 0.5.2 dans `/usr/local`, crée `swayfx-launch` et la session « SwayFX » |
| `default-session` | ✔ | — | sway | SwayFX (ou Sway si pas compilé) = session présélectionnée dans GDM |
| `network-bt` | ✔ | — | go | NetworkManager, nm-applet, bluez, blueman, bluetuith |
| `audio-display` | ✔ | — | base | pipewire, wireplumber, pavucontrol, brightnessctl, wdisplays, captures |
| `gestures` | ✔ | — | base | libinput-gestures (depuis GitHub), groupe `input`, **lien** de la config des gestes |
| `claude-notify` | ✔ | — | sway | notification mako quand Claude Code a fini de répondre (ou attend une autorisation) : hooks `Stop` / `Notification` dans `~/.claude/settings.json` |
| `lid` | ✔ | — | — | capot fermé **sur secteur** = pas de veille (les tâches continuent) ; sur batterie = veille |

✔ = coché par défaut · ☐ = proposé mais décoché · — = pas proposé dans ce mode.

`./install.sh --list` affiche ce tableau à jour (il est généré depuis les modules).

Détail de chaque module, ce qu'il modifie et comment le défaire : [docs/MODULES.md](docs/MODULES.md).

---

## Options de la ligne de commande

```
./install.sh [full|vm|link] [options]

-y, --yes          pas de liste à cocher : modules cochés par défaut du mode
--only a,b,c       exactement ces modules (+ leurs dépendances)
--skip a,b         retire des modules de la sélection
-n, --dry-run      affiche chaque commande sans l'exécuter
-l, --list         liste les modules
-h, --help         aide
```

Exemples :

```sh
./install.sh full --skip swayfx,java     # tout sauf la compilation SwayFX et Java
./install.sh vm -y --only dl             # juste dl (go et zsh ajoutés automatiquement)
./install.sh full -n                     # voir ce qui serait fait, sans rien faire
FORCE_SWAYFX=1 ./install.sh --only swayfx full   # recompiler SwayFX
SWAYFX_VER=0.6.0 SCENEFX_VER=0.5.0 WLROOTS_VER=0.20.0 ./install.sh full --only swayfx  # autre version
```

**Le programme est idempotent** : on peut le relancer autant qu'on veut. Ce qui est déjà installé
ou déjà lié est sauté (`✓ … déjà …`). Un module qui échoue n'arrête pas les autres ; le résumé final
donne la commande exacte pour relancer seulement les modules échoués.

Chaque exécution écrit un journal complet dans `~/.cache/pc_conf_build/install-DATE.log`.

---

## Organisation du repo

```
pc_conf_build/
├── install.sh            # le programme (menus, modes, dépendances, résumé)
├── bootstrap.sh          # 1re commande sur une machine neuve : clone puis install.sh
├── lib/common.sh         # fonctions partagées : run, as_root, apt_install, add_apt_repo, link…
├── modules/              # un fichier par module, exécutés dans l'ordre des numéros
│   ├── 00-base.sh  10-zsh.sh  11-tmux.sh  12-git-gh.sh  13-cli-extra.sh
│   ├── 20-go.sh  21-dl.sh  22-docker.sh
│   ├── 30-node.sh  31-python.sh  32-rust.sh  33-java.sh
│   ├── 40-k8s.sh  41-cloud.sh  42-tailscale.sh
│   └── 50-sway.sh  51-swayfx.sh  52-default-session.sh  53-network-bt.sh  54-audio-display.sh  55-gestures.sh  56-lid.sh  57-claude-notify.sh
├── dotfiles/             # MES configs : la source de vérité (les fichiers de ~ pointent ici)
│   ├── sway/             # → ~/.config/sway   (config, config.d/, scripts/, images/, swayfx.conf, simple.md)
│   ├── waybar/           # → ~/.config/waybar
│   ├── wofi/             # → ~/.config/wofi
│   ├── kitty/            # → ~/.config/kitty  (theme.conf = état local, ignoré par git)
│   ├── zsh/              # zshrc → ~/.zshrc, zsh_aliases → ~/.zsh_aliases
│   ├── tmux/             # tmux.conf → ~/.tmux.conf
│   ├── git/              # gitconfig → ~/.gitconfig
│   ├── gestures/         # libinput-gestures.conf → ~/.config/libinput-gestures.conf
│   └── bin/              # change_wallpaper.sh → ~/.local/bin/
└── docs/
    ├── NOUVEAU-PC.md     # pas-à-pas d'une réinstallation complète
    ├── VM.md             # mode vm
    ├── MODULES.md        # chaque module en détail + comment le défaire
    ├── SWAY.md           # mon environnement sway : raccourcis, barre, centre de contrôle, scripts
    ├── TERMINAL.md       # zsh, fonctions, alias, tmux, kitty
    └── DEPANNAGE.md      # problèmes connus et solutions
```

---

## Ce qui est installé où

| Quoi | Où |
|---|---|
| Paquets apt | système (`/usr`) |
| Dépôts ajoutés | `/etc/apt/sources.list.d/<nom>.list` + clé `/etc/apt/keyrings/<nom>.gpg` (github-cli, docker, opentofu, tailscale) |
| wlroots 0.19 + scenefx (SwayFX) | `/usr/local/lib/x86_64-linux-gnu/`, en-têtes dans `/usr/local/include` |
| binaire SwayFX | `/usr/local/lib/swayfx` (pas dans `/usr/local/bin`, pour ne pas masquer le `sway` de Debian) |
| lanceur SwayFX | `/usr/local/bin/swayfx-launch` + `/usr/share/wayland-sessions/swayfx.desktop` |
| session par défaut | `/var/lib/AccountsService/users/$USER` (`Session=swayfx`) |
| comportement du capot | `/etc/systemd/logind.conf.d/10-lid.conf` |
| helm, minikube, scw, lazygit | `/usr/local/bin/` |
| dl, bluetuith | `~/go/bin/` |
| bun | `~/.bun/` |
| uv | `~/.local/bin/` |
| oh-my-zsh | `~/.oh-my-zsh/` |
| police Nerd Font | `~/.local/share/fonts/JetBrainsMonoNerdFont/` |
| sauvegardes des anciens fichiers | `~/.dotfiles-backup-DATE/` (même arborescence que `~`) |
| journaux | `~/.cache/pc_conf_build/` |
| sources de compilation SwayFX | `~/.cache/pc_conf_build/swayfx-build/` (supprimable) |

---

## Secrets

**Aucun secret n'est dans ce repo.** Clés API, tokens… vont dans `~/.secrets.zsh` (droits 600),
chargé automatiquement à la fin de `.zshrc` :

```sh
# ~/.secrets.zsh
export OPENAI_API_KEY=sk-...
```

Le module `zsh` crée ce fichier vide s'il n'existe pas. Sur une nouvelle machine, il faut le
remplir à la main (gestionnaire de mots de passe). Les clés SSH (`~/.ssh`) non plus ne sont pas
dans le repo : les recopier depuis une sauvegarde chiffrée, ou en générer de nouvelles.

---

## Au quotidien : modifier ma config

Comme `~/.config/sway` est un lien vers `dotfiles/sway`, je modifie ma config comme avant
(`vim ~/.config/sway/config`, `Super+Shift+C` pour recharger)… et c'est le repo qui change :

```sh
cd ~/Tocuments/camputing/pc_conf_build
git status                 # voir ce qui a changé
git add -A && git commit -m "sway: nouveau raccourci"
git push
```

Sur une autre machine déjà installée : `git pull`, c'est tout (les liens pointent déjà sur le repo).

⚠️ Certains installeurs (conda, nvm, sdkman…) **ajoutent des lignes à `~/.zshrc`** : comme c'est
un lien, ils modifient le fichier du repo. Regarder `git diff` avant de commiter.

---

## Ajouter un module

Créer `modules/NN-nom.sh` (le numéro fixe l'ordre) :

```bash
# shellcheck shell=bash
# register <id> <full: on|off> <vm: on|off|->  "<dépendances>"  "<description>"
register monoutil on off "base" "Mon outil (description affichée dans le menu)"

mod_monoutil_install() {        # tirets de l'id → _ dans le nom de fonction
  apt_install monoutil
  mod_monoutil_link
}

mod_monoutil_link() {           # optionnel : utilisé par ./install.sh link
  link monoutil/config "$HOME/.config/monoutil/config"
}
```

Les fonctions utiles (dans `lib/common.sh`) :

| Fonction | Rôle |
|---|---|
| `apt_install paquets…` | `apt-get update` (une fois) + install non interactive |
| `add_apt_repo nom url-clé "deb [signed-by=KEYRING] …"` | ajoute un dépôt et sa clé (armored ou non) |
| `link chemin/dans/dotfiles ~/destination` | symlink idempotent, sauvegarde ce qui existait |
| `run cmd…` / `as_root cmd…` | exécute (ou affiche en dry-run), journalise ; `as_root` ajoute sudo |
| `root_write /chemin [mode]` | écrit stdin dans un fichier root |
| `gh_asset_url owner/repo 'regex'` | URL de l'asset de la dernière release GitHub |
| `install_bin url nom`, `install_tar_bin url nom`, `install_deb_url url` | binaire / archive / .deb téléchargé |
| `add_user_to_group groupe` | ajoute `$USER` à un groupe |
| `have cmd` | la commande existe ? |
| `ok` / `info` / `warn` / `err` / `title` | affichage |

Chaque module tourne dans un sous-shell avec `set -e` : la première commande qui échoue arrête le
module (et seulement lui).

---

## Documentation détaillée

- [docs/NOUVEAU-PC.md](docs/NOUVEAU-PC.md) — réinstaller mon PC de A à Z
- [docs/VM.md](docs/VM.md) — préparer une VM avec mes habitudes
- [docs/MODULES.md](docs/MODULES.md) — chaque module en détail
- [docs/SWAY.md](docs/SWAY.md) — mon environnement Sway : raccourcis, barre, centre de contrôle
- [docs/TERMINAL.md](docs/TERMINAL.md) — zsh, fonctions perso, alias, tmux, kitty
- [docs/DEPANNAGE.md](docs/DEPANNAGE.md) — quand quelque chose ne marche pas
