#!/usr/bin/env bash

KITTY_CONFIG_DIR="$HOME/.config/kitty"
THEME_LINK="$KITTY_CONFIG_DIR/theme.conf"
LIGHT_THEME="$KITTY_CONFIG_DIR/light.conf"
DARK_THEME="$KITTY_CONFIG_DIR/mocha.conf"

if [ ! -L "$THEME_LINK" ]; then
    echo "Creating theme symlink..."
    ln -sf "$DARK_THEME" "$THEME_LINK"
fi

CURRENT=$(readlink "$THEME_LINK")

if [[ "$CURRENT" == "$DARK_THEME" ]]; then
    ln -sf "$LIGHT_THEME" "$THEME_LINK"
    NEW="light"
else
    ln -sf "$DARK_THEME" "$THEME_LINK"
    NEW="dark"
fi

echo "Switched to $NEW theme."

# Recharger le thème sans redémarrer Kitty
kitty @ set-colors --all --configured "$THEME_LINK" >/dev/null 2>&1

