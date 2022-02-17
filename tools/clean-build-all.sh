#!/bin/bash

# makepkg -src installs and removes required dependencies so this can be run on CI,
# for example the archlinux/archlinux:base-devel image, to build from a clean root.

cd "${0%/*}/.."
ROOT="$(pwd)"

export PKGDEST="$ROOT/out"
export LOGDEST="$ROOT/out"

SUCC=0
FAIL=0
SKIP=0

cd "$ROOT/packages"
for PKG in *; do
	cd $PKG
	PKGLIST="$(makepkg --packagelist)"
	if ls $PKGLIST 2>/dev/null 1>&2; then
		SKIP=$((SKIP+1))
		echo "$PKG fully built, skipping ..."
		cd ..
		continue
	fi

	if makepkg -srcf --noconfirm --noprogressbar; then
		SUCC=$((SUCC+1))
	else
		FAIL=$((FAIL+1))
		rm -f $PKGLIST
	fi
	cd ..
done

echo "$SUCC built, $FAIL failed, $SKIP skipped"

[ $FAIL -eq 0 ] || exit 1
