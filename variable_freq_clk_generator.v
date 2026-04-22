`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      Intan Technologies, LLC
//
// Design Name:  RHD2000 Rhythm Interface
// Module Name:  variable_freq_clk_generator
// Description:  Fixed-frequency SPI clock generator for Xilinx Zynq-7 (MMCME2_BASE).
//               Output frequency = 100 MHz * CLKFBOUT_MULT_F / DIVCLK_DIVIDE / CLKOUT0_DIVIDE_F
//
//               Default: 84 MHz → 30 kS/s per channel
//               (2800 dataclk cycles per full 35-slot SPI frame)
//
//               To change sample rate, adjust CLKFBOUT_MULT_F and CLKOUT0_DIVIDE_F
//               keeping VCO = 100 * MULT / DIVCLK within 600–1440 MHz.
//
//               Selected sample rates (100 MHz input):
//               MULT_F  DIVCLK  DIV_F    dataclk      kS/s
//                 28       5    10.0     56.0 MHz      20.0
//                 42       5    10.0     84.0 MHz      30.0
//                 56       5    10.0    112.0 MHz      40.0
//                 28       5     5.0    112.0 MHz      40.0  (same, alt calc)
//                 42       5     6.0    140.0 MHz      50.0
//////////////////////////////////////////////////////////////////////////////////

module variable_freq_clk_generator #(
	parameter real CLKFBOUT_MULT_F  = 42.0,  // VCO multiplier  (default → 840 MHz VCO)
	parameter integer DIVCLK_DIVIDE = 5,     // VCO pre-divider (default → 840 MHz VCO)
	parameter real CLKOUT0_DIVIDE_F = 10.0   // Output divider  (default → 84 MHz out)
	)
	(
	input  wire clk1,     // 100 MHz input clock
	input  wire reset,    // synchronous reset (held during MMCM lock)
	output wire clkout,   // SPI clock output (through BUFG)
	output wire locked    // MMCM locked indicator
	);

	wire clkout_i;
	wire clkfb;

	MMCME2_BASE #(
		.CLKIN1_PERIOD     (10.0),           // 100 MHz input
		.CLKFBOUT_MULT_F   (CLKFBOUT_MULT_F),
		.DIVCLK_DIVIDE     (DIVCLK_DIVIDE),
		.CLKOUT0_DIVIDE_F  (CLKOUT0_DIVIDE_F),
		.CLKOUT0_DUTY_CYCLE(0.5),
		.CLKOUT0_PHASE     (0.0),
		.CLKFBOUT_PHASE    (0.0),
		.BANDWIDTH         ("OPTIMIZED"),
		.CLKOUT4_CASCADE   ("FALSE"),
		.STARTUP_WAIT      ("FALSE"),
		.REF_JITTER1       (0.01)
	)
	MMCME2_BASE_inst (
		.CLKIN1    (clk1),
		.CLKFBIN   (clkfb),
		.RST       (reset),
		.PWRDWN    (1'b0),
		.CLKOUT0   (clkout_i),
		.CLKOUT0B  (),
		.CLKOUT1   (), .CLKOUT1B(),
		.CLKOUT2   (), .CLKOUT2B(),
		.CLKOUT3   (), .CLKOUT3B(),
		.CLKOUT4   (),
		.CLKOUT5   (),
		.CLKOUT6   (),
		.CLKFBOUT  (clkfb),
		.CLKFBOUTB (),
		.LOCKED    (locked)
	);

	BUFG BUFG_1 (
		.O(clkout),
		.I(clkout_i)
	);

endmodule
