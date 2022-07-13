#!/bin/bash
if [ -z $CI ]; then
    echo "Only run in CI"
    exit 1
fi
echo '%nobody ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/nobody-sudo
cat tools/pacman.conf >> /etc/pacman.conf
cat tools/makepkg.conf >> /etc/makepkg.conf
source /etc/makepkg.conf
export PACKAGER
export SRCDEST=${SRCDEST:-/tmp/build}
export SRCPKGDEST=/tmp/build
export BUILDDIR=/tmp/build
export PKGDEST=${PKGDEST:-/tmp/build}
export LOGDEST=${LOGDEST:-$PKGDEST}
export SOURCE_DATE_EPOCH=${DRONE_BUILD_CREATED:-${DRONE_BUILD_STARTED:-$(date +%s)}}
mkdir -p .tmp/pkgs
alias run_nobody='PACKAGES="$(cd .tmp/pkgs; ls -1)" sudo -u nobody --preserve-env=CI,PACKAGER,PKGDEST,LOGDEST,SRCDEST,SRCPKGDEST,BUILDDIR,PACKAGE,PACKAGES,SOURCE_DATE_EPOCH,IGNOREDB,DRONE_TARGET_BRANCH,MAKEPKG_ARGS,MAKEFLAGS,DRONE_COMMIT_MESSAGE,PKGEXT'
