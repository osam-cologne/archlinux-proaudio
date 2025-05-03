#!/bin/bash
if [ -z $CI ]; then
    echo "Only run in CI"
    exit 1
fi

cd "${0%/*}/.."
ROOT="$(pwd)"

function bumpver() {
    sed -r -i -e "s/^pkgver=(.*)$/pkgver=$1/g" PKGBUILD
    updpkgsums
    git add .
}

git fetch origin

nvcmp -c nvchecker/archlinux-proaudio.toml --newer | while read -ra line; do
    PKG=${line[0]}
    VER=${line[3]}
    BRANCH=nvpr/update/$PKG
    TITLE="$PKG: update to v$VER"
    URL="$(jq -r '.data."'$PKG'".url // empty' nvchecker/new_ver.json)"
    BODY="$URL"
    pushd packages/$PKG
        if git switch $BRANCH; then
            # update
            bumpver $VER
            git commit -m "$TITLE"
            git push
            gh pr edit -t "$TITLE" -b "$BODY"
        else
            # create
            git switch -c $BRANCH
            bumpver $VER
            git commit -m "$TITLE"
            git push -u origin $BRANCH
            gh pr create --dry-run -t "$TITLE" -b "$BODY"
        fi
        git switch master
    popd
done
