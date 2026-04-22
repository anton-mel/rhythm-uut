`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:  top
// Description:  Synthesis top-level for Opal Kelly XEM7310 (XC7A200T).
//               Instantiates the RHD2000 DAQ core (main) and feeds its
//               electrode data stream into processor_sandbox.
//////////////////////////////////////////////////////////////////////////////////

module top (
    input  wire        clk1_in,   // 100 MHz system clock (XEM7310 pin)
    input  wire        reset,     // active-high reset

    output wire [7:0]  led,

    // --- Port A LVDS ---
    input  wire        MISO_A1_p, input  wire MISO_A1_n,
    input  wire        MISO_A2_p, input  wire MISO_A2_n,
    output wire        CS_b_A_p,  output wire CS_b_A_n,
    output wire        SCLK_A_p,  output wire SCLK_A_n,
    output wire        MOSI_A_p,  output wire MOSI_A_n,

    // --- Port B LVDS ---
    input  wire        MISO_B1_p, input  wire MISO_B1_n,
    input  wire        MISO_B2_p, input  wire MISO_B2_n,
    output wire        CS_b_B_p,  output wire CS_b_B_n,
    output wire        SCLK_B_p,  output wire SCLK_B_n,
    output wire        MOSI_B_p,  output wire MOSI_B_n,

    // --- Port C LVDS ---
    input  wire        MISO_C1_p, input  wire MISO_C1_n,
    input  wire        MISO_C2_p, input  wire MISO_C2_n,
    output wire        CS_b_C_p,  output wire CS_b_C_n,
    output wire        SCLK_C_p,  output wire SCLK_C_n,
    output wire        MOSI_C_p,  output wire MOSI_C_n,

    // --- Port D LVDS ---
    input  wire        MISO_D1_p, input  wire MISO_D1_n,
    input  wire        MISO_D2_p, input  wire MISO_D2_n,
    output wire        CS_b_D_p,  output wire CS_b_D_n,
    output wire        SCLK_D_p,  output wire SCLK_D_n,
    output wire        MOSI_D_p,  output wire MOSI_D_n,

    // --- Non-LVDS SPI (direct pin access) ---
    output wire        CS_b,
    output wire        SCLK,
    output wire        MOSI_A,
    output wire        MOSI_B,
    output wire        MOSI_C,
    output wire        MOSI_D,
    output wire        sample_clk,

    // --- TTL ---
    input  wire [15:0] TTL_in,
    output wire [15:0] TTL_out,

    // --- DAC / ADC ---
    output wire        DAC_SYNC,
    output wire        DAC_SCLK,
    output wire        DAC_DIN_1,
    output wire        DAC_DIN_2,
    output wire        DAC_DIN_3,
    output wire        DAC_DIN_4,
    output wire        DAC_DIN_5,
    output wire        DAC_DIN_6,
    output wire        DAC_DIN_7,
    output wire        DAC_DIN_8,
    output wire        ADC_CS,
    output wire        ADC_SCLK,
    input  wire        ADC_DOUT_1,
    input  wire        ADC_DOUT_2,
    input  wire        ADC_DOUT_3,
    input  wire        ADC_DOUT_4,
    input  wire        ADC_DOUT_5,
    input  wire        ADC_DOUT_6,
    input  wire        ADC_DOUT_7,
    input  wire        ADC_DOUT_8,

    input  wire [3:0]  board_mode
);

    // Stream wires between DAQ core and sandbox
    wire [15:0] data_word;
    wire        data_valid;
    wire        dataclk;

    // -----------------------------------------------------------------------
    // DAQ core
    // -----------------------------------------------------------------------
    main daq (
        .clk1_in    (clk1_in),
        .reset      (reset),
        .led        (led),

        .MISO_A1_p(MISO_A1_p), .MISO_A1_n(MISO_A1_n),
        .MISO_A2_p(MISO_A2_p), .MISO_A2_n(MISO_A2_n),
        .CS_b_A_p (CS_b_A_p),  .CS_b_A_n (CS_b_A_n),
        .SCLK_A_p (SCLK_A_p),  .SCLK_A_n (SCLK_A_n),
        .MOSI_A_p (MOSI_A_p),  .MOSI_A_n (MOSI_A_n),

        .MISO_B1_p(MISO_B1_p), .MISO_B1_n(MISO_B1_n),
        .MISO_B2_p(MISO_B2_p), .MISO_B2_n(MISO_B2_n),
        .CS_b_B_p (CS_b_B_p),  .CS_b_B_n (CS_b_B_n),
        .SCLK_B_p (SCLK_B_p),  .SCLK_B_n (SCLK_B_n),
        .MOSI_B_p (MOSI_B_p),  .MOSI_B_n (MOSI_B_n),

        .MISO_C1_p(MISO_C1_p), .MISO_C1_n(MISO_C1_n),
        .MISO_C2_p(MISO_C2_p), .MISO_C2_n(MISO_C2_n),
        .CS_b_C_p (CS_b_C_p),  .CS_b_C_n (CS_b_C_n),
        .SCLK_C_p (SCLK_C_p),  .SCLK_C_n (SCLK_C_n),
        .MOSI_C_p (MOSI_C_p),  .MOSI_C_n (MOSI_C_n),

        .MISO_D1_p(MISO_D1_p), .MISO_D1_n(MISO_D1_n),
        .MISO_D2_p(MISO_D2_p), .MISO_D2_n(MISO_D2_n),
        .CS_b_D_p (CS_b_D_p),  .CS_b_D_n (CS_b_D_n),
        .SCLK_D_p (SCLK_D_p),  .SCLK_D_n (SCLK_D_n),
        .MOSI_D_p (MOSI_D_p),  .MOSI_D_n (MOSI_D_n),

        .CS_b      (CS_b),
        .SCLK      (SCLK),
        .MOSI_A    (MOSI_A),
        .MOSI_B    (MOSI_B),
        .MOSI_C    (MOSI_C),
        .MOSI_D    (MOSI_D),
        .sample_clk(sample_clk),

        .TTL_in    (TTL_in),
        .TTL_out   (TTL_out),

        .DAC_SYNC  (DAC_SYNC),
        .DAC_SCLK  (DAC_SCLK),
        .DAC_DIN_1 (DAC_DIN_1), .DAC_DIN_2(DAC_DIN_2),
        .DAC_DIN_3 (DAC_DIN_3), .DAC_DIN_4(DAC_DIN_4),
        .DAC_DIN_5 (DAC_DIN_5), .DAC_DIN_6(DAC_DIN_6),
        .DAC_DIN_7 (DAC_DIN_7), .DAC_DIN_8(DAC_DIN_8),

        .ADC_CS    (ADC_CS),
        .ADC_SCLK  (ADC_SCLK),
        .ADC_DOUT_1(ADC_DOUT_1), .ADC_DOUT_2(ADC_DOUT_2),
        .ADC_DOUT_3(ADC_DOUT_3), .ADC_DOUT_4(ADC_DOUT_4),
        .ADC_DOUT_5(ADC_DOUT_5), .ADC_DOUT_6(ADC_DOUT_6),
        .ADC_DOUT_7(ADC_DOUT_7), .ADC_DOUT_8(ADC_DOUT_8),

        .board_mode(board_mode),

        .data_out  (data_word),
        .data_valid(data_valid)
    );

    // Expose internal dataclk for the sandbox (hierarchical wire)
    assign dataclk = daq.dataclk;

    // -----------------------------------------------------------------------
    // Processing sandbox
    // -----------------------------------------------------------------------
    processor_sandbox proc (
        .dataclk   (dataclk),
        .reset     (reset),
        .data_word (data_word),
        .data_valid(data_valid)
    );

endmodule
