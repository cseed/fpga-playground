read_verilog main.v
read_xdc main_arty.xdc

synth_design -part xc7a35ticsg324-1l -top main
opt_design
place_design
# phys_opt_design
route_design

report_utilization
report_timing
report_clocks

write_bitstream -force main_arty.bit
