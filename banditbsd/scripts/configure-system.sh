#!/bin/sh
set -eu

say() { printf '%s\n' "[banditbsd] $*"; }
die() { printf '%s\n' "[banditbsd] error: $*" >&2; exit 1; }
[ "$(id -u)" -eq 0 ] || die "run as root"
TARGET_USER=${1:-}
[ -n "$TARGET_USER" ] || die "usage: $0 USER"
pw usershow "$TARGET_USER" >/dev/null 2>&1 || die "user not found: $TARGET_USER"

pw usermod "$TARGET_USER" -s /usr/local/bin/zsh
sysrc dbus_enable=YES
sysrc hostname="banditbsd"
sysrc dumpdev="NO"
sysrc sendmail_enable="NONE"

install -d -m 0755 /usr/local/share/banditbsd
cat > /etc/motd <<'MOTD'
BanditBSD — authorized web and network security testing environment.
Use only against systems you own or have explicit permission to test.
MOTD

say "system configured for $TARGET_USER"
say "review /etc/rc.conf before enabling hardware-specific services"
