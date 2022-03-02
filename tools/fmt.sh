#!/bin/bash
#
# Format PKGBUILD files
#

cd "${0%/*}/.."
ROOT="$(pwd)"

shfmt -l -i 2 -sr -kp -w ${*:-packages/*/PKGBUILD}
