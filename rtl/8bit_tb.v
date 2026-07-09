//==============================================================================
// File        : 8bit_tb.v
// Design      : rca8_tb - testbench for rca8
// Author      : [Author]
// Description : Directed test, ten vectors chosen to hit the corner cases
//               that matter for a ripple-carry adder: zero operands,
//               single-bit carry propagation, full-width carry propagation
//               (0xFF + 0x01, 0xFF + 0xFF), alternating bit patterns
//               (0x55/0xAA) to stress transition-heavy nets, and the
//               signed-overflow-adjacent case (0x7F + 0x01).
//
//               Not self-checking - results are eyeballed against $monitor
//               output and cross-checked in Verdi against the FSDB. For a
//               block this small a scoreboard/reference model is more
//               machinery than the DUT justifies; if this were folded into
//               a larger integration testbench I'd want a proper checker
//               against a behavioral model instead of manual inspection.
//==============================================================================

`timescale 1ns/1ps
`include "8bit_rtl.v"

module rca8_tb;

  reg Clock, Reset;
  reg [7:0] A, B;
  reg Cin;
  wire [7:0] Sum;
  wire Cout;

  // Instantiate DUT
  rca8 dut (
    .Clock (Clock),
    .Reset (Reset),
    .A     (A),
    .B     (B),
    .Cin   (Cin),
    .Sum   (Sum),
    .Cout  (Cout)
  );

  // Clock generation: 10 ns period, free-running from t=0
  initial Clock = 0;
  always #5 Clock = ~Clock;

  // Stimulus
  initial begin
    // FSDB dump for Verdi waveform debug
    $fsdbDumpfile("novas.fsdb");
    $fsdbDumpvars(0, rca8_tb);

    $display("Time\t\tA\tB\tCin\t=> Sum\tCout");
    $monitor("%0t\t%h\t%h\t%b\t=> %h\t%b", $time, A, B, Cin, Sum, Cout);

    // Hold reset through the first couple of clock edges before
    // releasing, so the initial register state is unambiguous in the
    // waveform rather than relying on X-propagation to flag it.
    Reset = 1; A = 0; B = 0; Cin = 0;
    #12 Reset = 0;

    // Directed vectors, applied on the clock edge:
    @(posedge Clock); A = 8'h00; B = 8'h00; Cin = 0; // all-zero
    @(posedge Clock); A = 8'h01; B = 8'h01; Cin = 0; // trivial add
    @(posedge Clock); A = 8'h0F; B = 8'h01; Cin = 0; // nibble-boundary carry
    @(posedge Clock); A = 8'h0F; B = 8'h01; Cin = 1; // same, with Cin
    @(posedge Clock); A = 8'h55; B = 8'hAA; Cin = 0; // alternating pattern, no carry
    @(posedge Clock); A = 8'hFF; B = 8'h01; Cin = 0; // full-width carry propagation
    @(posedge Clock); A = 8'hFF; B = 8'hFF; Cin = 1; // max operands + Cin
    @(posedge Clock); A = 8'hAA; B = 8'hAA; Cin = 0; // alternating pattern, repeat
    @(posedge Clock); A = 8'h55; B = 8'h55; Cin = 1; // alternating pattern, with Cin
    @(posedge Clock); A = 8'h80; B = 8'h80; Cin = 0; // MSB-only operands
    @(posedge Clock); A = 8'h7F; B = 8'h01; Cin = 1; // signed-overflow-adjacent case

    #20 $finish;
  end

endmodule
