#!/bin/bash
set -e
shopt -s nullglob
if [ -z $CI ]; then
    echo "Only run in CI"
    exit 1
fi

cd "${0%/*}/.."
ROOT="$(pwd)"
TMP="${ROOT}/.tmp"

source /etc/makepkg.conf

# Fetch current database and extract
cd "$ROOT"/out
curl -fO "https://arch.osamc.de/proaudio/${CARCH}/proaudio.{db,files}.tar.gz"
mkdir -p "$TMP"/repo
bsdtar -xf proaudio.db.tar.gz -C "$TMP"/repo

# Cleanup old packages from db. $TMP/packagelist was created in the earlier
# prepare step and contains a list of package files built from all packages
# in this repo. This allows checking (and removing) packages simply by removing
# their PKGBUILD from this repo.
# This also covers renaming packages or merging split packages.
REMOVAL=()
for PKGPATH in "$TMP"/repo/*/desc; do
    FILENAME="$(sed -n '/^%FILENAME%$/ {n;p}' "$PKGPATH")"
    if ! grep -qxF "$FILENAME" "$TMP"/packagelist; then
        # $FILENAME is not built by any of our packages, let's remove it from the db
        PKGNAME="$(sed -n '/^%NAME%$/ {n;p}' "$PKGPATH")"
        REMOVAL+=(${PKGNAME})
    fi
done
repo-remove proaudio.db.tar.gz ${REMOVAL[@]}
echo "Packages removed from db:"
printf " %s\n" "${REMOVAL[@]}"

# Add newly built packages to db
repo-add proaudio.db.tar.gz *$PKGEXT

# Generate badge
COUNT=$(bsdtar -tf proaudio.db.tar.gz '*/desc' | wc -l)
BADGE="${CARCH/_/__}_packages-${COUNT}-informational"
curl -fo badge-count.svg https://img.shields.io/badge/${BADGE}
