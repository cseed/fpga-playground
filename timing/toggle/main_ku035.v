module main_ku035(
		  input        sys_clk_p,
		  input        sys_clk_n,
		  output [7:0] ja,
		  input        ck_rst
	    );
   
   wire 		 sys_clk;
   IBUFDS ibufds_sys_clk(.I(sys_clk_p),
			 .IB(sys_clk_n),
			 .O(sys_clk));
   
   main main_inst(.sys_clk(sys_clk),
		  .ja(ja),
		  .ck_rst(ck_rst));
   
endmodule
