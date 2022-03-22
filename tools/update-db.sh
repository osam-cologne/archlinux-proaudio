#!/bin/bash
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
curl -fOs "https://arch.osamc.de/proaudio/${CARCH}/proaudio.{db,files}.tar.gz"

# Add newly built packages to db
repo-add proaudio.db.tar.gz *$PKGEXT

# Cleanup old packages from db
> "$TMP"/removal
for PKGPATH in $(bsdtar -tf proaudio.db.tar.gz '*/desc'); do
    FILENAME="$(bsdtar -xOqf proaudio.db.tar.gz "$PKGPATH" | sed -n '/^%FILENAME%$/ {n;p}')"
    if ! grep -qxF "$FILENAME" "$TMP"/packagelist; then
        PKGNAME="$(bsdtar -xOqf proaudio.db.tar.gz "$PKGPATH" | sed -n '/^%NAME%$/ {n;p}')"
        echo "$FILENAME" >> "$TMP"/removal
        repo-remove proaudio.db.tar.gz "$PKGNAME"
    fi
done
echo "Packages removed from db:"
cat "$TMP"/removal
