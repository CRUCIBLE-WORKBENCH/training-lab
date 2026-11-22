#!/usr/bin/env bash
# ===============================================================================
# Ignytion IO - TRAINER LAB
# Copyright (c) 2026 Ignytion IO. All rights reserved.
# Author      : IGNYTION_TECH
# File        : trainer-lab/scripts/fetch-uvm.sh
# Created     : 2026-11-20
# Description : Fetches the pinned Verilator-compatible Accellera UVM library into third_party/ (slide 16).
# ===============================================================================
# Fetch the Verilator-compatible Accellera UVM library at a pinned revision.
# Needed only for the UVM session (slide 16). Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")/.."
REPO=https://github.com/verilator/uvm.git
REV=656f20d087370a7c742e00188d20bbf30fa95339
DEST=third_party/uvm
if [ ! -f "$DEST/src/uvm_pkg.sv" ]; then
  mkdir -p "$DEST"
  git init -q "$DEST"
  git -C "$DEST" remote add origin "$REPO"
  git -C "$DEST" fetch -q --depth 1 origin "$REV"
  git -C "$DEST" checkout -q --detach FETCH_HEAD
fi
test "$(git -C "$DEST" rev-parse HEAD)" = "$REV" || { echo "UVM revision mismatch" >&2; exit 1; }
echo "UVM ready at $DEST ($REV)"
