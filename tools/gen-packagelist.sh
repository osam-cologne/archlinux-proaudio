#!/bin/bash
if [ -z $CI ]; then
    echo "Only run in CI"
    exit 1
fi

cd "${0%/*}/.."
ROOT="$(pwd)"
TMP="${ROOT}/.tmp"

cd "$ROOT"/packages
ALLPKGS="$(ls -1)"

for PKG in $ALLPKGS; do
    if [[ ! -f "$PKG/PKGBUILD" ]]; then
        echo "Directory $PKG does not contain a PKGBUILD file"
        continue
    fi

    PKGFILES=($(cd $PKG; makepkg --packagelist))
    # FIXME: only remove -debug when it is a suffix. A package name like "my-debug-machine" should be kept.
    for PKGPATH in "${PKGFILES[@]/\-debug}"; do
        PKGFILE=$(basename $PKGPATH)
        echo $PKGFILE >> "$TMP"/packagelist
    done
done

cat "$TMP"/packagelist | sort | uniq > "$TMP"/packagelist.uniq
mv "$TMP"/packagelist.uniq "$TMP"/packagelist
