module main(
	    input 	 sys_clk,
	    output [7:0] ja,
	    input 	 ck_rst
	    );
   
   assign clk = sys_clk;
   assign resetn = ck_rst;
   
   reg q;
   always @(posedge clk) begin
      if (!resetn)
	q <= 0;
      else
	q <= !q;
   end

   assign ja[0] = q;
   
endmodule
