#!/usr/bin/env bash

BOOK_DIR="$HOME/Documents/PDF"
if [ ! -d "$BOOK_DIR" ]; then
    notify-send "Error" "La carpeta $BOOK_DIR no existe."
    exit 1
fi
FILE=$(find "$BOOK_DIR" -type f -name "*.pdf" | sed "s|$BOOK_DIR/||" | rofi -dmenu -i -p " Libros:" -theme ~/.config/rofi/pdf.rasi)
if [ -n "$FILE" ]; then
    zathura "$BOOK_DIR/$FILE" >/dev/null 2>&1 &
fi
