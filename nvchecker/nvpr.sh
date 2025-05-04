#!/bin/bash
if [ -z $CI ]; then
    echo "Only run in CI"
    exit 1
fi

cd "${0%/*}/.."
ROOT="$(pwd)"

git fetch origin

nvcmp -c nvchecker/archlinux-proaudio.toml --newer | while read -ra line; do
    PKG=${line[0]}
    VER=${line[3]}
    BRANCH=nvpr/update/$PKG
    TITLE="$PKG: update to v$VER"
    URL="$(jq -r '.data."'$PKG'".url // empty' nvchecker/new_ver.json)"
    BODY="$URL"
    BASE=$(git branch --show-current)
    pushd packages/$PKG
        git switch $BRANCH || git switch -c $BRANCH
        bumpver $VER
        sed -r -i -e "s/^pkgver=(.*)$/pkgver=$1/g" -e 's/^pkgrel=(.*)$/pkgrel=1/g' PKGBUILD
        chown -R nobody: .
        sudo -u nobody updpkgsums
        git add .
        git commit -m "$TITLE"
        git push -u origin $BRANCH
        gh pr edit -t "$TITLE" -b "$BODY" || gh pr create -t "$TITLE" -b "$BODY"
        git switch $BASE
    popd
done
