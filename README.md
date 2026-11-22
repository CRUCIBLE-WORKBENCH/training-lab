<!--
===============================================================================
Ignytion IO - TRAINER LAB
Copyright (c) 2026 Ignytion IO. All rights reserved.
Author      : IGNYTION_TECH
File        : trainer-lab/README.md
Created     : 2026-11-20
Description : Follow-along guide for the trainer onboarding session.
===============================================================================
-->

# Trainer Lab: follow-along repository

Starter files for the **trainer onboarding session** (Ignytion IO).
Clone it, run the preflight, and you can type along with the session.

## 1. Before the session (10 minutes)

Use a Linux shell: native Ubuntu 22.04/24.04, or the WSL setup provided for the workshop.
Clone under your **Linux home**, not under `/mnt/c`, so builds are fast.

```bash
git clone <REPO_URL> ~/trainer-lab
cd ~/trainer-lab
./scripts/preflight.sh
```

`preflight.sh` only reports: where you are, memory, display forwarding (GUI tools need it),
the `igny` version, and which tools are reachable. Send a screenshot of anything marked `missing`
or `WARNING` before the session.

## 2. Workspace

The names below are examples; any names work if you use them consistently:

```bash
igny env create trainer             # once; skip if it already exists
cd ~/trainer-lab
igny workspace create trainer-lab --env trainer
igny workspace show
```

If `igny` refuses because the folder is not empty, say so in the session. Do not force it.
The repo ships no `crucible.toml` or `crucible.lock`; each trainer creates their own.

## 3. Basic Python script

`python/hello.py` prints the truth table of an AND gate and checks it. Run it inside the Crucible
environment, or with the system Python, and compare:

```bash
igny run script python/hello.py     # runs inside the resolved Crucible environment
python3 python/hello.py             # same script with the system Python
make py                             # shortcut: uses igny run script when igny is on PATH
```

Expect `PASS: 4 input combinations` and exit status 0.

## 4. Basic Verilog and SystemVerilog

Plain Verilog-2001, a 4-bit counter with a self-checking testbench (`rtl/counter.v`, `tb/counter_tb.v`):

```bash
mkdir -p build
igny run verilator --binary --timing --trace --top-module counter_tb \
  --Mdir build/counter rtl/counter.v tb/counter_tb.v
(cd build && ./counter/Vcounter_tb)    # expect: PASS: counted 20 cycles, wrap included
make verilog                           # shortcut for the two commands above
```

SystemVerilog, a 2-input AND gate with a timed testbench (`rtl/hello.sv`, `tb/tb.sv`):

```bash
igny run verilator --lint-only -Wall rtl/hello.sv
igny run verilator --binary --timing --trace \
  --assert --top-module tb --Mdir build/hello \
  rtl/hello.sv tb/tb.sv
(cd build && ./hello/Vtb)           # expect: PASS: 4 input combinations
echo $?                             # expect: 0
```

Both testbenches dump a `.vcd` waveform into the folder you run them from, so for example
`igny run gtkwave build/hello.vcd` opens it (needs display forwarding). For a mutation exercise, change
`a_i & b_i` to `a_i | b_i` in `rtl/hello.sv` (or `+ 4'd1` to `+ 4'd2` in `rtl/counter.v`), rebuild and rerun:
the testbench must exit nonzero and print a mismatch. Restore the file afterwards with `git checkout rtl/`.

## 5. UVM: one extra file, which we give you

Using UVM here needs a Crucible registry file called `verilator.toml` in
`~/.ignytion/.crucible/registry/tools/`.

**We will give you this file at the session. It is not in this repository.** When you have it:

```bash
./scripts/install-verilator-toml.sh /path/to/verilator.toml
# or: make uvm-toml TOML=/path/to/verilator.toml
igny tool show verilator
```

The script copies the file into place, keeps any file already there as `verilator.toml.bak-<timestamp>`,
and refuses a file that is not the verilator tool definition. Then run UVM hello:

```bash
./scripts/fetch-uvm.sh                       # pinned Accellera UVM for Verilator, into third_party/
igny run make -C uvm_hello build JOBS=2
igny run make -C uvm_hello sim               # expect TEST PASSED, UVM_ERROR : 0, UVM_FATAL : 0
igny run make -C uvm_hello negative          # must FAIL (injected mismatch)
```

UVM ends a run with `$finish` even after `UVM_FATAL`, so the simulator itself exits 0 and the fixture can
still print `TEST PASSED`. The Makefile therefore grades the log: `sim` needs `TEST PASSED` and zero
`UVM_ERROR` / `UVM_FATAL`, and `negative` is expected to exit nonzero. `make uvm-negative` at the top
level succeeds only when that rejection happens.

## 6. Make shortcuts and the one-command check

```bash
make help        # list every target
make py          # basic Python script
make verilog     # basic Verilog counter
make lint sim    # SystemVerilog hello: lint, build, run
make mutant      # mutation on a copy; must be rejected
make uvm-fetch uvm-sim uvm-negative
make smoke       # same as ./scripts/smoke.sh
```

The Makefile uses `igny run` when `igny` is on your PATH. Use `make RUN= sim` for plain PATH tools,
or `make RUN="igny run --env trainer" sim` to pick an environment. `make clean` removes `build/` only.

Or run the checks directly:

```bash
./scripts/smoke.sh
```

Uses `igny run` when `igny` is on your PATH (override with `RUN= ./scripts/smoke.sh` for plain PATH tools).
It checks lint, the correct design, a mutant that must be rejected, and, if you fetched UVM, the UVM
hello and its negative control. It never edits `rtl/`. Exit status is 0 only when every check passes.

## Known limits

- The UVM revision was validated with Crucible's Verilator 5.047. A distro Verilator 5.032 fails to
  elaborate it (`PKGNODECL`). Use the Verilator that `igny` provides for UVM.
- `fetch-uvm.sh` needs internet access to GitHub. Run it before the session.
- `verible-verilog-lint`, `gtkwave` and `iverilog` come from `igny tool install`.
- Tool versions and catalog availability depend on the `igny` release you have installed.

## Layout

```text
Makefile              shortcuts: py, verilog, lint, sim, wave, mutant, uvm-*, smoke, clean
python/hello.py       basic Python script
rtl/counter.v         basic Verilog-2001 counter
tb/counter_tb.v       self-checking testbench for the counter
rtl/hello.sv          2-input AND gate (SystemVerilog)
tb/tb.sv              self-checking timed testbench for the AND gate
uvm_hello/            UVM test, Makefile with build / sim / negative
scripts/              preflight.sh, smoke.sh, fetch-uvm.sh, install-verilator-toml.sh
build/, third_party/  generated or fetched, git-ignored
```

Teaching fixtures authored for this onboarding. They are not a product design and make no signoff claim.
