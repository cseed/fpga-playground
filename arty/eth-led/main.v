module main(
	    input 	 sys_clk,
	    
	    output [3:0] led,
	    
	    output 	 eth_ref_clk,
	    output 	 eth_rstn,
	    
	    input 	 eth_rx_clk,
	    input 	 eth_rx_dv,
	    input [3:0]  eth_rxd,
	    input 	 eth_rxerr
	    );
   
   wire 		 clk100;
   
   design_1_clk_wiz_0_1_clk_wiz
     clk_inst(.clk_in1(sys_clk),
	      .resetn(1),
	      .locked(locked),
	      .clk_out1(clk100),
	      .clk_out2(eth_clk)); // 25MHz

   assign eth_ref_clk = eth_clk;
   assign eth_rstn = 1;
   
   // use eth_rx_clk to avoid synchronization
   
   // reset pulse on startup
   reg [3:0] 	   reset_cnt = 0;
   wire 	   resetn = &reset_cnt;
   always @(posedge eth_rx_clk)
     if (!resetn)
       reset_cnt <= reset_cnt + 1;
   
   reg [3:0] 	   led_reg;
   assign led = led_reg;
   
   reg [31:0] 		 state;
   
   reg 			 nibble_i;
   reg [3:0] 		 prev_nibble;
   wire [7:0] 		 b = {eth_rxd, prev_nibble};
   
   reg [47:0] 		 dst;
   
   reg [31:0] 		 i;
   
   reg 			 prev_dv;
   
   always @(posedge eth_rx_clk)
     prev_dv <= eth_rx_dv;
   
   always @(posedge eth_rx_clk) begin
      if (!resetn) begin
	 led_reg <= 0;
	 nibble_i <= 0;
	 state <= 0;
      end else begin
	 if (eth_rx_dv) begin
	   prev_nibble <= eth_rxd;
	   nibble_i <= !nibble_i;
	 end else
	   nibble_i <= 0; // safe
	 
	 if (eth_rx_dv) begin
	    case (state)
	      0: begin
		 // make sure we didn't come out of reset during the
		 // middle of a packet
		 if (!prev_dv)
		   state <= 1;
	      end
	      
	      1: begin
		 if (nibble_i) begin
		    if (b == 8'hd5) begin // start of frame delimiter
		       state <= 2;
		       i <= 0;
		    end
		 end
	      end
	      
	      2: begin
		 if (nibble_i) begin
		    case (i)
		      0: dst[47:40] <= b;
		      1: dst[39:32] <= b;
		      2: dst[31:24] <= b;
		      3: dst[23:16] <= b;
		      4: dst[15:8] <= b;
		      5: dst[7:0] <= b;
		      
		      14: // first byte of payload
			if (dst == 48'h123456789abc)
			  led_reg <= b[3:0];
		    endcase
		    
		    i <= i + 1;
		 end
	      end
	    endcase
	 end else
	   state <= 0;
      end
   end
   
endmodule
