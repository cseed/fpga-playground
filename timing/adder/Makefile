
VIVADO = vivado

main_ku035.bit: main.v main_ku035.v main_ku035.xdc synth_ku035.tcl
	$(VIVADO) -nojournal -mode batch -source synth_ku035.tcl -log logs/synth_ku035.log

main_arty.bit: main.v main_arty.xdc synth_arty.tcl
	$(VIVADO) -nojournal -mode batch -source synth_arty.tcl -log logs/synth_arty.log

clean:
	rm -rf .Xil
	rm -f *_webtalk.*
	rm -f logs/*.log
	rm -f main.bit
	rm -f vivado*.jou vivado*.log
	rm -f vivado_*.str
