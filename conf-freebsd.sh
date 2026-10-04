#!/bin/sh
# Install Null Dotfiles on FreeBSD.
# Usage: ./install-freebsd.sh [--skip-packages] [--skip-build] [--dry-run]

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

command -v uname >/dev/null 2>&1 || die "uname is required"
[ "$(uname -s)" = "FreeBSD" ] || die "this installer is for FreeBSD only"

if [ "$DRY_RUN" -eq 1 ]; then
    run() { printf '+ '; printf '%s ' "$@"; printf '\n'; }
else
    run() { "$@"; }
fi

if [ "$(id -u)" -eq 0 ]; then
    ROOT=
elif command -v doas >/dev/null 2>&1; then
    ROOT=doas
elif command -v sudo >/dev/null 2>&1; then
    ROOT=sudo
else
    die "install doas or sudo first, or run this script as root"
fi

pkg_install() {
    [ "$SKIP_PACKAGES" -eq 1 ] && return 0
    say "Installing FreeBSD packages"
    run $ROOT pkg install -y \
        git curl ca_root_nss pkgconf gmake \
        zsh tmux neovim fzf eza bat zoxide ripgrep fd-find \
        yazi rofi dunst picom redshift feh firefox \
        zathura zathura-pdf-mupdf cmus maim slop swaylock \
        dbus pipewire wireplumber \
        xorg-server xinit xsetroot setxkbmap xrdb \
        libX11 libXft libXrender libXinerama libxcb xcb-util-wm \
        imlib2 fontconfig freetype2 harfbuzz \
        liberation-fonts-ttf
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
    say "Backing up existing files to $BACKUP_DIR"
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
    say "Building custom dwm and st"
    # FreeBSD installs headers below /usr/local, while the upstream config
    # also supports Linux's /usr/include layout.
    run sed -i '' 's#^FREETYPEINC = /usr/include/freetype2#FREETYPEINC = /usr/local/include/freetype2#' \
        "$USER_HOME/.local/src/dwm/config.mk"
    run sh -c "cd '$USER_HOME/.local/src/dwm' && make clean && make && $ROOT make install"
    run sh -c "cd '$USER_HOME/.local/src/st' && make clean && make && $ROOT make install"
}

finish() {
    say "Installation complete."
    say "Start X11 with startx; select dwm in ~/.xinitrc if needed."
    say "Your shell can be changed with: chsh -s /usr/local/bin/zsh"
    say "For PipeWire on FreeBSD, enable D-Bus if it is not already running:"
    say "  doas sysrc dbus_enable=YES && doas service dbus start"
    say "Review FreeBSD notes in README.md before logging into dwm."
}

pkg_install
install_configs
build_local_programs
finish