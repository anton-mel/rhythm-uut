# XDC Constraints for Opal Kelly XEM7310 (XC7A200T-1FBG484C)
# RHD2000 Rhythm — XEM7310 port
#
# System clock: 200 MHz on-board oscillator on AB11 (SYS_CLK_MC1, Bank 13)
# LEDs:         A13–B17, Bank 16, active-low, LVCMOS15
# SPI/DAC/ADC:  Assign from the differential pair list below to match your PCB.

# ===========================================================================
# Clock — 200 MHz oscillator (Bank 13, LVCMOS33)
#
# AB11 is the system clock available on the MC1 expansion connector but is
# NOT a clock-capable (MRCC/SRCC) pin, so it cannot drive a BUFG directly.
# CLOCK_DEDICATED_ROUTE FALSE allows implementation to proceed for now.
#
# To fix properly: confirm the oscillator pin from the XEM7310 schematic and
# replace AB11 with the correct MRCC pin. The clock-capable options on the
# expansion connectors are:
#   V4 (B34_L12P_MRCC, MC1 pin 77) — preferred for Bank 34 clocking
#   H4 (B35_L12P_MRCC, MC2 pin 77) — preferred for Bank 35 clocking
# ===========================================================================
set_property PACKAGE_PIN AB11      [get_ports clk1_in]
set_property IOSTANDARD  LVCMOS33  [get_ports clk1_in]
create_clock -period 5.000 -name clk1_in [get_ports clk1_in]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk1_in_IBUF]

# ===========================================================================
# LEDs (active-low, Bank 16, VCCO = 1.5 V)
# D1=led[0] ... D8=led[7]
# ===========================================================================
set_property PACKAGE_PIN A13 [get_ports {led[0]}]
set_property PACKAGE_PIN B13 [get_ports {led[1]}]
set_property PACKAGE_PIN A14 [get_ports {led[2]}]
set_property PACKAGE_PIN A15 [get_ports {led[3]}]
set_property PACKAGE_PIN B15 [get_ports {led[4]}]
set_property PACKAGE_PIN A16 [get_ports {led[5]}]
set_property PACKAGE_PIN B16 [get_ports {led[6]}]
set_property PACKAGE_PIN B17 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS15 [get_ports led]

# ===========================================================================
# Reset — LOC TBD; IOSTANDARD set so NSTD-1 is satisfied
# ===========================================================================
# set_property PACKAGE_PIN <pin> [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# ===========================================================================
# LVDS SPI ports A/B/C/D
# LOC TBD — fill P/N pins from your PCB schematic.
# Available Bank 34 differential pairs (MC1):
#   L24: W9/Y9   L21: V9/V8   L17: R6/T6   L19: V7/W7   L16: U6/V5
#   L23: Y8/Y7   L15: W6/W5   L14: T5/U5   L10: AA5/AB5  L13: R4/T4
#   L20: AB7/AB6 L11: Y4/AA4  L3:  R3/R2   L18: Y6/AA6  L9:  Y3/AA3
#   L22: AA8/AB8 L2:  U2/V2   L6:  U3/V3   L4:  W2/Y2   L5:  W1/Y1
#   L8:  AB3/AB2 L7:  AA1/AB1 L1:  T1/U1   L12_MRCC: V4/W4
# Available Bank 35 differential pairs (MC2):
#   L21: P5/P4   L24: P6/N5   L19: N4/N3   L22: P2/N2   L18: L5/L4
#   L20: R1/P1   L23: M6/M5   L16: M3/M2   L15: M1/L1   L17: K6/J6
#   L9:  K2/J2   L14: L3/K3   L7:  K1/J1   L10: J5/H5   L11: H3/G3
#   L8:  H2/G2   L4:  E2/D2   L5:  G1/F1   L6:  F3/E3   L3:  E1/D1
#   L1:  B1/A1   L2:  C2/B2   L13: K4/J4   L12_MRCC: H4/G4
# ===========================================================================

# --- Port A LOC (fill in) ---
# set_property PACKAGE_PIN <P_pin> [get_ports MISO_A1_p]
# set_property PACKAGE_PIN <N_pin> [get_ports MISO_A1_n]
# set_property PACKAGE_PIN <P_pin> [get_ports MISO_A2_p]
# set_property PACKAGE_PIN <N_pin> [get_ports MISO_A2_n]
# set_property PACKAGE_PIN <P_pin> [get_ports CS_b_A_p]
# set_property PACKAGE_PIN <N_pin> [get_ports CS_b_A_n]
# set_property PACKAGE_PIN <P_pin> [get_ports SCLK_A_p]
# set_property PACKAGE_PIN <N_pin> [get_ports SCLK_A_n]
# set_property PACKAGE_PIN <P_pin> [get_ports MOSI_A_p]
# set_property PACKAGE_PIN <N_pin> [get_ports MOSI_A_n]

