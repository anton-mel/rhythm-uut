#!/usr/bin/env bash
# Sandbox BFM test — drives processor_sandbox with the BFM, no SPI state machine.
# Run from repo root: bash sim/run_sandbox.sh

set -euo pipefail

OUT=sim/sim_sandbox.vvp

iverilog -g2005 -Wall \
    -o "$OUT" \
    sim/tb_sandbox.v \
    sim/bfm_daq.v \
    processor_sandbox.v

echo "Compilation succeeded. Running simulation..."
vvp "$OUT"
