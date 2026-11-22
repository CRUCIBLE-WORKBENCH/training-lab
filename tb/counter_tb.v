// ===============================================================================
// Ignytion IO - TRAINER LAB
// Copyright (c) 2026 Ignytion IO. All rights reserved.
// Author      : IGNYTION_TECH
// File        : trainer-lab/tb/counter_tb.v
// Created     : 2026-11-22
// Description : Self-checking Verilog-2001 testbench for counter (wraps 15 to 0).
// ===============================================================================
`timescale 1ns/1ps
module counter_tb;
  reg        clk = 1'b0;
  reg        rst = 1'b1;
  wire [3:0] q;
  reg  [3:0] expected;
  integer    cycle;

  counter dut (.clk(clk), .rst(rst), .q(q));

  always #5 clk = ~clk;

  initial begin
    $dumpfile("counter.vcd");
    $dumpvars(0, counter_tb);
    expected = 4'd0;
    repeat (2) @(posedge clk);   // hold reset for two clock edges
    #1 rst = 1'b0;
    for (cycle = 1; cycle <= 20; cycle = cycle + 1) begin
      @(posedge clk);
      expected = expected + 4'd1;   // 4-bit, so 15 + 1 wraps to 0
      #1;
      if (q !== expected) begin
        $display("FAIL: cycle %0d q=%0d expected=%0d", cycle, q, expected);
        $stop;
      end
    end
    $display("PASS: counted 20 cycles, wrap included");
    $finish;
  end
endmodule
