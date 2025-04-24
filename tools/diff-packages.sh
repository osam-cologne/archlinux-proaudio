#!/bin/bash
#
# Compare built packages to check for reproducible build

res=0

test -n "$PACKAGES" || exit 0

for PACKAGE in $PACKAGES; do
    if [[ ! -f "packages/$PACKAGE/PKGBUILD" ]]; then
        continue
    fi

    if [[ ! -f "packages/$PACKAGE/.no-diffoscope" ]]; then
        PKGFILES=($(makepkg -D packages/$PACKAGE --packagelist MAKEPKG_LINT_PKGBUILD=0))

        for PKG in "${PKGFILES[@]}"; do
            if [[ "$PKG" =~ '-debug-' ]]; then
                continue
            fi

            echo "Diffing out/${PKG##*/} and out2/${PKG##*/}..."
            diffoscope \
                --text - \
                --max-text-report-size 51200 \
                out/"${PKG##*/}" \
                out2/"${PKG##*/}"

            if [[ $? -ne 0 ]]; then
               res=1
            fi
        done
    else
        echo "Skipping diffoscope check of package $PACKAGE."
    fi
done

exit $res
