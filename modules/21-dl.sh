# shellcheck shell=bash
register dl on on "go zsh" "dl : mes favoris de dossiers (github.com/Decapix/dl-organisation)"

mod_dl_install() {
  run env GOBIN="$HOME/go/bin" go install github.com/Decapix/dl-organisation/cmd/dl@latest
  ok "dl installé dans ~/go/bin (le .zshrc lance « dl init zsh »)"
}
