# Les modules en détail

Pour chaque module : ce qu'il fait, ce qu'il modifie, comment le défaire.
`./install.sh --list` donne l'état par défaut et les dépendances.

---

## base
- **Fait** : `apt-get install` de ca-certificates curl wget gnupg git whiptail unzip zip xz-utils
  build-essential make jq ripgrep tree rsync htop btop ranger httpie vim less man-db bash-completion
  lsof traceroute bind9-dnsutils netcat-traditional iputils-ping pciutils usbutils.
- **Défaire** : `sudo apt remove <paquet>`.

## zsh
- **Fait** : installe zsh ; installe oh-my-zsh dans `~/.oh-my-zsh` (sans écraser `.zshrc`) ;
  lie `~/.zshrc` → `dotfiles/zsh/zshrc` et `~/.zsh_aliases` → `dotfiles/zsh/zsh_aliases` ;
  `chsh -s zsh` ; crée `~/.secrets.zsh` (600) s'il n'existe pas.
- **Lien seulement** (`link`) : les deux liens + `~/.secrets.zsh`.
- **Défaire** : `chsh -s /bin/bash` ; remettre les fichiers depuis `~/.dotfiles-backup-*`.

## tmux
- **Fait** : installe tmux + wl-clipboard ; lie `~/.tmux.conf`.
- Kitty lance tmux automatiquement (`shell tmux` dans kitty.conf).

## git-gh
- **Fait** : dépôt `cli.github.com` (clé `/etc/apt/keyrings/github-cli.gpg`), installe git + gh ;
  lie `~/.gitconfig` ; si gh n'est pas connecté et que le terminal est interactif → `gh auth login`.
- `.gitconfig` contient mon nom/email (`adonis pesic` / `decapixd@gmail.com`) et `gh auth
  git-credential` comme gestionnaire d'identifiants pour github.com.

## cli-extra
- **Fait** : lazygit, dernière release GitHub → `/usr/local/bin/lazygit`.
- Avant, lazygit et k9s venaient du dépôt `deb.griffo.io` ; ce dépôt répond maintenant
  *401 Unauthorized* au téléchargement des paquets : on ne l'utilise plus.

## go
- **Fait** : `golang` de Debian, crée `~/go/bin` (dans le PATH via `.zshrc`).
- Les outils qui demandent un Go plus récent (ex. `dl` demande 1.26) téléchargent automatiquement
  la bonne toolchain (`GOTOOLCHAIN=auto`, comportement par défaut de Go).

## dl
- **Fait** : `go install github.com/Decapix/dl-organisation/cmd/dl@latest` → `~/go/bin/dl`.
- Le `.zshrc` fait `eval "$(dl init zsh)"` (seulement si `dl` existe) : c'est ce qui permet à `dl`
  de faire `cd` dans le shell. Alias : `dc` = `dl`.
- **Mettre à jour dl** : relancer `./install.sh full --only dl`.

## docker
- **Fait** : dépôt `download.docker.com` ; docker-ce, cli, containerd, buildx, compose ;
  `systemctl enable --now docker` ; ajout au groupe `docker` (effectif après reconnexion).

