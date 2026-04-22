`timescale 1ns/1ps

// Behavioral stubs for Xilinx 7-series and Spartan-6 primitives used in simulation.
// These replace hardware-specific netlists that cannot be compiled by Icarus Verilog.

// ---------------------------------------------------------------------------
// BUFG: global clock buffer — simple pass-through
// ---------------------------------------------------------------------------
module BUFG (output O, input I);
    assign O = I;
endmodule

// ---------------------------------------------------------------------------
// OBUFDS: differential output buffer
// ---------------------------------------------------------------------------
module OBUFDS (output O, output OB, input I);
    assign O  =  I;
    assign OB = ~I;
endmodule

// ---------------------------------------------------------------------------
// IBUFDS: differential input buffer
// ---------------------------------------------------------------------------
module IBUFDS (output O, input I, input IB);
    assign O = I;
endmodule

// ---------------------------------------------------------------------------
// MMCME2_BASE: Artix-7 MMCM — generates clkout at the correct frequency
// Only CLKOUT0 is modeled; all other outputs remain undriven.
// Parameters are ignored at elaboration; period is computed from CLKIN1_PERIOD,
// CLKFBOUT_MULT_F, DIVCLK_DIVIDE, and CLKOUT0_DIVIDE_F using real arithmetic.
// ---------------------------------------------------------------------------
module MMCME2_BASE #(
    parameter real CLKIN1_PERIOD      = 10.0,
    parameter real CLKFBOUT_MULT_F    = 5.0,
    parameter integer DIVCLK_DIVIDE   = 1,
    parameter real CLKOUT0_DIVIDE_F   = 1.0,
    parameter real CLKOUT0_DUTY_CYCLE = 0.5,
    parameter real CLKOUT0_PHASE      = 0.0,
    parameter real CLKFBOUT_PHASE     = 0.0,
    parameter      BANDWIDTH          = "OPTIMIZED",
    parameter      CLKOUT4_CASCADE    = "FALSE",
    parameter      STARTUP_WAIT       = "FALSE",
    parameter real REF_JITTER1        = 0.01
)(
    input  CLKIN1,
    input  CLKFBIN,
    input  RST,
    input  PWRDWN,
    output CLKOUT0,
    output CLKOUT0B,
    output CLKOUT1,  output CLKOUT1B,
    output CLKOUT2,  output CLKOUT2B,
    output CLKOUT3,  output CLKOUT3B,
    output CLKOUT4,
    output CLKOUT5,
    output CLKOUT6,
    output CLKFBOUT,
    output CLKFBOUTB,
    output LOCKED
);
    // Output period in ns
    localparam real OUT_PERIOD = CLKIN1_PERIOD * DIVCLK_DIVIDE * CLKOUT0_DIVIDE_F / CLKFBOUT_MULT_F;

    reg clkout_r = 0;
    reg locked_r = 0;

    // Simulate lock after 100 ns
    initial begin
        locked_r = 0;
        #100;
        locked_r = 1;
    end

    // Generate clock when not in reset and locked
    always begin
        #(OUT_PERIOD / 2.0);
        if (!RST && locked_r)
            clkout_r = ~clkout_r;
        else
            clkout_r = 0;
    end

    assign CLKOUT0   = clkout_r;
    assign CLKOUT0B  = ~clkout_r;
    assign CLKFBOUT  = clkout_r;
    assign CLKFBOUTB = ~clkout_r;
    assign LOCKED    = locked_r;

    // Unused outputs
    assign CLKOUT1  = 0; assign CLKOUT1B = 0;
    assign CLKOUT2  = 0; assign CLKOUT2B = 0;
    assign CLKOUT3  = 0; assign CLKOUT3B = 0;
    assign CLKOUT4  = 0;
    assign CLKOUT5  = 0;
    assign CLKOUT6  = 0;
endmodule

// ---------------------------------------------------------------------------
// RAMB16BWER: Spartan-6 16k-bit dual-port block RAM behavioral model
// Only the 18-bit data width mode (DATA_WIDTH_A/B = 18) is modeled here,
// matching the usage in RAM_block.v:
//   Port A: 10-bit addr (ADDRA[13:4]), 16-bit data write, WEA[1:0] active
//   Port B: 10-bit addr (ADDRB[13:4]), 16-bit data read-only
// ---------------------------------------------------------------------------
module RAMB16BWER #(
    parameter DATA_WIDTH_A        = 18,
    parameter DATA_WIDTH_B        = 18,
    parameter DOA_REG             = 0,
    parameter DOB_REG             = 0,
    parameter EN_RSTRAM_A         = "TRUE",
    parameter EN_RSTRAM_B         = "TRUE",
    parameter INITP_00 = 256'h0, parameter INITP_01 = 256'h0,
    parameter INITP_02 = 256'h0, parameter INITP_03 = 256'h0,
    parameter INITP_04 = 256'h0, parameter INITP_05 = 256'h0,
    parameter INITP_06 = 256'h0, parameter INITP_07 = 256'h0,
    parameter INIT_00  = 256'h0, parameter INIT_01  = 256'h0,
    parameter INIT_02  = 256'h0, parameter INIT_03  = 256'h0,
    parameter INIT_04  = 256'h0, parameter INIT_05  = 256'h0,
    parameter INIT_06  = 256'h0, parameter INIT_07  = 256'h0,
    parameter INIT_08  = 256'h0, parameter INIT_09  = 256'h0,
    parameter INIT_0A  = 256'h0, parameter INIT_0B  = 256'h0,
    parameter INIT_0C  = 256'h0, parameter INIT_0D  = 256'h0,
    parameter INIT_0E  = 256'h0, parameter INIT_0F  = 256'h0,
    parameter INIT_10  = 256'h0, parameter INIT_11  = 256'h0,
    parameter INIT_12  = 256'h0, parameter INIT_13  = 256'h0,
    parameter INIT_14  = 256'h0, parameter INIT_15  = 256'h0,
    parameter INIT_16  = 256'h0, parameter INIT_17  = 256'h0,
    parameter INIT_18  = 256'h0, parameter INIT_19  = 256'h0,
    parameter INIT_1A  = 256'h0, parameter INIT_1B  = 256'h0,
    parameter INIT_1C  = 256'h0, parameter INIT_1D  = 256'h0,
    parameter INIT_1E  = 256'h0, parameter INIT_1F  = 256'h0,
    parameter INIT_20  = 256'h0, parameter INIT_21  = 256'h0,
    parameter INIT_22  = 256'h0, parameter INIT_23  = 256'h0,
    parameter INIT_24  = 256'h0, parameter INIT_25  = 256'h0,
    parameter INIT_26  = 256'h0, parameter INIT_27  = 256'h0,
    parameter INIT_28  = 256'h0, parameter INIT_29  = 256'h0,
    parameter INIT_2A  = 256'h0, parameter INIT_2B  = 256'h0,
    parameter INIT_2C  = 256'h0, parameter INIT_2D  = 256'h0,
    parameter INIT_2E  = 256'h0, parameter INIT_2F  = 256'h0,
    parameter INIT_30  = 256'h0, parameter INIT_31  = 256'h0,
    parameter INIT_32  = 256'h0, parameter INIT_33  = 256'h0,
    parameter INIT_34  = 256'h0, parameter INIT_35  = 256'h0,
    parameter INIT_36  = 256'h0, parameter INIT_37  = 256'h0,
    parameter INIT_38  = 256'h0, parameter INIT_39  = 256'h0,
    parameter INIT_3A  = 256'h0, parameter INIT_3B  = 256'h0,
    parameter INIT_3C  = 256'h0, parameter INIT_3D  = 256'h0,
    parameter INIT_3E  = 256'h0, parameter INIT_3F  = 256'h0,
    parameter INIT_A          = 36'h0,
    parameter INIT_B          = 36'h0,
    parameter INIT_FILE       = "NONE",
    parameter RSTTYPE         = "SYNC",
    parameter RST_PRIORITY_A  = "CE",
    parameter RST_PRIORITY_B  = "CE",
    parameter SIM_COLLISION_CHECK = "ALL",
    parameter SIM_DEVICE      = "SPARTAN6",
    parameter SRVAL_A         = 36'h0,
    parameter SRVAL_B         = 36'h0,
    parameter WRITE_MODE_A    = "WRITE_FIRST",
    parameter WRITE_MODE_B    = "WRITE_FIRST"
)(
    // Port A
    output reg [31:0] DOA,
    output     [ 3:0] DOPA,
    input      [13:0] ADDRA,
    input             CLKA,
    input             ENA,
    input             REGCEA,
    input             RSTA,
    input      [ 3:0] WEA,
    input      [31:0] DIA,
    input      [ 3:0] DIPA,
    // Port B
    output reg [31:0] DOB,
    output     [ 3:0] DOPB,
    input      [13:0] ADDRB,
    input             CLKB,
    input             ENB,
    input             REGCEB,
    input             RSTB,
    input      [ 3:0] WEB,
    input      [31:0] DIB,
    input      [ 3:0] DIPB
);
    // 1024 x 16-bit memory (modeled as 1024 x 32-bit, lower 16 bits used)
    reg [15:0] mem [0:1023];
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) mem[i] = 16'h0;
    end

    wire [9:0] addr_a = ADDRA[13:4];
    wire [9:0] addr_b = ADDRB[13:4];

    // Port A: read/write
    always @(posedge CLKA) begin
        if (RSTA) begin
            DOA <= 32'b0;
        end else if (ENA) begin
            if (WEA[1] | WEA[0])
                mem[addr_a] <= DIA[15:0];
            DOA <= {16'b0, mem[addr_a]};
        end
    end

    // Port B: read-only
    always @(posedge CLKB) begin
        if (RSTB)
            DOB <= 32'b0;
        else if (ENB)
            DOB <= {16'b0, mem[addr_b]};
    end

    assign DOPA = 4'b0;
    assign DOPB = 4'b0;
endmodule

// ---------------------------------------------------------------------------
// multiplier: 16x16 clocked unsigned multiplier with 32-bit output
// ---------------------------------------------------------------------------
module multiplier (
    input         clk,
    input  [15:0] a,
    input  [15:0] b,
    output [31:0] p
);
    reg [31:0] p_r;
    always @(posedge clk) p_r <= a * b;
    assign p = p_r;
endmodule

// ---------------------------------------------------------------------------
// multiplier_18x18: 18x18 clocked signed multiplier with 36-bit output
// ---------------------------------------------------------------------------
module multiplier_18x18 (
    input         clk,
    input  [17:0] a,
    input  [17:0] b,
    output [35:0] p
);
    reg [35:0] p_r;
    always @(posedge clk) p_r <= $signed(a) * $signed(b);
    assign p = p_r;
endmodule
