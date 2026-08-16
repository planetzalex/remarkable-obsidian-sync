#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TABLET_HOST=${REMARKABLE_HOST:-10.11.99.1}
VAULT_DIR=${REMARKABLE_VAULT:-/Users/alexruimy/Obsidian/reMarkable Excalidraw}
CACHE_DIR="$VAULT_DIR/.remarkable-cache/raw"
OUTPUT_DIR="$VAULT_DIR/reMarkable Pages"
PYTHON_BIN=${REMARKABLE_PYTHON:-$SCRIPT_DIR/.venv313/bin/python}
POPLER_BIN=${REMARKABLE_POPPLER_BIN:-/Users/alexruimy/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/override}

if [ ! -x "$PYTHON_BIN" ]; then
    echo "Missing converter environment: $PYTHON_BIN" >&2
    exit 1
fi

if ! ssh -o BatchMode=yes -o ConnectTimeout=3 "root@$TABLET_HOST" true; then
    echo "reMarkable is not available at $TABLET_HOST" >&2
    exit 1
fi

mkdir -p "$CACHE_DIR" "$OUTPUT_DIR"

echo "Syncing reMarkable notebooks..."
rsync -a "root@$TABLET_HOST:/home/root/.local/share/remarkable/xochitl/" "$CACHE_DIR/"

echo "Converting compatible pages to Excalidraw..."
PATH="$POPLER_BIN:/usr/bin:/bin:/usr/sbin:/sbin" \
    "$PYTHON_BIN" "$SCRIPT_DIR/main.py" -i "$CACHE_DIR" -o "$OUTPUT_DIR"
