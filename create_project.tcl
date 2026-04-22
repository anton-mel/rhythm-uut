# create_project.tcl
# Creates a Vivado project for the RHD2000 Rhythm XEM7310 port.
#
# Usage (from Vivado Tcl Console or batch mode):
#   cd <repo root>
#   source create_project.tcl

set project_name  rhythm_xem7310
set project_dir   ./vivado
set part          xc7a200tfbg484-1

# Create project
create_project $project_name $project_dir -part $part -force
set_property target_language   Verilog [current_project]
set_property default_lib       xil_defaultlib [current_project]

# Source files (excludes legacy Spartan-6 DDR2/FrontPanel files)
set sources [list \
    top.v \
    main.v \
    processor_sandbox.v \
    variable_freq_clk_generator.v \
    RAM_bank.v \
    RAM_block.v \
    MISO_phase_selector.v \
    DAC_output_scalable_HPF.v \
    ADC_input.v \
    multiplier.v \
    multiplier_18x18.v \
]

add_files $sources
set_property top top [current_fileset]

# Constraints
add_files -fileset constrs_1 xem7310.xdc

# Run elaboration check (catches port/wire mismatches without full synthesis)
# Comment out if you want to open the GUI without waiting.
synth_design -rtl -name rtl_1

puts "------------------------------------------------------------"
puts "Project created: $project_dir/$project_name.xpr"
puts "Top module:      top"
puts "Part:            $part"
puts ""
puts "Next steps:"
puts "  1. Fill in pin LOC assignments in xem7310.xdc"
puts "  2. Run synthesis:   launch_runs synth_1"
puts "  3. Run impl:        launch_runs impl_1 -to_step write_bitstream"
puts "------------------------------------------------------------"
