`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:  multiplier
// Description:  16x16 unsigned registered multiplier.
//               Vivado infers a DSP48E1 slice from this description.
//               Replaces the Spartan-6 ISE netlist (multiplier.ngc).
//////////////////////////////////////////////////////////////////////////////////

module multiplier (
    input  wire        clk,
    input  wire [15:0] a,
    input  wire [15:0] b,
    output reg  [31:0] p
);
    always @(posedge clk) p <= a * b;
endmodule
