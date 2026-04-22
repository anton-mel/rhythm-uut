`timescale 1ns/1ps

// Testbench for main.v (RHD2000 Rhythm, XEM7310 port).
//
// Frame header is written as four 16-bit words in little-endian order
// from the 64-bit constant 0xC691_1999_2702_1942:
//   word 0: 0x1942  (bits [15: 0])
//   word 1: 0x2702  (bits [31:16])
//   word 2: 0x1999  (bits [47:32])
//   word 3: 0xC691  (bits [63:48])
//
// data_valid is generated in the dataclk domain (~84 MHz) and is observed
// here in the clk1_in domain (100 MHz).  Rising-edge detection on data_valid
// is used so each pulse is counted exactly once.

module tb_main;

    // -----------------------------------------------------------------
    // Clock & reset
    // -----------------------------------------------------------------
    reg clk1_in = 0;
    reg reset   = 1;

    always #5 clk1_in = ~clk1_in;  // 100 MHz

    // -----------------------------------------------------------------
    // DUT outputs
    // -----------------------------------------------------------------
    wire [15:0] data_out;
    wire        data_valid;
    wire [ 7:0] led;

    // SPI / LVDS outputs (unused in this testbench)
    wire CS_b, SCLK, MOSI_A, MOSI_B, MOSI_C, MOSI_D, sample_clk;
    wire CS_b_A_p, CS_b_A_n, CS_b_B_p, CS_b_B_n, CS_b_C_p, CS_b_C_n, CS_b_D_p, CS_b_D_n;
    wire SCLK_A_p, SCLK_A_n, SCLK_B_p, SCLK_B_n, SCLK_C_p, SCLK_C_n, SCLK_D_p, SCLK_D_n;
    wire MOSI_A_p, MOSI_A_n, MOSI_B_p, MOSI_B_n, MOSI_C_p, MOSI_C_n, MOSI_D_p, MOSI_D_n;
    wire DAC_SYNC, DAC_SCLK;
    wire DAC_DIN_1, DAC_DIN_2, DAC_DIN_3, DAC_DIN_4;
    wire DAC_DIN_5, DAC_DIN_6, DAC_DIN_7, DAC_DIN_8;
    wire ADC_CS, ADC_SCLK;
    wire [15:0] TTL_out;

    // -----------------------------------------------------------------
    // DUT instantiation
    // -----------------------------------------------------------------
    main dut (
        .clk1_in      (clk1_in),
        .reset        (reset),
        .led          (led),

        // LVDS inputs — tie low (no real headstage)
        .MISO_A1_p(1'b0), .MISO_A1_n(1'b1),
        .MISO_A2_p(1'b0), .MISO_A2_n(1'b1),
        .MISO_B1_p(1'b0), .MISO_B1_n(1'b1),
        .MISO_B2_p(1'b0), .MISO_B2_n(1'b1),
        .MISO_C1_p(1'b0), .MISO_C1_n(1'b1),
        .MISO_C2_p(1'b0), .MISO_C2_n(1'b1),
        .MISO_D1_p(1'b0), .MISO_D1_n(1'b1),
        .MISO_D2_p(1'b0), .MISO_D2_n(1'b1),

        // LVDS outputs
        .CS_b_A_p(CS_b_A_p), .CS_b_A_n(CS_b_A_n),
        .CS_b_B_p(CS_b_B_p), .CS_b_B_n(CS_b_B_n),
        .CS_b_C_p(CS_b_C_p), .CS_b_C_n(CS_b_C_n),
        .CS_b_D_p(CS_b_D_p), .CS_b_D_n(CS_b_D_n),
        .SCLK_A_p(SCLK_A_p), .SCLK_A_n(SCLK_A_n),
        .SCLK_B_p(SCLK_B_p), .SCLK_B_n(SCLK_B_n),
        .SCLK_C_p(SCLK_C_p), .SCLK_C_n(SCLK_C_n),
        .SCLK_D_p(SCLK_D_p), .SCLK_D_n(SCLK_D_n),
        .MOSI_A_p(MOSI_A_p), .MOSI_A_n(MOSI_A_n),
        .MOSI_B_p(MOSI_B_p), .MOSI_B_n(MOSI_B_n),
        .MOSI_C_p(MOSI_C_p), .MOSI_C_n(MOSI_C_n),
        .MOSI_D_p(MOSI_D_p), .MOSI_D_n(MOSI_D_n),

        // Non-LVDS SPI (internal regs, still output ports)
        .CS_b(CS_b), .SCLK(SCLK),
        .MOSI_A(MOSI_A), .MOSI_B(MOSI_B), .MOSI_C(MOSI_C), .MOSI_D(MOSI_D),
        .sample_clk(sample_clk),

        // TTL
        .TTL_in(16'b0), .TTL_out(TTL_out),

        // DAC / ADC
        .DAC_SYNC(DAC_SYNC), .DAC_SCLK(DAC_SCLK),
        .DAC_DIN_1(DAC_DIN_1), .DAC_DIN_2(DAC_DIN_2),
        .DAC_DIN_3(DAC_DIN_3), .DAC_DIN_4(DAC_DIN_4),
        .DAC_DIN_5(DAC_DIN_5), .DAC_DIN_6(DAC_DIN_6),
        .DAC_DIN_7(DAC_DIN_7), .DAC_DIN_8(DAC_DIN_8),
        .ADC_CS(ADC_CS), .ADC_SCLK(ADC_SCLK),
        .ADC_DOUT_1(1'b0), .ADC_DOUT_2(1'b0),
        .ADC_DOUT_3(1'b0), .ADC_DOUT_4(1'b0),
        .ADC_DOUT_5(1'b0), .ADC_DOUT_6(1'b0),
        .ADC_DOUT_7(1'b0), .ADC_DOUT_8(1'b0),

        .board_mode(4'b0),

        .data_out  (data_out),
        .data_valid(data_valid)
    );

    // -----------------------------------------------------------------
    // Stimulus
    // -----------------------------------------------------------------
    initial begin
        $display("TB: reset asserted");
        #200;
        reset = 0;
        $display("TB: reset released at %0t ns", $time);
    end

    // -----------------------------------------------------------------
    // Internal dataclk (hierarchical reference — 84 MHz SPI state clock)
    // The consumer of the output stream should sample data_out on each
    // rising edge of dataclk while data_valid is asserted, matching the
    // original FIFO write-enable protocol.
    // -----------------------------------------------------------------
    wire dataclk = dut.dataclk;

    // -----------------------------------------------------------------
    // Frame capture — collect first 4 valid words on the dataclk domain
    //
    // Magic number 64'hC691_1999_2702_1942 is written low-word first:
    //   word 0: 0x1942
    //   word 1: 0x2702
    //   word 2: 0x1999
    //   word 3: 0xC691
    // -----------------------------------------------------------------
    localparam [15:0] MAGIC_0 = 16'h1942;
    localparam [15:0] MAGIC_1 = 16'h2702;
    localparam [15:0] MAGIC_2 = 16'h1999;
    localparam [15:0] MAGIC_3 = 16'hC691;

    integer word_count;
    reg [15:0] captured [0:3];
    reg        frame_done;

    initial begin
        word_count = 0;
        frame_done = 0;
    end

    always @(posedge dataclk) begin
        if (data_valid && !frame_done) begin
            if (word_count < 4) begin
                captured[word_count] = data_out;
                $display("TB: word[%0d] = 0x%04X at %0t ns", word_count, data_out, $time);
                word_count = word_count + 1;
            end
            if (word_count == 4) begin
                frame_done = 1;
                $display("TB: first 4 valid words captured");
                if (captured[0] === MAGIC_0 &&
                    captured[1] === MAGIC_1 &&
                    captured[2] === MAGIC_2 &&
                    captured[3] === MAGIC_3) begin
                    $display("TB: PASS — frame header matched: %04X %04X %04X %04X",
                        captured[0], captured[1], captured[2], captured[3]);
                end else begin
                    $display("TB: FAIL — unexpected header: %04X %04X %04X %04X",
                        captured[0], captured[1], captured[2], captured[3]);
                    $display("TB:   expected:               %04X %04X %04X %04X",
                        MAGIC_0, MAGIC_1, MAGIC_2, MAGIC_3);
                end
                $finish;
            end
        end
    end

    // Safety timeout: 10 ms simulated time
    initial begin
        #10_000_000;
        $display("TB: TIMEOUT — data_valid never produced 4 words in 10 ms");
        $finish;
    end

    // Dump waveforms for inspection
    initial begin
        $dumpfile("sim/tb_main.vcd");
        $dumpvars(0, tb_main);
    end

endmodule
