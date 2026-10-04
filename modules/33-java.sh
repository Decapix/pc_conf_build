# shellcheck shell=bash
register java on off "base" "Java 21 (openjdk-21-jdk) — JAVA_HOME est déjà dans le .zshrc"

mod_java_install() { apt_install openjdk-21-jdk; }
