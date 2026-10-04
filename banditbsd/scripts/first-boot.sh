#!/bin/sh
set -eu

say() { printf '%s\n' "[banditbsd] $*"; }
die() { printf '%s\n' "[banditbsd] error: $*" >&2; exit 1; }
[ "$(id -u)" -eq 0 ] || die "run as root"

ROOT=${BANDITBSD_ROOT:-/usr/local/share/banditbsd}
TARGET_USER=${1:-}
[ -n "$TARGET_USER" ] || die "usage: $0 USER"
[ -d "$ROOT" ] || die "BanditBSD payload not found: $ROOT"

pkg bootstrap -f
pkg update -f
install_packages() {
    list=$1
    while IFS= read -r package; do
        case "$package" in ''|'#'*) continue ;; esac
        if pkg search -e "$package" >/dev/null 2>&1; then
            pkg install -y "$package" || say "could not install optional package: $package"
        else
            say "package unavailable in repository: $package"
        fi
    done < "$ROOT/packages/$list"
}
install_packages base.txt
install_packages web-pentest.txt
install_packages network-pentest.txt

env BANDITBSD_DOTFILES_ROOT="$ROOT/dotfiles" "$ROOT/scripts/configure-system.sh" "$TARGET_USER"
env BANDITBSD_DOTFILES_ROOT="$ROOT/dotfiles" "$ROOT/scripts/install-dotfiles.sh" "$TARGET_USER"
touch /var/db/banditbsd-first-boot.done
say "first boot completed"
