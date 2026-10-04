#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
DRY_RUN=0
WITH_VM=0

say() { printf '%s\n' "[banditbsd-build] $*"; }
die() { printf '%s\n' "[banditbsd-build] error: $*" >&2; exit 1; }
run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        printf '+ '
        printf '%s ' "$@"
        printf '\n'
    else
        "$@"
    fi
}

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        --vm) WITH_VM=1 ;;
        -h|--help)
            printf '%s\n' 'Usage: ./banditbsd/build-banditbsd.sh [--dry-run] [--vm]'
            exit 0
            ;;
        *) die "unknown option: $arg" ;;
    esac
done

if [ "$(uname -s)" != FreeBSD ]; then
    [ "$DRY_RUN" -eq 1 ] || die "run this builder on FreeBSD"
    say "dry-run on non-FreeBSD host; no release build will be attempted"
fi
[ "$DRY_RUN" -eq 1 ] || {
    [ -x /usr/src/release/release.sh ] || die "/usr/src/release/release.sh not found"
    [ "$(id -u)" -eq 0 ] || die "run as root"
}

PAYLOAD="$REPO_ROOT/banditbsd/payload"
run rm -rf "$PAYLOAD"
run mkdir -p "$PAYLOAD/packages" "$PAYLOAD/dotfiles" "$PAYLOAD/scripts"
run cp "$SCRIPT_DIR/packages/"*.txt "$PAYLOAD/packages/"
run cp -R "$REPO_ROOT/.Xresources" "$REPO_ROOT/.p10k.zsh" "$REPO_ROOT/.tmux.conf" \
    "$REPO_ROOT/.xinitrc" "$REPO_ROOT/.xprofile" "$REPO_ROOT/.zshrc" "$PAYLOAD/dotfiles/"
run cp -R "$REPO_ROOT/configs" "$REPO_ROOT/local" "$REPO_ROOT/Pictures" "$PAYLOAD/dotfiles/"
run cp "$SCRIPT_DIR/scripts/configure-system.sh" "$SCRIPT_DIR/scripts/install-dotfiles.sh" "$PAYLOAD/scripts/"
run chmod +x "$PAYLOAD/scripts/"*.sh
run install -m 0755 "$PAYLOAD/scripts/first-boot.sh" "$PAYLOAD/first-boot.sh"

RELEASE_ARGS="-c $SCRIPT_DIR/release.conf"
[ "$WITH_VM" -eq 1 ] && RELEASE_ARGS="$RELEASE_ARGS WITH_VMIMAGES=1 VMBASE=banditbsd VMSIZE=20g VMFORMATS=qcow2,raw"
say "release tooling will build the FreeBSD base media"
say "payload staged at $PAYLOAD"
say "custom payload injection into bsdinstall is the next release-engineering step"
run sh -c "cd /usr/src/release && sh release.sh $RELEASE_ARGS"
