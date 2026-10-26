# OpenSTA timing analysis for the synthesized 4-bit array multiplier (typical corner)
# Run from the repository root: sta sta/sta.tcl
# The clock period defaults to Tmin; override it with e.g. PERIOD=10 sta sta/sta.tcl

set lib $::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

if {[info exists ::env(PERIOD)]} {
    set period $::env(PERIOD)
} else {
    set period 2.79
}

# 1. Read the cell timing library
read_liberty $lib

# 2. Read and link the netlist
read_verilog synth/mult_array_netlist.v
link_design mult_array

# 3. Define the clock with period T in ns
create_clock -name clk -period $period [get_ports clk]

# 4. Input arrival time
set_input_delay 1.0 -clock clk [delete_from_list [all_inputs] [get_ports clk]]

# 5. Output required time
set_output_delay 1.0 -clock clk [all_outputs]

# 6. Print the worst setup slack
puts "Clock period: $period ns"
report_worst_slack -max

# 7. Save the critical path report
report_checks -path_delay max -digits 3 > sta/mult_array_timing.rpt

exit
