# XDC Constraints for Opal Kelly XEM7310 (XC7A200T-1FBG484C)
# RHD2000 Rhythm — XEM7310 port

# 100 MHz on-board oscillator (single-ended, bank 16)
set_property PACKAGE_PIN R4       [get_ports clk1_in]
set_property IOSTANDARD  LVCMOS33 [get_ports clk1_in]
create_clock -period 10.000 -name clk1_in [get_ports clk1_in]

set_false_path -from [get_ports reset]
