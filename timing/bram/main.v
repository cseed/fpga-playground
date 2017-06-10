module ram32(
             input                  clk,
             input [ADDR_WIDTH-1:2] addr,
             input [31:0]           din,
             input [3:0]            bwe,
             output reg [31:0]      dout,
             input                  ren);
   
   // 12 = 1K words
   parameter ADDR_WIDTH = 12;
   
   reg [31:0] 			    mem [0:(1 << (ADDR_WIDTH - 2)) - 1];
   
   always @(posedge clk) begin
      if (bwe[0])
        mem[addr][7:0] <= din[7:0];
      
      if (bwe[1])
        mem[addr][15:8] <= din[15:8];
      
      if (bwe[2])
        mem[addr][23:16] <= din[23:16];
      
      if (bwe[3])
        mem[addr][31:24] <= din[31:24];
   end
   
   always @(posedge clk) begin
      if (ren)
        dout <= mem[addr];
   end
   
endmodule             

module main(
	    input 	sys_clk,
	    inout [7:0] ja,
	    input 	ck_rst
	    );
   
   assign clk = sys_clk;
   assign resetn = ck_rst;
   
   reg [9:0] 		addr;
   reg [31:0] 		din;
   wire [3:0] 		bwe;
   wire 		ren;
   wire [31:0] 		dout;
   ram32 ram_inst(.clk(clk),
		  .addr(addr),
		  .din(din),
		  .bwe(bwe),
		  .dout(dout),
		  .ren(ren));
   
   always @(posedge clk) begin
      // something non-trivial
      if (ja[6])
	din <= dout;
      else
	din <= {dout[30:0], ja[7]};
      addr <= addr + 1;
   end
   
   assign bwe = ja[3:0];
   assign ren = ja[4];
   
   assign ja[5] = dout[31];
   
endmodule
