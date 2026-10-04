# shellcheck shell=bash
register k8s on off "base" "Kubernetes : kubectl, k9s, helm, minikube"

mod_k8s_install() {
  apt_install kubectl
  if have k9s; then ok "k9s déjà installé"; else
    install_deb_url "$(gh_asset_url derailed/k9s 'k9s_linux_amd64[.]deb$')"
  fi
  if have helm; then ok "helm déjà installé"; else
    run bash -c "curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
  fi
  if have minikube; then ok "minikube déjà installé"; else
    install_bin https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 minikube
  fi
}
