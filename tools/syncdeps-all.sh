#!/bin/bash

# makepkg -src installs and removes required dependencies so this can be run on CI,
# for example the archlinux/archlinux:base-devel image, to build from a clean root.

cd "${0%/*}/.."
ROOT="$(pwd)"
MAKEPKG_ARGS="$*"

cd "$ROOT/packages"
for PKG in *; do
	cd $PKG
	makepkg -socef --noconfirm $MAKEPKG_ARGS
	cd ..
done
