module tb;
   
   reg clk;
   reg resetn;
   wire exit;
   wire [31:0] exitcode;
   
   // initial $monitor("clk %b resetn %b halt %b", clk, resetn, halt);
   
   initial begin
      clk = 0;
      resetn = 0;
   end

   initial
     #10 resetn = 1;
   
   always
     #5 clk = !clk;
   
   barrel inst (.clk(clk), .resetn(resetn), .exit(exit), .exitcode(exitcode));
   
   always @(posedge clk) begin
      if (resetn && exit)
        $finish_and_return(exitcode);
   end

   initial
     #100000 $finish_and_return(255);
   
endmodule
