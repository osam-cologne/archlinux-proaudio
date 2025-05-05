#!/bin/bash -x

PKGDB_URL="https://arch.osamc.de/proaudio/x86_64/proaudio.db"
INTERVAL=14
ETAG="./package-db/sync/proaudio.db.etag"
CURL_OPTS="--etag-save $ETAG"

mkdir -p ./package-db/sync

if [[ -f "$ETAG" ]]; then
    CURL_OPTS="$CURL_OPTS --etag-compare $ETAG"
fi
curl --silent \
    --compressed \
    --remote-time \
    -o ./package-db/sync/proaudio.db \
    $CURL_OPTS \
    "$PKGDB_URL"
python getnewpackages.py \
    --db proaudio \
    --history-file history.db \
    --interval $INTERVAL \
    "$@" \
    $(pwd)/package-db
