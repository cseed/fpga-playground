module main(
	    input 	 sys_clk,
	    output [7:0] ja,
	    input 	 ck_rst
	    );
   
   assign clk = sys_clk;
   assign resetn = ck_rst;
   
   reg [31:0] q;
   always @(posedge clk) begin
      if (!resetn)
	q <= 0;
      else
	q <= q + 1;
   end
   
   assign ja = q[31:24];
   
endmodule
