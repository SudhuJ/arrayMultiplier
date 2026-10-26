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
