
module main(
	    input 	 sys_clk,
	    output [3:0] led
	    );
   
   wire 		 clk = sys_clk;
   
   // reset pulse on startup
   reg [3:0] 	   reset_cnt = 0;
   wire 	   resetn = &reset_cnt;
   always @(posedge clk)
     if (!resetn)
       reset_cnt <= reset_cnt + 1;
   
   wire 	   exit;
   wire [31:0] 	   exitcode;
   barrel inst (.clk(clk), .resetn(resetn), .exit(exit), .exitcode(exitcode));
   
   assign led[0] = exit;
   assign led[3:1] = exitcode[2:0];
   
endmodule
