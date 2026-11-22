// ===============================================================================
// Ignytion IO - TRAINER LAB
// Copyright (c) 2026 Ignytion IO. All rights reserved.
// Author      : IGNYTION_TECH
// File        : trainer-lab/uvm_hello/tb.sv
// Created     : 2026-11-20
// Description : UVM test for hello using the Verilator-compatible Accellera UVM library.
// ===============================================================================
`timescale 1ns/1ps
`include "uvm_macros.svh"

interface hello_if;
  logic a;
  logic b;
  logic y;
endinterface

module tb;
  import uvm_pkg::*;
  hello_if bus();
  hello dut (.a_i(bus.a), .b_i(bus.b), .y_o(bus.y));

  class hello_test extends uvm_test;
    `uvm_component_utils(hello_test)
    virtual hello_if vif;
    int checks = 0;

    function new(string name = "hello_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual hello_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "Missing DUT interface")
    endfunction

    task run_phase(uvm_phase phase);
      bit expected;
      phase.raise_objection(this);
      for (int i = 0; i < 4; i++) begin
        vif.a = (i >> 1) & 1;
        vif.b = i & 1;
        #1ns;
        expected = vif.a & vif.b;
        if ($test$plusargs("INJECT_FAILURE") && i == 3)
          expected = ~expected;
        if (vif.y !== expected)
          `uvm_fatal("MISMATCH", $sformatf("a=%b b=%b y=%b expected=%b",
                                        vif.a, vif.b, vif.y, expected))
        checks++;
      end
      phase.drop_objection(this);
    endtask

    function void report_phase(uvm_phase phase);
      uvm_report_server server;
      super.report_phase(phase);
      server = uvm_report_server::get_server();
      if (checks != 4 || server.get_severity_count(UVM_ERROR) != 0 ||
          server.get_severity_count(UVM_FATAL) != 0)
        `uvm_fatal("BADRESULT", "The DUT checks did not all succeed")
      `uvm_info("LAB", "TEST PASSED: all 4 AND-gate input combinations checked", UVM_LOW)
    endfunction
  endclass

  initial begin
    uvm_config_db#(virtual hello_if)::set(null, "uvm_test_top", "vif", bus);
    run_test("hello_test");
  end
endmodule
