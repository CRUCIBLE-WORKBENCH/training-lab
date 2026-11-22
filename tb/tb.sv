// ===============================================================================
// Ignytion IO - TRAINER LAB
// Copyright (c) 2026 Ignytion IO. All rights reserved.
// Author      : IGNYTION_TECH
// File        : trainer-lab/tb/tb.sv
// Created     : 2026-11-20
// Description : Self-checking timed testbench for hello (slide 12).
// ===============================================================================
`timescale 1ns/1ps
module tb;
  logic a, b, y;
  hello dut (.a_i(a), .b_i(b), .y_o(y));
  initial begin
    $dumpfile("hello.vcd"); $dumpvars(0, tb);
    for (int i = 0; i < 4; i++) begin
      {a, b} = 2'(i); #1;
      if (y !== (a & b)) $fatal(1, "Mismatch");
    end
    $display("PASS: 4 input combinations");
    $finish;
  end
endmodule
