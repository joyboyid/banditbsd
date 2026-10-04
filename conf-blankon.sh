#!/bin/sh
# Install Null Dotfiles on BlankOn Linux.
# Usage: ./install-blankon.sh [--skip-packages] [--skip-build] [--dry-run]

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
USER_HOME=${HOME:?HOME must be set}
BACKUP_DIR="$USER_HOME/.local/state/null-dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
SKIP_PACKAGES=0
SKIP_BUILD=0
DRY_RUN=0

say() { printf '%s\n' "[null-dotfiles] $*"; }
die() { printf '%s\n' "[null-dotfiles] error: $*" >&2; exit 1; }

for arg in "$@"; do
    case "$arg" in
        --skip-packages) SKIP_PACKAGES=1 ;;
        --skip-build) SKIP_BUILD=1 ;;
        --dry-run) DRY_RUN=1 ;;
        -h|--help)
            sed -n '2,3p' "$0"
            exit 0
            ;;
        *) die "unknown option: $arg" ;;
    esac
done

command -v apt-get >/dev/null 2>&1 || die "apt-get tidak ditemukan; skrip ini untuk BlankOn/Debian"

if [ "$(id -u)" -eq 0 ]; then
    ROOT=
elif command -v doas >/dev/null 2>&1; then
    ROOT=doas
elif command -v sudo >/dev/null 2>&1; then
    ROOT=sudo
else
    die "pasang sudo/doas terlebih dahulu, atau jalankan sebagai root"
fi

if [ "$DRY_RUN" -eq 1 ]; then
    run() { printf '+ '; printf '%s ' "$@"; printf '\n'; }
else
    run() { "$@"; }
fi

apt_install() {
    [ "$SKIP_PACKAGES" -eq 1 ] && return 0
    say "Memperbarui indeks paket dan memasang dependensi BlankOn"
    run $ROOT apt-get update
    run $ROOT apt-get install -y \
        build-essential git curl ca-certificates pkg-config \
        zsh tmux neovim fzf ripgrep \
        rofi dunst picom redshift feh firefox-esr \
        zathura zathura-pdf-poppler cmus maim slop swaylock \
        pipewire pipewire-pulse wireplumber dbus-user-session \
        xserver-xorg xinit x11-xserver-utils x11-xkb-utils x11-utils \
        libx11-dev libxinerama-dev libxft-dev libxrender-dev \
        libxext-dev libxfixes-dev libxdamage-dev libxcomposite-dev \
        libx11-xcb-dev libxcb1-dev libxcb-res0-dev libxcb-util-dev \
        libxcb-ewmh-dev libxcb-icccm4-dev libimlib2 libimlib2-dev \
        libfontconfig1-dev libfreetype-dev libharfbuzz-dev \
        fonts-jetbrains-mono fonts-firacode fonts-noto-core

    # Availability varies between BlankOn releases. Do not abort the whole
    # installation when an optional convenience package is absent.
    for package in eza bat zoxide fd-find yazi; do
        if apt-cache show "$package" >/dev/null 2>&1; then
            run $ROOT apt-get install -y "$package"
        else
            say "Paket opsional $package tidak tersedia; dilewati"
        fi
    done
}

backup_path() {
    path=$1
    [ -e "$path" ] || [ -L "$path" ] || return 0
    target="$BACKUP_DIR/${path#$USER_HOME/}"
    run mkdir -p "$(dirname "$target")"
    run mv "$path" "$target"
}

copy_file() {
    source=$1
    target=$2
    backup_path "$target"
    run mkdir -p "$(dirname "$target")"
    run cp -p "$source" "$target"
}

copy_dir() {
    source=$1
    target=$2
    backup_path "$target"
    run mkdir -p "$(dirname "$target")"
    run cp -R "$source" "$target"
}

install_configs() {
    say "Mencadangkan konfigurasi lama ke $BACKUP_DIR"
    run mkdir -p "$BACKUP_DIR"

    for file in .Xresources .p10k.zsh .tmux.conf .xinitrc .xprofile .zshrc; do
        copy_file "$SCRIPT_DIR/$file" "$USER_HOME/$file"
    done

    for dir in dunst fastfetch nvim picom redshift rofi yazi zathura; do
        copy_dir "$SCRIPT_DIR/configs/$dir" "$USER_HOME/.config/$dir"
    done
    copy_dir "$SCRIPT_DIR/configs/zsh_plugins" "$USER_HOME/.config/zsh_plugins"
    copy_dir "$SCRIPT_DIR/local/src" "$USER_HOME/.local/src"
    copy_dir "$SCRIPT_DIR/local/share/fonts" "$USER_HOME/.local/share/fonts"
    copy_dir "$SCRIPT_DIR/Pictures" "$USER_HOME/Pictures"

    run fc-cache -f "$USER_HOME/.local/share/fonts"
    run chmod +x "$USER_HOME/.xinitrc"
    run chmod +x "$USER_HOME/.local/src/dwm/scripts"/*.sh
}

build_local_programs() {
    [ "$SKIP_BUILD" -eq 1 ] && return 0
    say "Mengompilasi dwm dan st custom"
    run sh -c "cd '$USER_HOME/.local/src/dwm' && make clean && make && $ROOT make install"
    run sh -c "cd '$USER_HOME/.local/src/st' && make clean && make && $ROOT make install"
}

apt_install
install_configs
build_local_programs

say "Instalasi BlankOn selesai."
say "Jalankan 'chsh -s /usr/bin/zsh' lalu 'startx' untuk memulai dwm."
say "Jika PipeWire belum aktif, jalankan: systemctl --user enable --now pipewire pipewire-pulse wireplumber"
say "Backup konfigurasi tersimpan di: $BACKUP_DIR"