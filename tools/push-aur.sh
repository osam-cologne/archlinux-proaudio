#!/bin/bash
if [ -z $CI ]; then
    echo "Only run in CI"
    exit 1
fi

set -e

cd "${0%/*}/.."
ROOT="$(pwd)"
TMP="$ROOT/.tmp"

sudo pacman -S --noconfirm git openssh

PACKAGES="$(cd "$TMP"/pkgs; ls -1)"
for PKG in $PACKAGES; do
    if ! grep -Fxq $PKG "$ROOT"/aur/packages; then
        continue
    fi
    echo "Updating AUR package $PKG ..."
    cd "$TMP"/aur
    echo "Cloning AUR repository for $PKG ..."
    git clone -n ssh://aur.archlinux.org/$PKG.git
    cp -a "$ROOT"/packages/$PKG .
    cd $PKG

    # generate .SRCINFO
    echo "Generating .SRCINFO for $PKG ..."
    sudo -Eu nobody makepkg --printsrcinfo > .SRCINFO

    # update .gitignore
    cat "$ROOT"/aur/gitignore-base >> .gitignore

    # commit and push
    echo "Committing and pushing new version of $PKG to AUR ..."
    git add .
    git commit --author="$PACKAGER" -m "$DRONE_COMMIT_MESSAGE"
    git push
done
