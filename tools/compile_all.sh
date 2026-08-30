#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$ROOT/addons/sourcemod/scripting"
PLUGIN_DIR="$ROOT/addons/sourcemod/plugins"
INCLUDE_DIR="$SCRIPT_DIR/include"

if [[ -n "${SPCOMP:-}" ]]; then
    COMPILER="$SPCOMP"
elif [[ -x "$SCRIPT_DIR/spcomp" ]]; then
    COMPILER="$SCRIPT_DIR/spcomp"
elif command -v spcomp >/dev/null 2>&1; then
    COMPILER="$(command -v spcomp)"
else
    echo "ERROR: spcomp not found. Set SPCOMP=/path/to/spcomp" >&2
    exit 2
fi

mkdir -p "$PLUGIN_DIR"
shopt -s nullglob
for src in "$SCRIPT_DIR"/*.sp; do
    base="$(basename "$src" .sp)"
    echo "[SPCOMP] $base.sp"
    "$COMPILER" -i"$INCLUDE_DIR" "$src" -o"$PLUGIN_DIR/$base.smx"
done

echo "Build complete. Compiler: $COMPILER"
