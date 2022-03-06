#!/bin/bash

if [[ -z "$1" ]]; then
    echo "Usage $0 <PACKAGE>"
    exit 1
fi

ENV_FILE="$(mktemp XXXXXX.env)"
echo "PACKAGE=$1" > "$ENV_FILE"

cleanup() {
    rm -f "$ENV_FILE"
}

trap cleanup EXIT
drone exec --env-file "$ENV_FILE"
