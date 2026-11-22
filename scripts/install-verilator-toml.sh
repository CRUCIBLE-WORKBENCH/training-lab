#!/usr/bin/env bash
# ===============================================================================
# Ignytion IO - TRAINER LAB
# Copyright (c) 2026 Ignytion IO. All rights reserved.
# Author      : IGNYTION_TECH
# File        : trainer-lab/scripts/install-verilator-toml.sh
# Created     : 2026-11-22
# Description : Places the verilator.toml we hand out into the Crucible registry (needed for UVM).
# ===============================================================================
# Usage: ./scripts/install-verilator-toml.sh /path/to/verilator.toml
#
# The verilator.toml file is NOT in this repository. We give it to you at the
# session. This script copies it to:
#   ~/.ignytion/.crucible/registry/tools/verilator.toml
# An existing file is kept as verilator.toml.bak-<timestamp>.
set -euo pipefail

SRC="${1:-}"
[ -n "$SRC" ] || { echo "Usage: $0 /path/to/verilator.toml  (the file we give you)" >&2; exit 2; }
[ -f "$SRC" ] || { echo "Not a file: $SRC" >&2; exit 2; }
grep -q '^name = "verilator"' "$SRC" || { echo "Refusing: $SRC does not look like the verilator tool file (no: name = \"verilator\")." >&2; exit 2; }

DIR="$HOME/.ignytion/.crucible/registry/tools"
[ -d "$DIR" ] || { echo "Registry folder not found: $DIR" >&2; echo "Run igny init (or any igny command) once, then try again." >&2; exit 1; }
DEST="$DIR/verilator.toml"

if [ -f "$DEST" ]; then
  if cmp -s "$SRC" "$DEST"; then echo "Already installed and identical: $DEST"; exit 0; fi
  BAK="$DEST.bak-$(date +%Y%m%d-%H%M%S)"
  cp -p "$DEST" "$BAK"
  echo "Existing file kept as $BAK"
fi
cp "$SRC" "$DEST"
echo "Installed $DEST"
