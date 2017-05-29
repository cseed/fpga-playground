module main(
	    input 	 sys_clk,
	    input [3:0]  sw,
	    input [3:0]  btn,
	    output [3:0] led
	    );
   
   // reset pulse on startup
   reg [3:0] 	   reset_cnt = 0;
   wire 	   resetn = &reset_cnt;
   always @(posedge sys_clk)
     if (!resetn)
       reset_cnt <= reset_cnt + 1;
   
   assign led[3:2] = 3'b01;
   assign led[1] = btn[0];
   xor(led[0], sw[0], sw[1]);
endmodule
