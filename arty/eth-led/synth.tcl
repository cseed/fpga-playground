# read_verilog clock.v
read_verilog main.v
read_verilog clock.v
read_xdc main.xdc

synth_design -part xc7a35ticsg324-1L -top main
opt_design
place_design
route_design

report_utilization
report_timing

write_bitstream -force main.bit
