
module tb;
   
   reg [31:0] rom [0:9];
   
   initial begin
      $readmemh("example.hex", rom);
   end
   
   initial
     #5 $finish_and_return(! (rom[0] == 32'h008000ef
			      && rom[2] == 32'hff010113
			      && rom[9] == 32'h00008067));
   
endmodule
