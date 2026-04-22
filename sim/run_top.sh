#!/usr/bin/env bash
# Integration test: compiles top.v + processor_sandbox and verifies the
# stream reaches the sandbox correctly.
# Run from the repo root: bash sim/run_top.sh

set -euo pipefail

OUT=sim/sim_top.vvp

iverilog -g2005 -Wall \
    -o "$OUT" \
    sim/primitives.v \
    sim/tb_top.v \
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
