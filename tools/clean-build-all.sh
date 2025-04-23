#!/bin/bash
# makepkg -src installs and removes required dependencies so this can be run on CI,
# for example the archlinux/archlinux:base-devel image, to build from a clean root.

cd "${0%/*}/.."
ROOT="$(pwd)"
MAKEPKG_ARGS="$* $MAKEPKG_ARGS"

SUCC=0
FAIL=0

cd "$ROOT/packages"
TOTAL=$(ls -1 | wc -l)

echo "Building packages: $PACKAGES"
echo "Epoch is $SOURCE_DATE_EPOCH"

for PKG in $PACKAGES; do
    pushd $PKG
    PKGLIST=($(makepkg --packagelist MAKEPKG_LINT_PKGBUILD=0))

    if makepkg -srcf --noconfirm $MAKEPKG_ARGS; then
        SUCC=$((SUCC+1))
    else
        FAIL=$((FAIL+1))
        rm -f $PKGLIST
    fi

    popd
done

echo "$SUCC built, $FAIL failed, $((TOTAL-SUCC-FAIL)) skipped"

[ $FAIL -eq 0 ] || exit 1
