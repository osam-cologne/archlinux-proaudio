#!/bin/sh
set -e
bindir=`dirname "$0"`
sharedir="$bindir"/../share
exec java -jar "$sharedir"/ConvertWithMoss/convertwithmoss-6.0.0.jar "$@"
