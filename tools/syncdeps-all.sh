#!/bin/bash

# makepkg -src installs and removes required dependencies so this can be run on CI,
# for example the archlinux/archlinux:base-devel image, to build from a clean root.

cd "${0%/*}/.."
ROOT="$(pwd)"
MAKEPKG_ARGS="$*"

cd "$ROOT/packages"

if [[ -n "$PACKAGE" ]]; then
    echo "Caching dependencies for package $PACKAGE..."
    PACKAGES="$PACKAGE"
else
    echo "Caching dependencies for all packages..."
    PACKAGES="$(ls -1)"
fi

for PKG in $PACKAGES; do
    cd $PKG
    makepkg -srcf --verifysource --noconfirm $MAKEPKG_ARGS
    cd ..
done
