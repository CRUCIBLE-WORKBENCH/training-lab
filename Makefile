# ===============================================================================
# Ignytion IO - TRAINER LAB
# Copyright (c) 2026 Ignytion IO. All rights reserved.
# Author      : IGNYTION_TECH
# File        : trainer-lab/Makefile
# Created     : 2026-11-20
# Description : Top-level lab shortcuts: lint, sim, mutant, UVM and smoke targets.
# ===============================================================================
# Trainer lab: shortcuts for slides 11-16. Run `make help`.
#
# Tools run through `igny run` when igny is on PATH. Override with RUN= to use
# plain PATH tools, or RUN="igny run --env trainer" to pick an environment.
RUN      ?= $(if $(shell command -v igny 2>/dev/null),igny run,)
JOBS     ?= 2
BUILD    := build
SIM_ARGS := --binary --timing --trace --assert --top-module tb

.DEFAULT_GOAL := help
.PHONY: help preflight lint build sim wave mutant uvm-fetch uvm-build uvm-sim uvm-negative smoke clean distclean

help:
	@echo "Frontend lab (slides 11-14)"
	@echo "  make lint          Verilator -Wall lint of rtl/hello.sv"
	@echo "  make sim           build and run the self-checking testbench"
	@echo "  make wave          open build/hello.vcd in GTKWave (needs display)"
	@echo "  make mutant        rebuild with a|b on a COPY; must be rejected"
	@echo "UVM hello (slide 16)"
	@echo "  make uvm-fetch     fetch the pinned UVM library into third_party/"
	@echo "  make uvm-sim       build and run UVM hello"
	@echo "  make uvm-negative  injected failure; succeeds only if it is rejected"
	@echo "Checks and cleanup"
	@echo "  make preflight     report machine and tool readiness (read-only)"
	@echo "  make smoke         run every check above in one go"
	@echo "  make clean         remove build/    (distclean also removes third_party/)"
	@echo "Tool runner: '$(RUN)' (empty means plain PATH tools)"

preflight:
	./scripts/preflight.sh

lint:
	$(RUN) verilator --lint-only -Wall rtl/hello.sv

$(BUILD)/hello/Vtb: rtl/hello.sv tb/tb.sv
	mkdir -p $(BUILD)
	$(RUN) verilator $(SIM_ARGS) --Mdir $(BUILD)/hello rtl/hello.sv tb/tb.sv

build: $(BUILD)/hello/Vtb

# Runs inside build/ so hello.vcd lands at build/hello.vcd.
sim: build
	cd $(BUILD) && ./hello/Vtb

wave: sim
	$(RUN) gtkwave $(BUILD)/hello.vcd

# The mutation never touches rtl/. A mutant that passes is a failed exercise.
mutant:
	mkdir -p $(BUILD)/mutant_src
	sed 's/a_i & b_i/a_i | b_i/' rtl/hello.sv > $(BUILD)/mutant_src/hello.sv
	$(RUN) verilator $(SIM_ARGS) --Mdir $(BUILD)/mutant $(BUILD)/mutant_src/hello.sv tb/tb.sv
	@if (cd $(BUILD) && ./mutant/Vtb); then \
	  echo "FAIL: the mutant passed; the testbench missed the fault"; exit 1; \
	else echo "OK: the mutant was rejected (nonzero exit)"; fi

uvm-fetch:
	./scripts/fetch-uvm.sh

uvm-build:
	$(RUN) $(MAKE) -C uvm_hello build JOBS=$(JOBS)

uvm-sim:
	$(RUN) $(MAKE) -C uvm_hello sim JOBS=$(JOBS)

uvm-negative: uvm-build
	@if $(RUN) $(MAKE) -C uvm_hello negative; then \
	  echo "FAIL: the injected failure was not rejected"; exit 1; \
	else echo "OK: the injected failure was rejected"; fi

smoke:
	./scripts/smoke.sh

clean:
	rm -rf $(BUILD)

distclean: clean
	rm -rf third_party
