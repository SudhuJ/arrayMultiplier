Sudhanva Joshi 2023102022
Aditya Peketi 2024122001

## Part A: RTL simulation

All commands are run from the repository root. Simulation outputs go to `build/` (git-ignored).

```
mkdir -p build/rtl
iverilog -g2012 -o build/rtl/sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
(cd build/rtl && vvp sim)
gtkwave build/rtl/mult.vcd
```

## Part B: Logic synthesis

Run inside the IIC-OSIC-TOOLS container, from the repository root:

```
yosys -c synth/synth.tcl

mkdir -p build/gls
CELLS=$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog
iverilog -g2012 -DFUNCTIONAL -DUNIT_DELAY=#1 -o build/gls/gls \
  tb/tb_mult.v $CELLS/primitives.v $CELLS/sky130_fd_sc_hd.v synth/mult_array_netlist.v
(cd build/gls && vvp gls)
```

## Part C: Static timing analysis

Run inside the IIC-OSIC-TOOLS container, from the repository root.
First run at T = 10 ns to find the worst slack, then at Tmin = 2.79 ns (the default in `sta.tcl`):

```
PERIOD=10 sta sta/sta.tcl
sta sta/sta.tcl
```

## Part D: Physical design (LibreLane)

Run inside the IIC-OSIC-TOOLS container (with `PDK=sky130A`, e.g. after `sak-pdk sky130A`):

```
cd pnr
librelane --manual-pdk --pdk sky130A --scl sky130_fd_sc_hd --run-tag final_3.5_tt config.json
cp runs/final_3.5_tt/final/metrics.json metrics.json
cp runs/final_3.5_tt/final/gds/mult_array.gds mult_array.gds
klayout mult_array.gds
```

### Run log

CLOCK_PERIOD starts at 1.2 × Tmin = 1.2 × 2.79 = 3.348 ns, rounded up to 3.5 ns.

| Run | CLOCK_PERIOD (ns) | Corners checked | Worst setup slack (ns) | Typical-corner slack (ns) | DRC | LVS | Result |
|---|---|---|---|---|---|---|---|
| 1 | 3.5 | all 9 | -2.184 (max_ss_100C_1v60) | 0.511 | 0 | 0 | Fail (slow corner) |
| 2 | 4.0 | all 9 | -1.684 | 1.011 | 0 | 0 | Fail |
| 3 | 4.5 | all 9 | -1.184 | 1.511 | 0 | 0 | Fail |
| 4 | 5.0 | all 9 | -0.682 | 2.011 | 0 | 0 | Fail |
| 5 | 5.5 | all 9 | -0.208 | 2.509 | 0 | 0 | Fail |
| 6 | 6.0 | all 9 | -0.154 | 2.877 | 0 | 0 | Fail |
| 7 | 6.5 | all 9 | -0.224 | 3.117 | 0 | 0 | Fail |
| 8 | 7.0 | all 9 | -0.137 | 3.518 | 0 | 0 | Fail |
| 9 | 3.5 | typical (`nom_tt_025C_1v80`) | 0.077 | 0.077 | 0 | 0 | **Pass (final)** |

Runs 1–8 used LibreLane's default multi-corner signoff. Every run met timing at the typical
corner, but the slow corner (ss, 100 °C, 1.60 V) kept failing by about 0.15–0.2 ns from 5.5 ns
upwards, because the post-CTS timing repair only optimises for the typical corner. Since Part C
specifies the typical corner (tt_025C_1v80) only, run 9 restricts signoff to that corner with
`"STA_CORNERS": ["nom_tt_025C_1v80"]`.

## Report

```
tectonic report/report.tex      # writes report/report.pdf
```
