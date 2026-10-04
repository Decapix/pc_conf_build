# shellcheck shell=bash
register rust on off "base" "Rust (cargo + rustc de Debian)"

mod_rust_install() { apt_install cargo rustc; }
