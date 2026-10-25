Sudhanva Joshi 2023102022
Aditya Peketi 2024122001

## Part A: RTL simulation

```
iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim
gtkwave mult.vcd
```
