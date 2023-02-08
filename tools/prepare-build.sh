#!/bin/bash
if [ -z $CI ]; then
    echo "Only run in CI"
    exit 1
fi

cd "${0%/*}/.."
ROOT="$(pwd)"
TMP="${ROOT}/.tmp"
CACHE="${TMP}/cache"
PACMAN_EXTRA="$*"

# Prepare directories
sudo rm -rf "$ROOT"/{out,out2,out.SHA512}
sudo install -o nobody -d "$ROOT"/{out,out2,out-debug}
sudo install -o nobody -d "$TMP"{,/pkgs,/ignore,/aur}
sudo install -o nobody -d "$CACHE"/srcdest

# Restore pacman cache if exists
if [ -d "$CACHE"/pkgcache ]; then
    sudo cp "$CACHE"/pkgcache/* /var/cache/pacman/pkg
fi
if [ -d "$CACHE"/pkgdb ]; then
    sudo cp "$CACHE"/pkgdb/* /var/lib/pacman/sync
fi

# Update pacman cache
sudo pacman -Syyu --noconfirm git $PACMAN_EXTRA

# some helpers
enable_pkgs() {
    MSG="$1"; shift
    for _pkg in $*; do
        echo " ${_pkg}${MSG:+: $MSG}" > "$TMP"/pkgs/$_pkg
        rm -f "$TMP"/ignore/$_pkg
    done
}

disable_pkgs() {
    MSG="$1"; shift
    for _pkg in $*; do
        echo " ${_pkg}${MSG:+: $MSG}" > "$TMP"/ignore/$_pkg
        rm -f "$TMP"/pkgs/$_pkg
    done
}

get_pkgs() {
    (cd "$TMP"/pkgs && ls -1)
}

final() {
    # sort + uniq full package list for later
    cat "$TMP"/packagelist | sort | uniq > "$TMP"/packagelist.uniq
    mv "$TMP"/packagelist.uniq "$TMP"/packagelist

    # fetch all dependencies to pacman cache
    export PACKAGES="$(get_pkgs)"
    export SRCDEST="$CACHE"/srcdest
    "$ROOT"/tools/syncdeps-all.sh $MAKEPKG_ARGS

    # Save pacman cache
    sudo mkdir -p "$CACHE"/{pkgcache,pkgdb}
    sudo cp -r /var/cache/pacman/pkg/* "$CACHE"/pkgcache
    sudo cp -r /var/lib/pacman/sync/* "$CACHE"/pkgdb

    # print report
    echo -e "\nPackages to skip:"
    cat "$TMP"/ignore/* 2>/dev/null
    echo -e "\nPackages to build:"
    cat "$TMP"/pkgs/* 2>/dev/null
    return 0
}

cd "$ROOT"/packages
ALLPKGS="$(ls -1)"
enable_pkgs "new" $ALLPKGS
trap final EXIT

source /etc/makepkg.conf

# Fetch current database
cd "$ROOT"/out
curl -fOs "https://arch.osamc.de/proaudio/${CARCH}/proaudio.db.tar.gz"
cd -

# Flag packages to ignore during build

# Ignore packages where the current version is already in the repo
if [[ -f "$ROOT"/out/proaudio.db.tar.gz ]]; then
    DB_PKGS=($(bsdtar -xOf "$ROOT"/out/proaudio.db.tar.gz '*/desc' | sed -n '/^%FILENAME%$/ {n;p}'))
    for PKG in $ALLPKGS; do
        IGN=true
        PKGFILES=($(cd $PKG; makepkg --packagelist))
        # FIXME: only remove -debug when it is a suffix. A package name like "my-debug-machine" should be kept.
        for PKGPATH in "${PKGFILES[@]/\-debug}"; do
            PKGFILE=$(basename $PKGPATH)
            echo $PKGFILE >> "$TMP"/packagelist
            if [[ ! " ${DB_PKGS[@]} " =~ " $PKGFILE " ]]; then
                IGN=false
            fi
        done
        if $IGN; then
            disable_pkgs "current version already in repo" $PKG
        fi
    done
fi

# If a single package is provided in the PACKAGE variable, ignore all others
if [[ -n "$PACKAGE" && -e $PACKAGE ]]; then
    disable_pkgs "not selected" $ALLPKGS
    enable_pkgs "building single selected package" $PACKAGE
    exit 0
fi

# ignore packages that don't support our architecture
for PKG in $(get_pkgs); do
    ARCH="$(. "$PKG"/PKGBUILD; echo "${arch[@]}")"
    if [[ "$ARCH" != "any" && ! " $ARCH " =~ "$CARCH" ]]; then
        disable_pkgs "unsupported architecture" $PKG
    fi
done
