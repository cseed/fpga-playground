open_project ddr3.xpr

reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1

launch_runs -to_step write_bitstream impl_1 -jobs 4
wait_on_run impl_1
