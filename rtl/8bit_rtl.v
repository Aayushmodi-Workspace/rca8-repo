//==============================================================================
// File        : 8bit_rtl.v
// Design      : rca8 - 8-bit Registered Ripple Carry Adder
// Author      : [Author]
// Description : Behavioral 1-bit full adder, structurally chained eight deep
//               to form an 8-bit ripple-carry adder with registered I/O.
//               Written for a synthesis/PnR teaching exercise, not for a
//               timing-critical datapath - see docs/cell-tradeoff-study.md
//               for why the ripple topology is the dominant limiter here,
//               not the standard-cell library.
//
// Notes       : - `assign {Cout, Sum} = A + B + Cin` is deliberate: it lets
//                 DC pick the full-adder implementation (FADD macro,
//                 discrete AOI/OAI gates, whatever the library and
//                 set_dont_use list allow) instead of pinning it to a
//                 specific gate-level structure. Fine for an 8-bit block;
//                 wouldn't reach for this on anything where I needed to
//                 guarantee a particular carry structure went in.
//               - Inputs are registered at the module boundary and the
//                 carry chain is combinational between those register
//                 banks - one clock's worth of ripple-carry delay per
//                 operation, which is exactly what shows up as the
//                 critical path in STA.
//==============================================================================

`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// fa: 1-bit full adder. Purely combinational, no internal state.
// -----------------------------------------------------------------------------
module fa (
    input  wire A,
    input  wire B,
    input  wire Cin,
    output wire Sum,
    output wire Cout
);
  assign {Cout, Sum} = A + B + Cin;
endmodule

// -----------------------------------------------------------------------------
// rca8: 8-bit ripple-carry adder, registered inputs and outputs.
//
//   Clock, Reset -> synchronous datapath, active-high async reset
//   A, B[7:0]    -> operands, registered on entry
//   Cin          -> carry-in, registered on entry
//   Sum[7:0]     -> registered sum output
//   Cout         -> registered carry-out (carry[7])
// -----------------------------------------------------------------------------
module rca8 (
    input  wire       Clock,
    input  wire       Reset,
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire       Cin,
    output reg  [7:0] Sum,
    output reg         Cout
);

  // Registered operands - this is the register stage the carry chain
  // ripples out of on the following combinational pass.
  reg [7:0] A_reg, B_reg;
  reg       Cin_reg;

  // Full-adder interconnect
  wire [7:0] sum_wire;
  wire [7:0] carry;

  // Eight 1-bit full adders, ripple-carry chained. carry[7] is the
  // block carry-out; this chain is the entire combinational critical
  // path of the design (see 8bit.sdc / cell-tradeoff-study.md).
  fa FA0 (A_reg[0], B_reg[0], Cin_reg,  sum_wire[0], carry[0]);
  fa FA1 (A_reg[1], B_reg[1], carry[0], sum_wire[1], carry[1]);
  fa FA2 (A_reg[2], B_reg[2], carry[1], sum_wire[2], carry[2]);
  fa FA3 (A_reg[3], B_reg[3], carry[2], sum_wire[3], carry[3]);
  fa FA4 (A_reg[4], B_reg[4], carry[3], sum_wire[4], carry[4]);
  fa FA5 (A_reg[5], B_reg[5], carry[4], sum_wire[5], carry[5]);
  fa FA6 (A_reg[6], B_reg[6], carry[5], sum_wire[6], carry[6]);
  fa FA7 (A_reg[7], B_reg[7], carry[6], sum_wire[7], carry[7]);

  // Synchronous register stage: capture operands on entry, capture the
  // adder result on the following edge. Async, active-high reset.
  always @(posedge Clock or posedge Reset) begin
    if (Reset) begin
      A_reg   <= 8'b0;
      B_reg   <= 8'b0;
      Cin_reg <= 1'b0;
      Sum     <= 8'b0;
      Cout    <= 1'b0;
    end else begin
      A_reg   <= A;
      B_reg   <= B;
      Cin_reg <= Cin;
      Sum     <= sum_wire;
      Cout    <= carry[7];
    end
  end

endmodule
