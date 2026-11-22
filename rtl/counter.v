// ===============================================================================
// Ignytion IO - TRAINER LAB
// Copyright (c) 2026 Ignytion IO. All rights reserved.
// Author      : IGNYTION_TECH
// File        : trainer-lab/rtl/counter.v
// Created     : 2026-11-22
// Description : Basic Verilog-2001 example: 4-bit counter with synchronous reset.
// ===============================================================================
`timescale 1ns/1ps
module counter (
  input  wire       clk,
  input  wire       rst,
  output reg  [3:0] q
);
  always @(posedge clk) begin
    if (rst) q <= 4'd0;
    else     q <= q + 4'd1;
  end
endmodule
