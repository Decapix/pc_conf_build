# Mode VM : mes habitudes terminal partout

But : sur une VM/serveur Debian tout neuf, retrouver en 2 minutes mon shell comme sur mon PC.

## Lancer

```sh
# sans question, modules vm par défaut :
bash <(curl -fsSL https://raw.githubusercontent.com/Decapix/pc_conf_build/main/bootstrap.sh) vm -y

# ou avec la liste à cocher (pour ajouter node, python, k8s…) :
bash <(curl -fsSL https://raw.githubusercontent.com/Decapix/pc_conf_build/main/bootstrap.sh) vm
```

Lancer **en utilisateur normal** avec sudo. En root (VPS fraîchement créé) ça marche aussi, mais tout
est installé pour root ; mieux vaut d'abord :

```sh
adduser solenopsis && usermod -aG sudo solenopsis && su - solenopsis
```

Si le repo est privé, `bootstrap.sh` lance `gh auth login` : choisir **Paste an authentication token**
ou le code à 8 caractères à valider depuis le navigateur du PC (pas de navigateur sur la VM).

## Ce que j'obtiens (par défaut)

| Module | Résultat |
|---|---|
| `base` | git, curl, jq, ripgrep, btop, ranger, tree, httpie, vim… |
| `zsh` | zsh par défaut + oh-my-zsh + tout mon `.zshrc` : `pwdc`, `cdc`, `readlinkfc`, `cpr`, `ran`, alias git (`gad`, `gcm`, `gps`…), Ctrl+Suppr / Ctrl+Retour arrière |
| `tmux` | ma conf tmux |
| `git-gh` | `gh` + mon `.gitconfig` (nom/email, gh comme gestionnaire d'identifiants) |
| `cli-extra` | lazygit |
| `go` + `dl` | mon outil `dl` |
| `docker` | Docker CE + compose ; je suis dans le groupe `docker` |

Proposés décochés : `node`, `python`, `rust`, `java`, `k8s`, `cloud`, `tailscale`.
Exemple : `./install.sh vm -y --only node,tailscale` pour les ajouter plus tard.

## Particularités en VM

- **Presse-papier** : `pwdc`, `readlinkfc`, `cpr` et la copie tmux utilisent `wl-copy`/`xclip`. En SSH
  sans affichage graphique, la copie vers le presse-papier ne fait rien (pas d'erreur) : `pwdc`/`cdc`
  marchent quand même (ils passent par `~/.pwdc_output`).
- **Docker** : se reconnecter (ou `newgrp docker`) pour utiliser docker sans sudo.
- **Pas de kitty/sway** : rien de graphique n'est proposé en mode vm.
- **Tailscale** : après le module, `sudo tailscale up` pour rejoindre le tailnet.

## Testé

Le mode `vm -y` a été lancé de bout en bout dans un conteneur `debian:trixie` vierge
(utilisateur avec sudo) : tous les modules réussissent ; `dl`, `pwdc`, `cdc`, `readlinkfc`, `cpr`,
`gh`, `docker` et `lazygit` sont disponibles dans zsh.
