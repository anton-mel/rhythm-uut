`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: processor_sandbox driven by bfm_daq.
//
// Does NOT instantiate main.v or the SPI state machine.
// The BFM generates N complete RHD2000 frames in nanoseconds.
// Use this testbench to test processing logic in processor_sandbox.
//////////////////////////////////////////////////////////////////////////////////

module tb_sandbox;

    parameter NUM_FRAMES = 10;  // number of frames to run through

    reg clk   = 0;
    reg reset = 1;

    always #5 clk = ~clk;  // 100 MHz

    // BFM outputs
    wire        dataclk;
    wire [15:0] data_word;
    wire        data_valid;

    // -------------------------------------------------------------------
    // BFM — generates full RHD2000 frames at full clock speed
    // -------------------------------------------------------------------
    bfm_daq #(.INTER_FRAME_GAP(4)) bfm (
        .clk       (clk),
        .reset     (reset),
        .dataclk   (dataclk),
        .data_word (data_word),
        .data_valid(data_valid)
    );

    // -------------------------------------------------------------------
    // DUT — the sandbox receives the stream
    // -------------------------------------------------------------------
    processor_sandbox dut (
        .dataclk   (dataclk),
        .reset     (reset),
        .data_word (data_word),
        .data_valid(data_valid)
    );

    // -------------------------------------------------------------------
    // Stimulus
    // -------------------------------------------------------------------
    initial begin
        #20;
        reset = 0;
        $display("TB_SANDBOX: reset released, BFM running");
    end

    // -------------------------------------------------------------------
    // Frame monitor — count frames, verify header and timestamp
    // -------------------------------------------------------------------
    localparam FRAME_WORDS = 296;

    integer word_pos   = 0;  // position within current frame
    integer frame_num  = 0;
    reg [31:0] ts_prev = 32'hFFFFFFFF;
    reg [31:0] ts_cur;
    reg        ts_lo_valid = 0;

    always @(posedge dataclk) begin
        if (!reset && data_valid) begin

            // Check magic header
            if (word_pos == 0 && data_word !== 16'h1942) begin
                $display("TB_SANDBOX: FAIL frame %0d word[0] = 0x%04X (expected 0x1942)",
                    frame_num, data_word);
                $finish;
            end
            if (word_pos == 1 && data_word !== 16'h2702) begin
                $display("TB_SANDBOX: FAIL frame %0d word[1] = 0x%04X (expected 0x2702)",
                    frame_num, data_word);
                $finish;
            end
            if (word_pos == 2 && data_word !== 16'h1999) begin
                $display("TB_SANDBOX: FAIL frame %0d word[2] = 0x%04X (expected 0x1999)",
                    frame_num, data_word);
                $finish;
            end
            if (word_pos == 3 && data_word !== 16'hC691) begin
                $display("TB_SANDBOX: FAIL frame %0d word[3] = 0x%04X (expected 0xC691)",
                    frame_num, data_word);
                $finish;
            end

            // Capture timestamp
            if (word_pos == 4) begin
                ts_cur[15:0]  = data_word;
                ts_lo_valid   = 1;
            end
            if (word_pos == 5 && ts_lo_valid) begin
                ts_cur[31:16] = data_word;
                if (ts_prev !== 32'hFFFFFFFF && ts_cur !== ts_prev + 1) begin
                    $display("TB_SANDBOX: FAIL frame %0d timestamp jump: %0d -> %0d",
                        frame_num, ts_prev, ts_cur);
                    $finish;
                end
                ts_prev = ts_cur;
            end

            word_pos = word_pos + 1;

            if (word_pos == FRAME_WORDS) begin
                $display("TB_SANDBOX: frame %0d OK  (timestamp=%0d)", frame_num, ts_prev);
                word_pos  = 0;
                frame_num = frame_num + 1;
                if (frame_num == NUM_FRAMES) begin
                    $display("TB_SANDBOX: PASS — %0d frames received and verified", NUM_FRAMES);
                    $finish;
                end
            end
        end
    end

    initial begin
        #10_000_000;
        $display("TB_SANDBOX: TIMEOUT");
        $finish;
    end

    initial begin
        $dumpfile("sim/tb_sandbox.vcd");
        $dumpvars(0, tb_sandbox);
    end

endmodule
