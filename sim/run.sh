#!/usr/bin/env bash
# Compile and simulate main.v with Icarus Verilog.
# Run from the repo root: bash sim/run.sh

set -euo pipefail

OUT=sim/sim.vvp

# NOTE: multiplier.v and multiplier_18x18.v are Spartan-6 netlists that cannot
# be compiled by Icarus; their behavioral equivalents live in sim/primitives.v.
iverilog -g2005 -Wall \
    -o "$OUT" \
    sim/primitives.v \
    sim/tb_main.v \
    top.v \
    main.v \
    processor_sandbox.v \
    variable_freq_clk_generator.v \
    RAM_bank.v \
    RAM_block.v \
    MISO_phase_selector.v \
    DAC_output_scalable_HPF.v \
    ADC_input.v

echo "Compilation succeeded. Running simulation..."
vvp "$OUT"