# --- Port B LOC (fill in) ---
# set_property PACKAGE_PIN <P_pin> [get_ports MISO_B1_p]  ...
# set_property PACKAGE_PIN <P_pin> [get_ports MISO_B2_p]  ...
# set_property PACKAGE_PIN <P_pin> [get_ports CS_b_B_p]   ...
# set_property PACKAGE_PIN <P_pin> [get_ports SCLK_B_p]   ...
# set_property PACKAGE_PIN <P_pin> [get_ports MOSI_B_p]   ...

# --- Port C LOC (fill in) ---
# set_property PACKAGE_PIN <P_pin> [get_ports MISO_C1_p]  ...
# set_property PACKAGE_PIN <P_pin> [get_ports MISO_C2_p]  ...
# set_property PACKAGE_PIN <P_pin> [get_ports CS_b_C_p]   ...
# set_property PACKAGE_PIN <P_pin> [get_ports SCLK_C_p]   ...
# set_property PACKAGE_PIN <P_pin> [get_ports MOSI_C_p]   ...

# --- Port D LOC (fill in) ---
# set_property PACKAGE_PIN <P_pin> [get_ports MISO_D1_p]  ...
# set_property PACKAGE_PIN <P_pin> [get_ports MISO_D2_p]  ...
# set_property PACKAGE_PIN <P_pin> [get_ports CS_b_D_p]   ...
# set_property PACKAGE_PIN <P_pin> [get_ports SCLK_D_p]   ...
# set_property PACKAGE_PIN <P_pin> [get_ports MOSI_D_p]   ...

# IOSTANDARD for all LVDS SPI pairs (active even without LOC)
set_property IOSTANDARD LVDS_25 [get_ports {MISO_A1_p MISO_A1_n MISO_A2_p MISO_A2_n}]
set_property IOSTANDARD LVDS_25 [get_ports {CS_b_A_p  CS_b_A_n  SCLK_A_p  SCLK_A_n  MOSI_A_p MOSI_A_n}]
set_property IOSTANDARD LVDS_25 [get_ports {MISO_B1_p MISO_B1_n MISO_B2_p MISO_B2_n}]
set_property IOSTANDARD LVDS_25 [get_ports {CS_b_B_p  CS_b_B_n  SCLK_B_p  SCLK_B_n  MOSI_B_p MOSI_B_n}]
set_property IOSTANDARD LVDS_25 [get_ports {MISO_C1_p MISO_C1_n MISO_C2_p MISO_C2_n}]
set_property IOSTANDARD LVDS_25 [get_ports {CS_b_C_p  CS_b_C_n  SCLK_C_p  SCLK_C_n  MOSI_C_p MOSI_C_n}]
set_property IOSTANDARD LVDS_25 [get_ports {MISO_D1_p MISO_D1_n MISO_D2_p MISO_D2_n}]
set_property IOSTANDARD LVDS_25 [get_ports {CS_b_D_p  CS_b_D_n  SCLK_D_p  SCLK_D_n  MOSI_D_p MOSI_D_n}]

# ===========================================================================
# Single-ended signals — LVCMOS33 (Banks 34/35 default 3.3 V)
# LOC TBD — assign pins from your PCB schematic
# ===========================================================================
set_property IOSTANDARD LVCMOS33 [get_ports CS_b]
set_property IOSTANDARD LVCMOS33 [get_ports SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports MOSI_A]
set_property IOSTANDARD LVCMOS33 [get_ports MOSI_B]
set_property IOSTANDARD LVCMOS33 [get_ports MOSI_C]
set_property IOSTANDARD LVCMOS33 [get_ports MOSI_D]
set_property IOSTANDARD LVCMOS33 [get_ports sample_clk]
set_property IOSTANDARD LVCMOS33 [get_ports TTL_in]
set_property IOSTANDARD LVCMOS33 [get_ports TTL_out]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_SYNC]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_DIN_1]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_DIN_2]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_DIN_3]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_DIN_4]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_DIN_5]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_DIN_6]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_DIN_7]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_DIN_8]
set_property IOSTANDARD LVCMOS33 [get_ports ADC_CS]
set_property IOSTANDARD LVCMOS33 [get_ports ADC_SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports ADC_DOUT_1]
set_property IOSTANDARD LVCMOS33 [get_ports ADC_DOUT_2]
set_property IOSTANDARD LVCMOS33 [get_ports ADC_DOUT_3]
set_property IOSTANDARD LVCMOS33 [get_ports ADC_DOUT_4]
set_property IOSTANDARD LVCMOS33 [get_ports ADC_DOUT_5]
set_property IOSTANDARD LVCMOS33 [get_ports ADC_DOUT_6]
set_property IOSTANDARD LVCMOS33 [get_ports ADC_DOUT_7]
set_property IOSTANDARD LVCMOS33 [get_ports ADC_DOUT_8]
set_property IOSTANDARD LVCMOS33 [get_ports board_mode]

# ===========================================================================
# Timing exceptions
# ===========================================================================
set_false_path -from [get_ports reset]
