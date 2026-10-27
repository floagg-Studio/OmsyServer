#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

BUILD_DIR="$SOURCE_DIR/build"
BIN_DIR="$PATH_ROOT/sys/bin"

mkdir -p "$BUILD_DIR" "$BIN_DIR" "$PATH_ROOT/sys/omsy"

gcc "$SOURCE_DIR/omsyCtl/omsyd.c"   "$SOURCE_DIR/omsyCtl/common.c" -o "$BUILD_DIR/omsyd"
gcc "$SOURCE_DIR/omsyCtl/omsyctl.c" "$SOURCE_DIR/omsyCtl/common.c" -o "$BUILD_DIR/omsyctl"

mv "$BUILD_DIR/omsyd" "$BUILD_DIR/omsyctl" "$BIN_DIR/"
# mv webinterface/ to ./usr/
# mv handler/ to ./sys/omsy/
# mv lib/* to ./sys/lib/omsy/