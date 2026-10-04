#!/usr/bin/env bash

WALLPAPERS_FOLDER="$HOME/Pictures/Wallpapers"
if [ ! -d "$WALLPAPERS_FOLDER" ]; then
    rofi -e "Error: Directory not found $WALLPAPERS_FOLDER"
    exit 1
fi
ROFI_INPUT=""
while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    ROFI_INPUT+="${filename}\x00icon\x1f${file}\n"
done < <(find "$WALLPAPERS_FOLDER" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) -print0)
if [ -z "$ROFI_INPUT" ]; then
    rofi -e "There are no images in: $WALLPAPERS_FOLDER"
    exit 1
fi
SELECCION=$(echo -ne "$ROFI_INPUT" | rofi -dmenu \
    -theme ~/.config/rofi/wallpaper.rasi \
    -show-icons \
    -p " Wallpaper:")
if [ -n "$SELECCION" ]; then
    WALLPAPER_PATH="$WALLPAPERS_FOLDER/$SELECCION"
    feh --bg-fill "$WALLPAPER_PATH"
    if command -v notify-send &>/dev/null; then
        notify-send -u low \
            -i "$WALLPAPER_PATH" \
            -a "Wallpaper" \
            "Wallpaper Changed" \
            "$SELECCION"
    fi
fi
