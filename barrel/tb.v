module tb;
   
   reg clk;
   reg resetn;
   
   initial begin
      clk = 0;
      resetn = 0;
   end

   initial
     #10 resetn = 1;
   
   always
     #5 clk = !clk;
   
   wire halt;
   
   barrel inst(.clk(clk), .resetn(resetn), .halt(halt));

   always @(posedge clk) begin
      if (halt && !resetn)
        $finish_and_return(0);
   end

   initial
     #10000 $finish_and_return(0);
   
endmodule
