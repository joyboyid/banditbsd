# BanditBSD build tree

BanditBSD is a FreeBSD-based, authorized security-testing workstation built
from the dotfiles in the repository root. LY is intentionally not used.

## Current build stages

The tree currently provides:

- separate base, web-pentest, and network-pentest package manifests;
- system configuration and dotfiles installation scripts;
- a first-boot installer that skips packages unavailable in the configured
  FreeBSD repository;
- a `release.conf` targeting FreeBSD 15.1 amd64;
- a release builder that stages a self-contained payload before invoking the
  FreeBSD release tools.

Run the validation-only path from any host:

```sh
./banditbsd/build-banditbsd.sh --dry-run
```

The actual release build must run as root on FreeBSD. If `/usr/src/release` is
not available, the builder fetches the `releng/15.1` source tree into
`/usr/local/src/freebsd-src`. Use `--source-dir=PATH` to select another source
checkout, or `--no-fetch-source` to require an existing checkout. FreeBSD's release tooling produces the standard media; the next
release-engineering stage is wiring the staged payload into the bsdinstall
post-install path so a freshly installed system runs `first-boot.sh` once.

All testing tools are intended for systems where the operator has explicit
authorization.