## node
- **Fait** : nodejs + npm (Debian) ; `sudo npm i -g pnpm` ; bun via l'installeur officiel
  (avec `SHELL=/bin/sh` pour qu'il ne modifie pas `.zshrc`, qui contient déjà les lignes de bun).

## python
- **Fait** : python3, pip, venv, pipx ; uv via l'installeur officiel → `~/.local/bin/uv`
  (sans toucher au PATH, déjà géré par `.zshrc`).

## rust
- **Fait** : cargo + rustc de Debian. (Pour rustup à la place : `curl https://sh.rustup.rs | sh`.)

## java
- **Fait** : openjdk-21-jdk. `JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64` est dans `.zshrc`.

## k8s
- **Fait** : kubectl (Debian) ; k9s (.deb de la dernière release GitHub) ; helm (script officiel
  `get-helm-3`) ; minikube (binaire officiel) → `/usr/local/bin`. Alias `kl` = `kubectl`.

## cloud
- **Fait** : OpenTofu (dépôt officiel, deux clés : `opentofu.gpg` + `opentofu-repo.gpg`) ;
  Scaleway CLI `scw` (dernière release GitHub) → `/usr/local/bin/scw`.
- Config scw à refaire : `scw init`.

## tailscale
- **Fait** : dépôt `pkgs.tailscale.com`, installe et démarre `tailscaled`.
- **Ensuite** : `sudo tailscale up`.

## sway
- **Fait** : sway (Debian, fournit aussi swaynag/swaymsg), swaybg, **swaylock, swayidle**, xwayland,
  waybar, wofi, **mako** (notifications), libnotify-bin, **playerctl** (touches média), wl-clipboard,
  grim, slurp, grimshot, jq, upower, portails xdg (wlr + gtk : partage d'écran), kitty, fontconfig.
  Police **JetBrainsMono Nerd Font** (dernière release nerd-fonts) dans `~/.local/share/fonts`.
- **Liens** : `~/.config/sway`, `~/.config/waybar`, `~/.config/wofi`, `~/.config/kitty` (dossiers
  entiers), `~/.local/bin/change_wallpaper.sh`.
- Crée `dotfiles/kitty/theme.conf` → `mocha.conf` (thème sombre ; ignoré par git car F8 le change),
  et `~/Pictures/Wallpapers/actual.jpg` (copie de `sway/images/wallpaper.jpg`) s'il n'existe pas.

## swayfx
- **Fait** : installe les dépendances de compilation, télécharge et compile dans
  `~/.cache/pc_conf_build/swayfx-build/` :
  1. **wlroots 0.19.0** → `meson` + `ninja install` dans `/usr/local` (Debian n'a que 0.18)
  2. **scenefx 0.4.1** (le moteur d'effets) → `/usr/local`
  3. **SwayFX 0.5.2** → seul le binaire est copié en `/usr/local/lib/swayfx`
- Crée `/usr/local/bin/swayfx-launch` (ajoute `/usr/local/lib/x86_64-linux-gnu` à
  `LD_LIBRARY_PATH`, lance SwayFX avec `~/.config/sway/swayfx.conf`) et la session
  `/usr/share/wayland-sessions/swayfx.desktop`.
- `swayfx.conf` inclut la config sway normale puis ajoute les effets (coins 12px, ombres,
  assombrissement des fenêtres inactives). Choisir la session **Sway** dans GDM = mêmes raccourcis,
  sans effets.
- Sauté si `/usr/local/lib/swayfx` est déjà en 0.5.2. `FORCE_SWAYFX=1` pour recompiler ;
  `SWAYFX_VER`, `SCENEFX_VER`, `WLROOTS_VER` pour changer de version (elles doivent aller ensemble :
  voir les notes de version de SwayFX).
- **Défaire** : `sudo rm /usr/local/lib/swayfx /usr/local/bin/swayfx-launch /usr/share/wayland-sessions/swayfx.desktop`
  puis, pour wlroots/scenefx : `sudo ninja -C ~/.cache/pc_conf_build/swayfx-build/<projet>/build uninstall`.

## default-session
- **Fait** : écrit `Session=swayfx` (ou `sway` si SwayFX n'est pas installé) dans
  `/var/lib/AccountsService/users/$USER`. GDM présélectionne cette session.
- **Défaire** : choisir une autre session dans GDM (elle sera mémorisée).

## network-bt
- **Fait** : network-manager, nm-applet (icône Wi-Fi dans le tray de waybar), bluez, bluez-tools,
  blueman ; active le service bluetooth ; `go install` de **bluetuith** (gestion bluetooth en
  terminal, utilisé par le centre de contrôle) → `~/go/bin/bluetuith`.

## audio-display
- **Fait** : pipewire, pipewire-pulse, wireplumber, pavucontrol, pulseaudio-utils (`pactl`, utilisé
  par les raccourcis volume), brightnessctl (+ groupe `video`), wdisplays, grim/slurp/grimshot.

## gestures
- **Fait** : libinput-tools, wmctrl, xdotool ; clone `bulletmark/libinput-gestures` et `make install` ;
  groupe `input` (obligatoire pour lire le touchpad) ; lie `~/.config/libinput-gestures.conf` ;
  `libinput-gestures-setup autostart` (pour GNOME ; dans sway c'est `custom/touchpad_gestures`
  qui le lance).
