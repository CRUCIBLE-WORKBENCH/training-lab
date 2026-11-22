# ===============================================================================
# Ignytion IO - TRAINER LAB
# Copyright (c) 2026 Ignytion IO. All rights reserved.
# Author      : IGNYTION_TECH
# File        : trainer-lab/uvm_hello/Makefile
# Created     : 2026-11-20
# Description : Build, sim and negative targets for UVM hello on Verilator, with log grading.
# ===============================================================================
# UVM hello on Verilator. Targets: build, sim, negative.
# UVM_HOME defaults to the library fetched by scripts/fetch-uvm.sh.
#
# UVM ends a run with $finish even after UVM_FATAL, so the simulator's exit
# status stays 0. Both run targets therefore grade the log as well:
#   sim      passes only with "TEST PASSED" and zero UVM_ERROR / UVM_FATAL.
#   negative injects a mismatch and is EXPECTED to fail (exit 1).
VERILATOR ?= verilator
UVM_HOME  ?= $(abspath ../third_party/uvm)
BUILD_DIR ?= $(abspath ../build/uvm_hello)
JOBS      ?= 2

# $(1) = extra plusargs for the simulation binary
define RUN_AND_GRADE
	@$(BUILD_DIR)/Vtb $(1) > $(BUILD_DIR)/run.log 2>&1; rc=$$?; cat $(BUILD_DIR)/run.log; \
	if [ $$rc -ne 0 ]; then echo "GRADE: simulator exit status $$rc"; exit $$rc; fi; \
	if grep -Eq 'UVM_(ERROR|FATAL) *: *[1-9]' $(BUILD_DIR)/run.log; then \
	  echo "GRADE: FAIL, UVM_ERROR or UVM_FATAL reported"; exit 1; fi; \
	if ! grep -q 'TEST PASSED' $(BUILD_DIR)/run.log; then \
	  echo "GRADE: FAIL, no TEST PASSED line"; exit 1; fi; \
	echo "GRADE: PASS"
endef

.PHONY: sim build negative
sim: build
	$(call RUN_AND_GRADE,)

build: $(BUILD_DIR)/Vtb

$(BUILD_DIR)/Vtb: tb.sv ../rtl/hello.sv $(UVM_HOME)/src/uvm_pkg.sv
	mkdir -p $(BUILD_DIR)
	$(VERILATOR) --binary --timing --assert -Wno-fatal -j $(JOBS) \
	  +define+UVM_NO_DPI +incdir+$(UVM_HOME)/src \
	  $(UVM_HOME)/src/uvm_pkg.sv ../rtl/hello.sv tb.sv \
	  --top-module tb --Mdir $(BUILD_DIR)

negative: build
	$(call RUN_AND_GRADE,+INJECT_FAILURE)
