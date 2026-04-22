`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:  bfm_daq
// Description:  Bus-Functional Model of the RHD2000 DAQ core (main.v).
//
//               Replaces the full SPI state machine for simulation.
//               Outputs complete RHD2000 frames directly onto the
//               data_word/data_valid/dataclk interface, one word per cycle,
//               with no SPI bit-period gaps.
//
//               Real hardware: ~2800 dataclk cycles per frame
//               This BFM:        296 dataclk cycles per frame  (~9x faster)
//
// Frame format (296 words, matching Rhythm firmware):
//   [0]       magic 0x1942
//   [1]       magic 0x2702
//   [2]       magic 0x1999
//   [3]       magic 0xC691
//   [4]       timestamp[15:0]
//   [5]       timestamp[31:16]
//   [6..277]  amp samples: 34 channels x 8 streams (stream-major order)
//             word = channel[7:0] | stream[7:0]<<8  (easy to decode in sandbox)
//   [278..285] 8 filler words (0xFFFF)
//   [286..293] 8 ADC words (0x0000)
//   [294]     TTL in  (0x0000)
//   [295]     TTL out (0x0000)
//////////////////////////////////////////////////////////////////////////////////

module bfm_daq #(
    parameter INTER_FRAME_GAP = 4   // idle cycles between frames
)(
    input  wire        clk,         // reference clock — BFM outputs one word/cycle
    input  wire        reset,
    output reg         dataclk,     // mirrors clk (sandbox samples on this)
    output reg  [15:0] data_word,
    output reg         data_valid
);
    // dataclk = clk in the BFM (no MMCM needed)
    always @(*) dataclk = clk;

    localparam FRAME_WORDS = 296;
    localparam GAP         = INTER_FRAME_GAP;

    reg [31:0] timestamp = 0;
    reg [9:0]  word_idx  = 0;   // 0..FRAME_WORDS-1: frame words; FRAME_WORDS..: gap
    reg [9:0]  gap_cnt   = 0;

    // Current frame word value
    reg [15:0] word_out;
    integer    ch, st;

    always @(*) begin
        word_out = 16'hDEAD; // default (should never appear)
        case (word_idx)
            10'd0: word_out = 16'h1942;                  // magic LSW
            10'd1: word_out = 16'h2702;
            10'd2: word_out = 16'h1999;
            10'd3: word_out = 16'hC691;                  // magic MSW
            10'd4: word_out = timestamp[15:0];
            10'd5: word_out = timestamp[31:16];
            default: begin
                if (word_idx >= 10'd6 && word_idx <= 10'd277) begin
                    // Amp samples: 34 channels x 8 streams, stream-major order
                    // word index within samples = word_idx - 6
                    // channel = (word_idx - 6) / 8
                    // stream  = (word_idx - 6) % 8
                    ch = (word_idx - 6) / 8;
                    st = (word_idx - 6) % 8;
                    word_out = {st[7:0], ch[7:0]};  // stream<<8 | channel
                end else if (word_idx >= 10'd278 && word_idx <= 10'd285) begin
                    word_out = 16'hFFFF;             // filler
                end else if (word_idx >= 10'd286 && word_idx <= 10'd293) begin
                    word_out = 16'h0000;             // ADC
                end else if (word_idx == 10'd294) begin
                    word_out = 16'h0000;             // TTL in
                end else if (word_idx == 10'd295) begin
                    word_out = 16'h0000;             // TTL out
                end
            end
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            data_word  <= 16'h0;
            data_valid <= 1'b0;
            word_idx   <= 10'd0;
            gap_cnt    <= 10'd0;
            timestamp  <= 32'd0;
        end else begin
            if (gap_cnt > 0) begin
                // Inter-frame gap
                data_valid <= 1'b0;
                data_word  <= 16'h0;
                gap_cnt    <= gap_cnt - 1;
            end else if (word_idx < FRAME_WORDS) begin
                // Outputting frame
                data_valid <= 1'b1;
                data_word  <= word_out;
                word_idx   <= word_idx + 1;
            end else begin
                // Frame done — start gap, advance timestamp
                data_valid <= 1'b0;
                data_word  <= 16'h0;
                word_idx   <= 10'd0;
                timestamp  <= timestamp + 1;
                gap_cnt    <= GAP;
            end
        end
    end

endmodule
