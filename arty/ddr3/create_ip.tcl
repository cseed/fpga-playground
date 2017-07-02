create_project ddr3 . -part xc7a35ticsg324-1L

read_verilog main.v
read_xdc main.xdc

create_ip -name clk_wiz -vendor xilinx.com -library ip -version 5.4 -module_name clk_wiz_0
set_property -dict [list \
			CONFIG.CLKOUT2_USED {true} \
			CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {166.667} \
			CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {200.000} \
			CONFIG.RESET_TYPE {ACTIVE_LOW}] [get_ips clk_wiz_0]
generate_target all [get_files ddr3.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]

create_ip -name mig_7series -vendor xilinx.com -library ip -version 4.0 -module_name mig_7series_0

exec cp mig.prj ddr3.srcs/sources_1/ip/mig_7series_0
set_property -dict [list CONFIG.XML_INPUT_FILE {mig.prj}] [get_ips mig_7series_0]

generate_target {instantiation_template} [get_files ddr3.srcs/sources_1/ip/mig_7series_0/mig_7series_0.xci]
generate_target all [get_files ddr3.srcs/sources_1/ip/mig_7series_0/mig_7series_0.xci]

update_compile_order -fileset sources_1
