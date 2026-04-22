`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:  processor_sandbox
// Description:  Placeholder for user-defined processing logic.
//               Receives the RHD2000 electrode data stream from main.v.
//               No outputs — extend this module with your own logic.
//
// Stream protocol (identical to the original FIFO write interface):
//   - data is clocked in the dataclk domain (~84 MHz)
//   - sample data_word on every rising edge of dataclk while data_valid is high
//   - frame format: 4-word magic header, timestamp, then electrode samples
//////////////////////////////////////////////////////////////////////////////////

module processor_sandbox (
    input wire        dataclk,    // ~84 MHz SPI state-machine clock
    input wire        reset,      // active-high synchronous reset
    input wire [15:0] data_word,  // one 16-bit word per valid pulse
    input wire        data_valid  // high for one dataclk cycle per valid word
);

    // -----------------------------------------------------------------------
    // Insert processing logic here.
    // -----------------------------------------------------------------------

endmodule
