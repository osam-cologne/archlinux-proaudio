#!/bin/bash

if [[ -z "$1" ]]; then
    echo "Usage $0 <PACKAGE>"
    exit 1
fi

ENV_FILE="$(mktemp XXXXXX.env)"
echo "PACKAGE=$1" > "$ENV_FILE"
echo "CI=true" >> "$ENV_FILE"
if [[ -n "$DRONE_SERVER" ]]; then
    echo "DRONE_SERVER=$DRONE_SERVER" >> "$ENV_FILE"
fi
if [[ -n "$DRONE_TOKEN" ]]; then
    echo "DRONE_TOKEN=$DRONE_TOKEN" >> "$ENV_FILE"
fi

cleanup() {
    rm -f "$ENV_FILE"
}

trap cleanup EXIT
drone exec --env-file "$ENV_FILE"
