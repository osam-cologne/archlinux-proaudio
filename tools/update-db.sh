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

# Extract new db
rm -rf "$TMP"/repo/*
bsdtar -xf proaudio.db.tar.gz -C "$TMP"/repo

# Generate badge
COUNT=$(ls -1 "$TMP"/repo/ | wc -l)
BADGE="${CARCH/_/__}_packages-${COUNT}-informational"
curl -fo badge-count.svg https://img.shields.io/badge/${BADGE}

# Generate descriptions for apache directory listing
# https://httpd.apache.org/docs/2.4/mod/mod_autoindex.html
(
    for PKGPATH in "$TMP"/repo/*/desc; do
        FILENAME="$(sed -n '/^%FILENAME%$/ {n;p}' "$PKGPATH")"
        # get description but remove double quotes
        DESC="$(sed -n '/^%DESC%$/ {n;s/"//g;p}' "$PKGPATH")"
        # the filename length is used for sorting to prevent false matches
        # because apache will match partial names and use the first match
        # (e.g. python-alsa-1.2-3 =~ alsa-1.2-3)
        echo ${#FILENAME} AddDescription \"${DESC}\" ${FILENAME}
    done
) | sort -nrs | cut -d " " -f2- > .htaccess
