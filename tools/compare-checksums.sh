#!/bin/bash
#
# Compare SHA checksum of built packages

res=0

PACKAGES="$(cd .tmp/pkgs; ls -1)"

for PACKAGE in $PACKAGES; do
    if [[ ! -f "packages/$PACKAGE/PKGBUILD" ]]; then
        continue
    fi

    if [[ ! -f "packages/$PACKAGE/.no-checksum" ]]; then
        PKGFILES=($(cd packages/$PACKAGE; makepkg --packagelist))

        for PKG in "${PKGFILES[@]}"; do
            if [[ "$PKG" =~ '-debug-' ]]; then
                continue
            fi

            echo "Comparing checksum of out/${PKG##*/}..."
            cd out
            sha512sum "${PKG##*/}" > "${TMP:-/tmp}/${PKG##*/}".sha512
            cd ../out2
            sha512sum -c "${TMP:-/tmp}/${PKG##*/}".sha512

            if [[ $? -ne 0 ]]; then
               res=1
            fi
        done
    else
        echo "Skipping checksum check of package $PACKAGE."
    fi
done

exit $res
