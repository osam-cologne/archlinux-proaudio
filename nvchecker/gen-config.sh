#!/bin/bash

cd "${0%/*}/.."
ROOT="$(pwd)"

CFG=nvchecker/archlinux-proaudio.toml
VER=nvchecker/old_ver.json
cat > $CFG << __EOF__
[__config__]
oldver = "old_ver.json"
newver = "new_ver.json"
keyfile = "keyfile.toml"
__EOF__

VER_TEMP="$(mktemp)"
for f in packages/*/.nvchecker.toml; do
  echo "" >> $CFG
  cat $f >> $CFG
  pkgdir=$(dirname $f)
  pkgbase=$(basename $pkgdir)
  pkgver=$(. $pkgdir/PKGBUILD; echo $pkgver)
  printf '{"%s": "%s"}\n' $pkgbase $pkgver >> "$VER_TEMP"
done
jq -s add "$VER_TEMP" > $VER
