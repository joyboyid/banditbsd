#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
DRY_RUN=0
WITH_VM=0
FETCH_SOURCE=1
SOURCE_TREE=${BANDITBSD_SOURCE_TREE:-/usr/src}
FREEBSD_BRANCH=${BANDITBSD_BRANCH:-releng/15.1}
FREEBSD_GIT_URL=${BANDITBSD_GIT_URL:-https://git.freebsd.org/src.git}

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
        --source-dir=*) SOURCE_TREE=${arg#*=} ;;
        --no-fetch-source) FETCH_SOURCE=0 ;;
        -h|--help)
            printf '%s\n' 'Usage: ./banditbsd/build-banditbsd.sh [--dry-run] [--vm] [--source-dir=PATH] [--no-fetch-source]'
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
    [ "$(id -u)" -eq 0 ] || die "run as root"
}

RELEASE_SH="$SOURCE_TREE/release/release.sh"
if [ ! -x "$RELEASE_SH" ]; then
    if [ "$DRY_RUN" -eq 1 ]; then
        say "source tree missing at $SOURCE_TREE; would fetch branch $FREEBSD_BRANCH"
        RELEASE_SH="$SOURCE_TREE/release/release.sh"
    elif [ "$FETCH_SOURCE" -eq 0 ]; then
        die "$RELEASE_SH not found; install FreeBSD source or remove --no-fetch-source"
    else
        if [ "$SOURCE_TREE" = /usr/src ]; then
            SOURCE_TREE=/usr/local/src/freebsd-src
        fi
        RELEASE_SH="$SOURCE_TREE/release/release.sh"
        if [ ! -x "$RELEASE_SH" ]; then
            command -v git >/dev/null 2>&1 || die "git is required to fetch FreeBSD source"
            mkdir -p "$(dirname "$SOURCE_TREE")"
            if [ -e "$SOURCE_TREE" ]; then
                [ -d "$SOURCE_TREE/.git" ] || die "source directory exists but is not a git checkout: $SOURCE_TREE"
                say "updating FreeBSD source at $SOURCE_TREE"
                git -C "$SOURCE_TREE" fetch --depth 1 origin "$FREEBSD_BRANCH"
                git -C "$SOURCE_TREE" checkout -B "$FREEBSD_BRANCH" "FETCH_HEAD"
            else
                say "fetching FreeBSD source branch $FREEBSD_BRANCH"
                git clone --depth 1 --branch "$FREEBSD_BRANCH" "$FREEBSD_GIT_URL" "$SOURCE_TREE"
            fi
        fi
    fi
fi

PAYLOAD="$REPO_ROOT/banditbsd/payload"
run rm -rf "$PAYLOAD"
run mkdir -p "$PAYLOAD/packages" "$PAYLOAD/dotfiles" "$PAYLOAD/scripts"
run cp "$SCRIPT_DIR/packages/"*.txt "$PAYLOAD/packages/"
run cp -R "$REPO_ROOT/.Xresources" "$REPO_ROOT/.p10k.zsh" "$REPO_ROOT/.tmux.conf" \
    "$REPO_ROOT/.xinitrc" "$REPO_ROOT/.xprofile" "$REPO_ROOT/.zshrc" "$PAYLOAD/dotfiles/"
run cp -R "$REPO_ROOT/configs" "$REPO_ROOT/local" "$REPO_ROOT/Pictures" "$PAYLOAD/dotfiles/"
run cp "$SCRIPT_DIR/scripts/configure-system.sh" "$SCRIPT_DIR/scripts/install-dotfiles.sh" \
    "$SCRIPT_DIR/scripts/first-boot.sh" "$PAYLOAD/scripts/"
run chmod +x "$PAYLOAD/scripts/"*.sh
run install -m 0755 "$PAYLOAD/scripts/first-boot.sh" "$PAYLOAD/first-boot.sh"

RELEASE_ARGS="-c $SCRIPT_DIR/release.conf"
[ "$WITH_VM" -eq 1 ] && RELEASE_ARGS="$RELEASE_ARGS WITH_VMIMAGES=1 VMBASE=banditbsd VMSIZE=20g VMFORMATS=qcow2,raw"
say "release tooling will build the FreeBSD base media"
say "payload staged at $PAYLOAD"
say "custom payload injection into bsdinstall is the next release-engineering step"
run sh -c "cd '$SOURCE_TREE/release' && sh release.sh $RELEASE_ARGS"
