# shellcheck shell=bash
register git-gh on on "base" "git + GitHub CLI (gh) + .gitconfig, puis gh auth login"

mod_git_gh_install() {
  add_apt_repo github-cli https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    "deb [arch=$(dpkg --print-architecture) signed-by=KEYRING] https://cli.github.com/packages stable main"
  apt_install git gh
  mod_git_gh_link
  if [[ "$DRY_RUN" == 1 ]]; then return 0; fi
  if gh auth status >/dev/null 2>&1; then
    ok "gh déjà connecté"
  elif [[ -t 0 ]]; then
    info "Connexion GitHub (interactive, choisis HTTPS + navigateur ou token) :"
    gh auth login || warn "gh auth login à refaire plus tard"
  else
    warn "lance « gh auth login » plus tard"
  fi
}

mod_git_gh_link() { link git/gitconfig "$HOME/.gitconfig"; }
