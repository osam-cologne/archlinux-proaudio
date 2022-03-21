#!/bin/bash
# This pulls all dependencies into the pacman cache to speed up successive or
# parallel builds.

cd "${0%/*}/.."
ROOT="$(pwd)"
MAKEPKG_ARGS="$*"

cd "$ROOT/packages"

echo "Caching dependencies for packages: $PACKAGES"

for PKG in $PACKAGES; do
    cd $PKG
    makepkg -srcf --verifysource --noconfirm $MAKEPKG_ARGS
    cd ..
done
