.PHONY: create_ip
create_ip:
	vivado -mode batch -source create_ip.tcl

.PHONY: synth
synth:
	vivado -mode batch -source synth.tcl

.PHONY: program
program: ddr.runs/impl_1/main.bit
	vivado -nojournal -mode batch -source program.tcl -log logs/program.log

.PHONY: clean
clean:
	rm -rf ddr.*
	rm -f logs/*.log vivado*.log vivado*.jou
	rm -rf .Xil
