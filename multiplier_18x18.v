`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:  multiplier_18x18
// Description:  18x18 signed registered multiplier.
//               Vivado infers a DSP48E1 slice from this description.
//               Replaces the Spartan-6 ISE netlist (multiplier_18x18.ngc).
//////////////////////////////////////////////////////////////////////////////////

module multiplier_18x18 (
    input  wire        clk,
    input  wire [17:0] a,
    input  wire [17:0] b,
    output reg  [35:0] p
);
    always @(posedge clk) p <= $signed(a) * $signed(b);
endmodule
