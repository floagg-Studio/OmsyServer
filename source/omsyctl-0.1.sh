#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

BUILD_DIR="$SOURCE_DIR/build"
BIN_DIR="$PATH_ROOT/sys/bin"

mkdir -p "$BUILD_DIR" "$BIN_DIR" "$PATH_ROOT/sys/omsy"

gcc "$SOURCE_DIR/omsyCtl/omsyd.c"   "$PATH_ROOT/sys/include/omsy/common.c" -o "$BIN_DIR/omsyd"
gcc "$SOURCE_DIR/omsyCtl/omsyctl.c" "$PATH_ROOT/sys/include/omsy/common.c" -o "$BIN_DIR/omsyctl"

# mv "$BUILD_DIR/omsyd" "$BUILD_DIR/omsyctl" "$BIN_DIR/"
# mv webinterface/ to ./usr/
# mv handler/ to ./sys/omsy/
# mv lib/* to ./sys/lib/omsy/