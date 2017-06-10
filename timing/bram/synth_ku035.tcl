read_verilog main_ku035.v
read_verilog main.v
read_xdc main_ku035.xdc

synth_design -part xcku035-ffva1156-2-e -top main_ku035
opt_design
place_design
# phys_opt_design
route_design

report_utilization
report_timing
report_clocks

write_bitstream -force main_ku035.bit
