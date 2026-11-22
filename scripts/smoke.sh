#!/usr/bin/env bash
# ===============================================================================
# Ignytion IO - TRAINER LAB
# Copyright (c) 2026 Ignytion IO. All rights reserved.
# Author      : IGNYTION_TECH
# File        : trainer-lab/scripts/smoke.sh
# Created     : 2026-11-20
# Description : Day-0 smoke test: lint, simulation, mutant rejection and, if fetched, UVM hello (slides 11-16).
# ===============================================================================
# Day-0 smoke test for slides 11-14 (and 16 when UVM is fetched).
# It never edits rtl/: the mutation runs on a copy under build/.
# Uses "igny run" when igny is on PATH; override with RUN= to use plain PATH tools.
set -uo pipefail
cd "$(dirname "$0")/.."
if [ -z "${RUN+x}" ]; then if command -v igny >/dev/null; then RUN="igny run"; else RUN=""; fi; fi
fail=0
check() { if [ "$2" = ok ]; then echo "PASS  $1"; else echo "FAIL  $1"; fail=1; fi; }

echo "RUN prefix: '${RUN}'"
rm -rf build/hello build/mutant; mkdir -p build

# Older Verilator releases print a "Verilation Report" even for a clean lint, so
# judge lint by exit status and by the absence of warning/error lines.
out=$($RUN verilator --lint-only -Wall rtl/hello.sv 2>&1); rc=$?
[ $rc -eq 0 ] && ! echo "$out" | grep -Eq '^%(Warning|Error)'   && check "lint exits 0 with no warnings or errors" ok || { echo "$out"; check "lint exits 0 with no warnings or errors" bad; }

$RUN verilator --binary --timing --trace --assert --top-module tb --Mdir build/hello \
  rtl/hello.sv tb/tb.sv >build/hello.build.log 2>&1 \
  && check "correct RTL builds" ok || { tail -20 build/hello.build.log; check "correct RTL builds" bad; }
out=$(cd build && ./hello/Vtb 2>&1); rc=$?
[ $rc -eq 0 ] && echo "$out" | grep -q "PASS: 4 input combinations" \
  && check "correct RTL passes (exit 0 + PASS text)" ok || { echo "$out"; check "correct RTL passes (exit 0 + PASS text)" bad; }

mkdir -p build/mutant_src
sed 's/a_i & b_i/a_i | b_i/' rtl/hello.sv > build/mutant_src/hello.sv
$RUN verilator --binary --timing --trace --assert --top-module tb --Mdir build/mutant \
  build/mutant_src/hello.sv tb/tb.sv >build/mutant.build.log 2>&1 \
  && check "mutant (a|b) builds" ok || { tail -20 build/mutant.build.log; check "mutant (a|b) builds" bad; }
out=$(cd build && ./mutant/Vtb 2>&1); rc=$?
[ $rc -ne 0 ] && echo "$out" | grep -qi "mismatch" && ! echo "$out" | grep -q "^PASS" \
  && check "mutant is rejected (nonzero exit, no PASS)" ok || { echo "$out (exit $rc)"; check "mutant is rejected (nonzero exit, no PASS)" bad; }

if [ -f third_party/uvm/src/uvm_pkg.sv ]; then
  out=$($RUN make -C uvm_hello sim JOBS=2 2>&1); rc=$?
  [ $rc -eq 0 ] && echo "$out" | grep -q "TEST PASSED: all 4" \
    && echo "$out" | grep -Eq "UVM_ERROR *: *0" && echo "$out" | grep -Eq "UVM_FATAL *: *0" \
    && check "UVM hello passes (0 errors, 0 fatals)" ok || { echo "$out" | tail -25; check "UVM hello passes (0 errors, 0 fatals)" bad
    echo "HINT  This UVM revision was validated with Verilator 5.047 from Crucible; Debian's 5.032 fails to elaborate it."
    echo "HINT  Your Verilator: $($RUN verilator --version 2>&1 | head -1)"; }
  out=$($RUN make -C uvm_hello negative 2>&1); rc=$?
  # The fixture can print "TEST PASSED" next to a UVM_FATAL, so grade on the exit status
  # and the fatal mismatch, never on PASS text.
  [ $rc -ne 0 ] && echo "$out" | grep -Eq "UVM_FATAL .*\[MISMATCH\]" \
    && check "UVM negative target fails the run" ok || { echo "$out" | tail -25; check "UVM negative target fails the run" bad; }
else
  echo "SKIP  UVM hello (run scripts/fetch-uvm.sh first)"
fi

[ $fail -eq 0 ] && echo "SMOKE OK" || echo "SMOKE FAILED"
exit $fail
