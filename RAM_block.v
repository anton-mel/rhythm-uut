`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      Intan Technologies, LLC
//
// Design Name:  RHD2000 Rhythm Interface
// Module Name:  RAM_1024x16bit
// Description:  Dual-port 1024 x 16-bit block RAM for storing MOSI commands.
//               Port A: read/write (USB/host clock domain).
//               Port B: read-only (RHD2000 SPI clock domain).
//
//               Xilinx 7-series RAMB18E1 (replaces Spartan-6 RAMB16BWER).
//////////////////////////////////////////////////////////////////////////////////

module RAM_1024x16bit(
    input  wire        clk_A,
    input  wire        clk_B,
    input  wire [9:0]  RAM_addr_A,
    input  wire [9:0]  RAM_addr_B,
    input  wire [15:0] RAM_data_in,
    output wire [15:0] RAM_data_out_A,
    output wire [15:0] RAM_data_out_B,
    input  wire        RAM_we,
    input  wire        reset
);

    wire [15:0] DOA, DOB;

    assign RAM_data_out_A = DOA;
    assign RAM_data_out_B = DOB;

    RAMB18E1 #(
        .RAM_MODE          ("TDP"),
        .DATA_WIDTH_A      (18),
        .DATA_WIDTH_B      (18),
        .DOA_REG           (0),
        .DOB_REG           (0),
        .INIT_A            (18'h0),
        .INIT_B            (18'h0),
        .SRVAL_A           (18'h0),
        .SRVAL_B           (18'h0),
        .WRITE_MODE_A      ("WRITE_FIRST"),
        .WRITE_MODE_B      ("WRITE_FIRST"),
        .SIM_COLLISION_CHECK("ALL"),
        .RDADDR_COLLISION_HWCONFIG("DELAYED_WRITE"),
        // Init contents all zero
        .INIT_00(256'h0), .INIT_01(256'h0), .INIT_02(256'h0), .INIT_03(256'h0),
        .INIT_04(256'h0), .INIT_05(256'h0), .INIT_06(256'h0), .INIT_07(256'h0),
        .INIT_08(256'h0), .INIT_09(256'h0), .INIT_0A(256'h0), .INIT_0B(256'h0),
        .INIT_0C(256'h0), .INIT_0D(256'h0), .INIT_0E(256'h0), .INIT_0F(256'h0),
        .INIT_10(256'h0), .INIT_11(256'h0), .INIT_12(256'h0), .INIT_13(256'h0),
        .INIT_14(256'h0), .INIT_15(256'h0), .INIT_16(256'h0), .INIT_17(256'h0),
        .INIT_18(256'h0), .INIT_19(256'h0), .INIT_1A(256'h0), .INIT_1B(256'h0),
        .INIT_1C(256'h0), .INIT_1D(256'h0), .INIT_1E(256'h0), .INIT_1F(256'h0),
        .INIT_20(256'h0), .INIT_21(256'h0), .INIT_22(256'h0), .INIT_23(256'h0),
        .INIT_24(256'h0), .INIT_25(256'h0), .INIT_26(256'h0), .INIT_27(256'h0),
        .INIT_28(256'h0), .INIT_29(256'h0), .INIT_2A(256'h0), .INIT_2B(256'h0),
        .INIT_2C(256'h0), .INIT_2D(256'h0), .INIT_2E(256'h0), .INIT_2F(256'h0),
        .INIT_30(256'h0), .INIT_31(256'h0), .INIT_32(256'h0), .INIT_33(256'h0),
        .INIT_34(256'h0), .INIT_35(256'h0), .INIT_36(256'h0), .INIT_37(256'h0),
        .INIT_38(256'h0), .INIT_39(256'h0), .INIT_3A(256'h0), .INIT_3B(256'h0),
        .INIT_3C(256'h0), .INIT_3D(256'h0), .INIT_3E(256'h0), .INIT_3F(256'h0),
        .INITP_00(256'h0), .INITP_01(256'h0), .INITP_02(256'h0), .INITP_03(256'h0),
        .INITP_04(256'h0), .INITP_05(256'h0), .INITP_06(256'h0), .INITP_07(256'h0)
    )
    RAMB18E1_inst (
        // Port A (read/write)
        .CLKARDCLK  (clk_A),
        .ENARDEN    (1'b1),
        .RSTRAMARSTRAM(1'b0),
        .RSTREGARSTREG(1'b0),
        .REGCEAREGCE(1'b1),
        .WEA        ({RAM_we, RAM_we}),   // 2-bit byte-write enable
        .ADDRA      ({RAM_addr_A, 4'b0000}),
        .DIA        (RAM_data_in),
        .DIPA       (2'b0),
        .DOA        (DOA),
        .DOPA       (),
        // Port B (read-only)
        .CLKBWRCLK  (clk_B),
        .ENBWREN    (1'b1),
        .RSTRAMB    (1'b0),
        .RSTREGB    (1'b0),
        .REGCEB     (1'b1),
        .WEBWE      (4'b0),
        .ADDRB      ({RAM_addr_B, 4'b0000}),
        .DIB        (16'b0),
        .DIPB       (2'b0),
        .DOB        (DOB),
        .DOPB       ()
    );

endmodule
