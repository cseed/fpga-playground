module main(
	    input 	 sys_clk,
	    input [31:0] v,
	    input [4:0]  d,
	    input 	 sel,
	    output [7:0] ja,
	    input 	 ck_rst
	    );
   
   assign clk = sys_clk;
   assign resetn = ck_rst;
   
   reg [31:0] q;
   reg [31:0] shift;
   always @(posedge clk) begin
      if (!resetn)
	q <= 0;
      else begin
	 if (sel)
	   q <= v;
	 else
	   q <= shift;
      end
      
      shift <= q << d;
   end
   
   assign ja = q[31:24];
   
endmodule
