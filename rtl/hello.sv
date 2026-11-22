// ===============================================================================
// Ignytion IO - TRAINER LAB
// Copyright (c) 2026 Ignytion IO. All rights reserved.
// Author      : IGNYTION_TECH
// File        : trainer-lab/rtl/hello.sv
// Created     : 2026-11-20
// Description : 2-input AND gate used as the first lint and simulation fixture.
// ===============================================================================
`timescale 1ns/1ps
module hello (
  input  logic a_i,
  input  logic b_i,
  output logic y_o
);
  assign y_o = a_i & b_i;
endmodule
