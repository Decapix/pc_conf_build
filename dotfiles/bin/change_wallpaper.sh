#!/bin/bash

# Dossier où stocker le fond d'écran
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
mkdir -p "$WALLPAPER_DIR"

# Fichier flag pour vérifier si le fond a été changé aujourd'hui
FLAG_FILE="$HOME/.wallpaper_changed_today"

# URL du fond d'écran Bing
BING_URL="https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1"

# Vérifier si le fond d'écran a déjà été changé aujourd'hui
if [[ -f "$FLAG_FILE" && $(date +%Y-%m-%d) == $(cat "$FLAG_FILE") ]]; then
    echo "Le fond d'écran a déjà été changé aujourd'hui."
    exit 0
fi

# Télécharger le lien du fond d'écran Bing
IMAGE_URL=$(curl -s "$BING_URL" | jq -r '.images[0].url')
FULL_URL="https://www.bing.com$IMAGE_URL"

# Nom du fichier fond d'écran
TODAY_WALLPAPER="$WALLPAPER_DIR/actual.jpg"

# nom du fichier du fond d'ecran a remplacer
YESTERDAY_WALLPAPER="$WALLPAPER_DIR/$(date +%Y-%m-%d).jpg"

# changer le nom du fond actuel
mv "$TODAY_WALLPAPER" "$YESTERDAY_WALLPAPER"

# Télécharger le fond d'écran
curl -s -o "$TODAY_WALLPAPER" "$FULL_URL"

# Appliquer le fond d'écran (Hyprland ou Sway)
# swaybg -i "$TODAY_WALLPAPER" -m fill &

# Marquer que le fond d'écran a été changé
date +%Y-%m-%d > "$FLAG_FILE"

