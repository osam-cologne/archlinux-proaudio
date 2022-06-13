#!/bin/bash
if [ -z $CI ]; then
    echo "Only run in CI"
    exit 1
fi

cd "${0%/*}/.."
ROOT="$(pwd)"
TMP="${ROOT}/.tmp"

sudo pacman -S --noconfirm git openssh

PACKAGES="$(cd .tmp/pkgs; ls -1)"
for PKG in $PACKAGES; do
    if ! grep -Fxq $PKG "$ROOT"/aur/packages; then
        continue
    fi
    echo "Updating AUR package $PKG ..."
    cd "$TMP"/aur
    git clone -n ssh://aur.archlinux.org/$PKG.git
    cp -a "$ROOT"/packages/$PKG .
    cd $PKG

    # generate .SRCINFO
    sudo -Eu nobody makepkg --printsrcinfo > .SRCINFO

    # update .gitignore
    cat "$ROOT"/aur/gitignore-base >> .gitignore

    # commit and push
    git add .
    git commit --author="$PACKAGER" -m "$DRONE_COMMIT_MESSAGE"
    git push
done
