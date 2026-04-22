# RHD2000 Rhythm

Intan Technologies RHD2000 Rhythm FPGA firmware (via Open Ephys fork), retargeted from the Opal Kelly XEM6010 (Xilinx Spartan-6 LX45) to the Opal Kelly XEM7310 (Xilinx Artix-7 XC7A200T-1FBG484C).

The Opal Kelly FrontPanel USB layer and DDR2 SDRAM data path have been removed. The RHD2000 SPI acquisition core now streams electrode data directly through a simple 16-bit word interface, decoupled from any host communication protocol. A processor sandbox module sits on the other end of the stream for on-chip processing.

---

## Architecture

```
top.v  (XEM7310 synthesis root)
 ├── main.v  (RHD2000 DAQ core)
 │     data_out[15:0]
 │     data_valid
 processor_sandbox.v  (processing logic)
 │     dataclk (~84MHz)
 └── processor_sandbox.v
```

---

## What was removed

| Removed | Reason |
|---|---|
| Opal Kelly FrontPanel (`okHost`, `okWireIn`, `okWireOut`, `okPipeOut`, `okLibrary.v`) | No USB export needed |
| DDR2 SDRAM controller (`memc3_wrapper`, `mcb_soft_calibration`, `SDRAM_FIFO`, `ddr2_state_machine`) | No off-chip buffering needed |
| Dynamic DCM reprogramming state machine (`DCM_CLKGEN`, `DCM_prog_*` ports) | Replaced by fixed-parameter MMCM |
| All `ep*wirein` / `ep*trigin` control registers | Replaced by `localparam` constants |

---

## What was changed

### `variable_freq_clk_generator.v`

Replaced the Spartan-6 `DCM_CLKGEN` primitive and its runtime reprogramming state machine with a static Artix-7 `MMCME2_BASE` instance. Output frequency fixed at 84 MHz (30 kS/s per channel):

```
CLKFBOUT_MULT_F  = 42.0
DIVCLK_DIVIDE    = 5
CLKOUT0_DIVIDE_F = 10.0
VCO = 840 MHz  (within Artix-7 MMCM spec: 600–1440 MHz)
```

### `main.v`

- Ports reduced to: `clk1_in`, `reset`, physical SPI/LVDS/DAC/ADC pins, and the two stream outputs.
- All FrontPanel WireIn/TriggerIn/WireOut endpoint logic removed.
- `SDRAM_FIFO` instantiation removed; the internal `FIFO_data_in`/`FIFO_write_to` registers are wired directly to the output ports. The SPI state machine is left completely untouched:

```verilog
assign data_out   = FIFO_data_in;
assign data_valid = FIFO_write_to;
```

- All runtime-configurable registers replaced with `localparam` constants (SPI continuous run, all 8 streams enabled, default 30 kS/s rate).
- `RAM_bank` port A clock changed from `ti_clk` (FrontPanel USB clock) to `clk1_in`.

---

## New files

### `top.v`

Synthesis top-level for the XEM7310. Instantiates `main` and `processor_sandbox` and wires the stream between them. The internal `dataclk` is passed to the sandbox via hierarchical assign.

### `processor_sandbox.v`

Empty stub that receives the electrode data stream. Add processing logic here. Interface:

```verilog
module processor_sandbox (
    input wire        dataclk,    // ~84 MHz SPI state-machine clock
    input wire        reset,
    input wire [15:0] data_word,  // one 16-bit word per valid pulse
    input wire        data_valid  // high for one dataclk cycle per valid word
);
```

Stream protocol: sample `data_word` on every rising edge of `dataclk` while `data_valid` is high.

**Frame format:**

| Word | Value | Description |
|---|---|---|
| 0 | `0x1942` | Magic header (LSW of `0xC691199927021942`) |
| 1 | `0x2702` | Magic header |
| 2 | `0x1999` | Magic header |
| 3 | `0xC691` | Magic header (MSW) |
| 4–5 | — | 32-bit timestamp |
| 6+ | — | Electrode sample words (8 streams × channels) |
