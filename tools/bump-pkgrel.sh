#!/bin/bash

cd "${0%/*}/.."
ROOT="$(pwd)"

if [ -t 0 ]; then
    packages=("$@")
else
    mapfile -t packages
fi
for pkg in "${packages[@]}"; do
    pkgrel=$(. "$ROOT"/packages/$pkg/PKGBUILD; echo $((pkgrel+1)))
    sed -r -i -e "s/pkgrel=([0-9]+)/pkgrel=$pkgrel/g" "$ROOT"/packages/$pkg/PKGBUILD
done
