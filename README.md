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
Clone it, run the preflight, and you can type along with each slide.

## 1. Before the session (10 minutes)

Use a Linux shell: native Ubuntu 22.04/24.04, or the WSL setup provided for the workshop.
Clone under your **Linux home**, not under `/mnt/c`, so builds are fast.

```bash
git clone <REPO_URL> ~/trainer-lab
cd ~/trainer-lab
./scripts/preflight.sh
```

`preflight.sh` only reports: where you are, memory, display forwarding (GTKWave and KLayout need it),
the `igny` version, and which tools are reachable. Send a screenshot of anything marked `missing`
or `WARNING` before the session.

## 2. Follow along with the slides

| Slides | What you do | Where it lives |
|---|---|---|
| 4–6 | Concepts, `igny --version`, `igny doctor`, `igny status` | nothing to clone |
| 7 | Create the environment and workspace | see "Workspace" below |
| 8–10 | `igny tool install ...`, inspect bindings, `igny run` | nothing to clone |
| 11–12 | The RTL fixture and self-checking testbench | `rtl/hello.sv`, `tb/tb.sv` |
| 13–14 | Lint, build, simulate, view the waveform, mutate | commands below |
| 16 | UVM hello on Verilator | `uvm_hello/`, `scripts/fetch-uvm.sh` |

Slides 15 and 17–38 (coverage, firmware, synthesis, timing, physical design, handoff gates) rely on
files the sponsor's starter project supplies, such as `fw/main.c`, `pnr/synth.ys` and the lab Make
targets. They are **not in this repository**. We will rehearse those together once that project is chosen.

### Workspace (slide 7)

Slide 7 creates a new workspace folder. If you cloned this repo instead, make the clone the workspace.
The names below are examples; any names work if you use them consistently:

```bash
igny env create trainer             # once; skip if it already exists
cd ~/trainer-lab
igny workspace create trainer-lab --env trainer
igny workspace show
```

If `igny` refuses because the folder is not empty, say so in the session. Do not force it.
The repo ships no `crucible.toml` or `crucible.lock`; each trainer creates their own.

### Frontend lab (slides 11–14)

```bash
mkdir -p build
igny run verilator --lint-only -Wall rtl/hello.sv
igny run verible-verilog-lint rtl/hello.sv
igny run verilator --binary --timing --trace \
  --assert --top-module tb --Mdir build/hello \
  rtl/hello.sv tb/tb.sv
(cd build && ./hello/Vtb)           # expect: PASS: 4 input combinations
echo $?                             # expect: 0
```

The testbench dumps `hello.vcd` into the directory you run it from, so `igny run gtkwave build/hello.vcd`
opens it. For the mutation exercise, change `a_i & b_i` to `a_i | b_i` in `rtl/hello.sv`, rebuild, rerun,
and require a nonzero exit plus a `Mismatch`. Restore the file afterwards (`git checkout rtl/hello.sv`).

### UVM hello (slide 16)

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

## 3. Make shortcuts and the one-command check

```bash
make help        # list every target
make lint sim    # slides 13 (lint, build, run)
make mutant      # slide 14 mutation on a copy; must be rejected
make uvm-fetch uvm-sim uvm-negative   # slide 16
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
  elaborate it (`PKGNODECL`). Use the Verilator that `igny` provides for slide 16.
- `fetch-uvm.sh` needs internet access to GitHub. Run it before the session.
- `verible-verilog-lint`, `gtkwave` and `iverilog` come from `igny tool install` (slide 8).
- Tool versions and catalog availability depend on the `igny` release you have installed.

## Layout

```text
Makefile            shortcuts: lint, sim, wave, mutant, uvm-*, smoke, clean
rtl/hello.sv        2-input AND gate (slide 11)
tb/tb.sv            self-checking timed testbench (slide 12)
uvm_hello/          UVM test, Makefile with build / sim / negative (slide 16)
scripts/            preflight.sh, smoke.sh, fetch-uvm.sh
build/, third_party/   generated or fetched, git-ignored
```

Teaching fixtures authored for this onboarding. They are not a product design and make no signoff claim.
