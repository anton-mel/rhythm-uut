`timescale 1ns/1ps

// Integration smoke test for top.v.
// Verifies that the stream wired from main -> processor_sandbox is live:
// checks that data_valid pulses reach the sandbox and that the first word
// the sandbox sees is the correct frame magic word (0x1942, LSW of header).

module tb_top;

    reg clk1_in = 0;
    reg reset   = 1;

    always #5 clk1_in = ~clk1_in;  // 100 MHz

    // All physical I/O — only the ones top exposes as ports
    wire [7:0]  led;
    wire CS_b, SCLK, MOSI_A, MOSI_B, MOSI_C, MOSI_D, sample_clk;
    wire CS_b_A_p, CS_b_A_n, CS_b_B_p, CS_b_B_n, CS_b_C_p, CS_b_C_n, CS_b_D_p, CS_b_D_n;
    wire SCLK_A_p, SCLK_A_n, SCLK_B_p, SCLK_B_n, SCLK_C_p, SCLK_C_n, SCLK_D_p, SCLK_D_n;
    wire MOSI_A_p, MOSI_A_n, MOSI_B_p, MOSI_B_n, MOSI_C_p, MOSI_C_n, MOSI_D_p, MOSI_D_n;
    wire DAC_SYNC, DAC_SCLK;
    wire DAC_DIN_1, DAC_DIN_2, DAC_DIN_3, DAC_DIN_4;
    wire DAC_DIN_5, DAC_DIN_6, DAC_DIN_7, DAC_DIN_8;
    wire ADC_CS, ADC_SCLK;
    wire [15:0] TTL_out;

    top dut (
        .clk1_in   (clk1_in),
        .reset     (reset),
        .led       (led),

        .MISO_A1_p(1'b0), .MISO_A1_n(1'b1),
        .MISO_A2_p(1'b0), .MISO_A2_n(1'b1),
        .MISO_B1_p(1'b0), .MISO_B1_n(1'b1),
        .MISO_B2_p(1'b0), .MISO_B2_n(1'b1),
        .MISO_C1_p(1'b0), .MISO_C1_n(1'b1),
        .MISO_C2_p(1'b0), .MISO_C2_n(1'b1),
        .MISO_D1_p(1'b0), .MISO_D1_n(1'b1),
        .MISO_D2_p(1'b0), .MISO_D2_n(1'b1),

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

        .CS_b(CS_b), .SCLK(SCLK),
        .MOSI_A(MOSI_A), .MOSI_B(MOSI_B), .MOSI_C(MOSI_C), .MOSI_D(MOSI_D),
        .sample_clk(sample_clk),

        .TTL_in(16'b0), .TTL_out(TTL_out),

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

        .board_mode(4'b0)
    );

    initial begin
        #200;
        reset = 0;
        $display("TB_TOP: reset released at %0t ns", $time);
    end

    // -----------------------------------------------------------------------
    // Observe the stream as it arrives inside processor_sandbox via
    // hierarchical references: dut.proc.dataclk / .data_valid / .data_word
    // -----------------------------------------------------------------------
    wire        sb_clk   = dut.proc.dataclk;
    wire        sb_valid = dut.proc.data_valid;
    wire [15:0] sb_word  = dut.proc.data_word;

    reg [15:0] first_word;
    reg        captured = 0;

    always @(posedge sb_clk) begin
        if (sb_valid && !captured) begin
            first_word = sb_word;
            captured   = 1;
            $display("TB_TOP: sandbox received first word = 0x%04X at %0t ns", sb_word, $time);
            if (sb_word === 16'h1942)
                $display("TB_TOP: PASS — sandbox stream is live, first word correct (0x1942)");
            else
                $display("TB_TOP: FAIL — unexpected first word: 0x%04X (expected 0x1942)", sb_word);
            $finish;
        end
    end

    initial begin
        #10_000_000;
        $display("TB_TOP: TIMEOUT — sandbox never received data_valid in 10 ms");
        $finish;
    end

    initial begin
        $dumpfile("sim/tb_top.vcd");
        $dumpvars(0, tb_top);
    end

endmodule
