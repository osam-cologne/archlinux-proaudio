#!/bin/bash
#
# Build and preview project website locally from repository checkout
#

if [[ ! -f config.yml ]]; then
    echo "Please run this script from the repository root." > /dev/stderr
    exit 1
fi

if ! which hugo >/dev/null 2>&1; then
    echo "Please install 'hugo' to use this script." > /dev/stderr
    exit 1
fi

for ARCH in x86_64 aarch64; do
    mkdir -p .tmp/db/$ARCH &&
    curl https://arch.osamc.de/proaudio/$ARCH/proaudio.files.tar.gz |
    bsdtar -xC .tmp/db/$ARCH
done

exec hugo server "@"

