#!/usr/bin/env bash
# ===============================================================================
# Ignytion IO - TRAINER LAB
# Copyright (c) 2026 Ignytion IO. All rights reserved.
# Author      : IGNYTION_TECH
# File        : trainer-lab/scripts/preflight.sh
# Created     : 2026-11-20
# Description : Read-only session preflight: location, memory, display and tool reachability.
# ===============================================================================
# Session preflight. Reports facts only; it changes nothing.
set -u
echo "== Where am I =="
pwd; df -h . | tail -1
case "$(pwd)" in /mnt/*) echo "WARNING: /mnt/* is Windows storage. Clone under your Linux home for build speed.";; esac
echo "== Memory =="; free -h | sed -n 1,2p
echo "== Display (needed for GTKWave / KLayout) =="
echo "DISPLAY='${DISPLAY-}' WAYLAND_DISPLAY='${WAYLAND_DISPLAY-}'"
[ -n "${DISPLAY-}${WAYLAND_DISPLAY-}" ] || echo "NOTE: no display forwarding; GUI tools will not open."
echo "== Crucible =="
if command -v igny >/dev/null; then igny --version 2>&1 | head -1; else echo "igny: not found on PATH"; fi
echo "== Tools (via igny run when available, else PATH) =="
for t in verilator make iverilog gtkwave verible-verilog-lint; do
  if command -v igny >/dev/null && igny run "$t" --version >/dev/null 2>&1; then echo "ok (igny)  $t"
  elif command -v "$t" >/dev/null; then echo "ok (PATH)  $t"
  else echo "missing    $t"; fi
done
echo "== Other =="
for t in git python3; do command -v "$t" >/dev/null && echo "ok         $t" || echo "missing    $t"; done
