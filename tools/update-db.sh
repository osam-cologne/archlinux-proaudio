#!/bin/bash
set -x
if [ -z $CI ]; then
    echo "Only run in CI"
    exit 1
fi

cd "${0%/*}/.."
ROOT="$(pwd)"
TMP="${ROOT}/.tmp"

source /etc/makepkg.conf

# Fetch current database
cd "$ROOT"/out
curl -fO "https://arch.osamc.de/proaudio/${CARCH}/proaudio.{db,files}.tar.gz"

# Cleanup old packages from db
REMOVAL=()
for PKGPATH in $(bsdtar -tf proaudio.db.tar.gz '*/desc'); do
    FILENAME="$(bsdtar -xOqf proaudio.db.tar.gz "$PKGPATH" | sed -n '/^%FILENAME%$/ {n;p}')"
    if ! grep -qxF "$FILENAME" "$TMP"/packagelist; then
        PKGNAME="$(bsdtar -xOqf proaudio.db.tar.gz "$PKGPATH" | sed -n '/^%NAME%$/ {n;p}')"
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
