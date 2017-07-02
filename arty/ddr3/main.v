module main(
	    output [13:0]    ddr3_sdram_addr,
	    output [2:0]     ddr3_sdram_ba,
	    output 	     ddr3_sdram_cas_n,
	    output [0:0]     ddr3_sdram_ck_n,
	    output [0:0]     ddr3_sdram_ck_p,
	    output [0:0]     ddr3_sdram_cke,
	    output [0:0]     ddr3_sdram_cs_n,
	    output [1:0]     ddr3_sdram_dm,
	    inout [15:0]     ddr3_sdram_dq,
	    inout [1:0]      ddr3_sdram_dqs_n,
	    inout [1:0]      ddr3_sdram_dqs_p,
	    output [0:0]     ddr3_sdram_odt,
	    output 	     ddr3_sdram_ras_n,
	    output 	     ddr3_sdram_reset_n,
	    output 	     ddr3_sdram_we_n,
	    input 	     sys_resetn,
	    input 	     sys_clock,
	    output reg [3:0] led);
   
   wire 		  locked;
   clk_wiz_0 clk_wiz_inst(
			  .clk_out1(clk_out1),
			  .clk_out2(clk_out2),
			  .resetn(sys_resetn),
			  .locked(locked),
			  .clk_in1(sys_clock));
   
   // user interface signals
   wire 		  ui_clk;
   wire 		  ui_clk_sync_rst;
   wire 		  mmcm_locked;
   wire 		  app_sr_active;
   wire 		  app_ref_ack;
   wire 		  app_zq_ack;
   // Slave Interface Write Address Ports
   wire [27:0] 		  s_axi_awaddr = 28'b0;
   wire [7:0] 		  s_axi_awlen = 8'b0; // 1
   wire [2:0] 		  s_axi_awsize = 3'b010; // 4 bytes
   wire [1:0] 		  s_axi_awburst = 2'b0; // fixed
   reg 			  s_axi_awvalid;
   wire 		  s_axi_awready;
   // Slave Interface Write Data Ports
   reg [31:0] 		  s_axi_wdata = 32'hcafe_beef;
   reg [3:0] 		  s_axi_wstrb = 4'b1111;
   reg 			  s_axi_wlast;
   reg 			  s_axi_wvalid;
   wire 		  s_axi_wready;
   // Slave Interface Write Response Ports
   reg 			  s_axi_bready;
   wire [3:0] 		  s_axi_bid;
   wire [1:0] 		  s_axi_bresp;
   wire 		  s_axi_bvalid;
   // Slave Interface Read Address Ports
   wire [27:0] 		  s_axi_araddr = 28'b0;
   wire [7:0] 		  s_axi_arlen = 8'b0; // 1
   wire [2:0] 		  s_axi_arsize = 3'b010; // 4 bytes
   wire [1:0] 		  s_axi_arburst = 2'b0; // fixed
   reg 			  s_axi_arvalid;
   wire 		  s_axi_arready;
   // Slave Interface Read Data Ports
   reg 			  s_axi_rready;
   wire [3:0] 		  s_axi_rid;
   wire [31:0] 		  s_axi_rdata;
   wire [1:0] 		  s_axi_rresp;
   wire 		  s_axi_rlast;
   wire 		  s_axi_rvalid;
   
   mig_7series_0 mig_inst(
			  .ddr3_dq(ddr3_sdram_dq),
			  .ddr3_dqs_n(ddr3_sdram_dqs_n),
			  .ddr3_dqs_p(ddr3_sdram_dqs_p),
			  .ddr3_addr(ddr3_sdram_addr),
			  .ddr3_ba(ddr3_sdram_ba),
			  .ddr3_ras_n(ddr3_sdram_ras_n),
			  .ddr3_cas_n(ddr3_sdram_cas_n),
			  .ddr3_we_n(ddr3_sdram_we_n),
			  .ddr3_reset_n(ddr3_sdram_reset_n),
			  .ddr3_ck_p(ddr3_sdram_ck_p),
			  .ddr3_ck_n(ddr3_sdram_ck_n),
			  .ddr3_cke(ddr3_sdram_cke),
			  .ddr3_cs_n(ddr3_sdram_cs_n),
			  .ddr3_dm(ddr3_sdram_dm),
			  .ddr3_odt(ddr3_sdram_odt),
			  .sys_clk_i(clk_out1),
			  .clk_ref_i(clk_out2),
			  // User Interface
			  .ui_clk(ui_clk),
			  .ui_clk_sync_rst(ui_clk_sync_rst),
			  .mmcm_locked(mmcm_locked),
			  .aresetn(1), // FIXME
			  .app_sr_req(0),
			  .app_ref_req(0),
			  .app_zq_req(0),
			  .app_sr_active(app_sr_active),
			  .app_ref_ack(app_ref_ack),
			  .app_zq_ack(app_zq_ack),
			  // Slave Interface Write Address Ports
			  .s_axi_awid(4'b0),
			  .s_axi_awaddr(s_axi_awaddr),
			  .s_axi_awlen(s_axi_awlen),
			  .s_axi_awsize(s_axi_awsize),
			  .s_axi_awburst(s_axi_awburst),
			  .s_axi_awlock(1'b0), // normal access
			  .s_axi_awcache(4'b0011),
			  .s_axi_awprot(3'b0),
			  .s_axi_awqos(4'b0),
			  .s_axi_awvalid(s_axi_awvalid),
			  .s_axi_awready(s_axi_awready),
			  // Slave Interface Write Data Ports
			  .s_axi_wdata(s_axi_wdata),
			  .s_axi_wstrb(s_axi_wstrb),
			  .s_axi_wlast(s_axi_wlast),
			  .s_axi_wvalid(s_axi_wvalid),
			  .s_axi_wready(s_axi_wready),
			  // Slave Interface Write Response Ports
			  .s_axi_bready(s_axi_bready),
			  .s_axi_bid(s_axi_bid),
			  .s_axi_bresp(s_axi_bresp),
			  .s_axi_bvalid(s_axi_bvalid),
			  // Slave Interface Read Address Ports
			  .s_axi_arid(4'b0),
			  .s_axi_araddr(s_axi_araddr),
			  .s_axi_arlen(s_axi_arlen),
			  .s_axi_arsize(s_axi_arsize),
			  .s_axi_arburst(s_axi_arburst),
			  .s_axi_arlock(1'b0),
			  .s_axi_arcache(4'b0011),
			  .s_axi_arprot(3'b0),
			  .s_axi_arqos(4'b0),
			  .s_axi_arvalid(s_axi_arvalid),
			  .s_axi_arready(s_axi_arready),
			  // Slave Interface Read Data Ports
			  .s_axi_rready(s_axi_rready),
			  .s_axi_rid(s_axi_rid),
			  .s_axi_rdata(s_axi_rdata),
			  .s_axi_rresp(s_axi_rresp),
			  .s_axi_rlast(s_axi_rlast),
			  .s_axi_rvalid(s_axi_rvalid),
			  
			  .sys_rst(sys_resetn));
   
   wire 		  clk = ui_clk;
   wire 		  clk_resetn = !ui_clk_sync_rst;

   reg [31:0] 		  state;
   
   always @(posedge clk) begin
      if (!clk_resetn) begin
	 s_axi_awvalid <= 0;
	 s_axi_wlast <= 0;
	 s_axi_wvalid <= 0;
	 s_axi_bready <= 0;
	 s_axi_arvalid <= 0;
	 s_axi_rready <= 0;
	 state <= 0;
	 led <= 4'b0;
      end else begin
	 case (state)
	   0: begin
	      s_axi_awvalid <= 1;
	      state <= 1;
	   end
	   
	   1: begin
	      if (s_axi_awready) begin
		 s_axi_awvalid <= 0;
		 state <= 2;
	      end
	   end
	   
	   2: begin
	      s_axi_wlast <= 1;
	      s_axi_wvalid <= 1;
	      state <= 3;
	   end
	   
	   3: begin
	      if (s_axi_wready) begin
		 s_axi_wvalid <= 0;
		 state <= 4;
	      end
	   end
	   
	   4: begin
	      if (s_axi_bvalid) begin
		 s_axi_bready <= 1;
		 state <= 5;
	      end
	   end
	   
	   5: begin
	      s_axi_bready <= 0;
	      led[0] <= 1; // write finished
	      
	      state <= 6;
	   end
	   
	   6: begin
	      s_axi_arvalid <= 1;
	      state <= 7;
	   end

	   7: begin
	      if (s_axi_arready) begin
		 s_axi_arvalid <= 0;
		 state <= 8;
	      end
	   end

	   8: begin
	      if (s_axi_rvalid) begin
		 s_axi_rready <= 1;
		 state <= 9;
	      end
	   end

	   9: begin
	      s_axi_rready <= 0;
	      
	      if (s_axi_rdata == 32'hcafe_beef)
		led[3] <= 1;
	      
	      led[1] <= 1; // read finished
	      
	      state <= 10;
	   end
	   
	   10: begin
	   end
	   
	 endcase
      end
   end
   
endmodule
