#!/bin/sh
set -eu

say() { printf '%s\n' "[banditbsd] $*"; }
die() { printf '%s\n' "[banditbsd] error: $*" >&2; exit 1; }

REPO_ROOT=${BANDITBSD_DOTFILES_ROOT:-}
TARGET_USER=${1:-}

[ "$(id -u)" -eq 0 ] || die "run as root"
[ -n "$TARGET_USER" ] || die "usage: $0 USER"
TARGET_HOME=$(pw usershow -n "$TARGET_USER" -7 | awk -F: '{print $7}')
[ -n "$TARGET_HOME" ] && [ -d "$TARGET_HOME" ] || die "user not found: $TARGET_USER"
[ -n "$REPO_ROOT" ] && [ -d "$REPO_ROOT" ] || die "set BANDITBSD_DOTFILES_ROOT to the dotfiles checkout"

BACKUP_DIR="$TARGET_HOME/.local/state/banditbsd-backup/$(date +%Y%m%d-%H%M%S)"
backup() {
    path=$1
    [ -e "$path" ] || [ -L "$path" ] || return 0
    target="$BACKUP_DIR/${path#$TARGET_HOME/}"
    mkdir -p "$(dirname "$target")"
    mv "$path" "$target"
}
copy_file() {
    source=$1; target=$2
    backup "$target"
    mkdir -p "$(dirname "$target")"
    cp -p "$source" "$target"
}
copy_dir() {
    source=$1; target=$2
    backup "$target"
    mkdir -p "$(dirname "$target")"
    cp -R "$source" "$target"
}

mkdir -p "$BACKUP_DIR"
for file in .Xresources .p10k.zsh .tmux.conf .xinitrc .xprofile .zshrc; do
    copy_file "$REPO_ROOT/$file" "$TARGET_HOME/$file"
done
for dir in dunst fastfetch nvim picom redshift rofi yazi zathura; do
    copy_dir "$REPO_ROOT/configs/$dir" "$TARGET_HOME/.config/$dir"
done
copy_dir "$REPO_ROOT/configs/zsh_plugins" "$TARGET_HOME/.config/zsh_plugins"
copy_dir "$REPO_ROOT/local/src" "$TARGET_HOME/.local/src"
copy_dir "$REPO_ROOT/local/share/fonts" "$TARGET_HOME/.local/share/fonts"
copy_dir "$REPO_ROOT/Pictures" "$TARGET_HOME/Pictures"

chown -R "$TARGET_USER":$(id -gn "$TARGET_USER") "$TARGET_HOME/.config" "$TARGET_HOME/.local" "$TARGET_HOME/Pictures"
chmod +x "$TARGET_HOME/.xinitrc" "$TARGET_HOME/.local/src/dwm/scripts"/*.sh
fc-cache -f "$TARGET_HOME/.local/share/fonts" || true

sed -i '' 's#^FREETYPEINC = /usr/include/freetype2#FREETYPEINC = /usr/local/include/freetype2#' \
    "$TARGET_HOME/.local/src/dwm/config.mk"
(cd "$TARGET_HOME/.local/src/dwm" && gmake clean && gmake && gmake install)
(cd "$TARGET_HOME/.local/src/st" && gmake clean && gmake && gmake install)
say "dotfiles installed for $TARGET_USER"
say "backup: $BACKUP_DIR"
