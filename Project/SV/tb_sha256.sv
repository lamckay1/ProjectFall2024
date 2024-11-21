`timescale 1ns/1ps
module stimulus;

   parameter MSG_SIZE = 96;   

   logic [MSG_SIZE-1:0] message;   
   logic [255:0] hashed;
  logic start;
   logic 	 clk;
   logic   reset;
   logic   en;
   logic [31:0]  errors;
   logic [31:0]  vectornum;
   logic [255:0]  result;
   logic [7:0] 	 op;
   // Size of [351:0] is size of vector in file: 96 + 256 = 352 bits
   logic [351:0] testvectors[511:0];
     
   
   integer 	 handle3;
   integer 	 desc3;
   integer 	 i;  
   integer       j;

   top #(MSG_SIZE, 512) dut (message, clk, reset, start, hashed);

   // 1 ns clock
   initial 
     begin	
	clk = 1'b1;
	forever #5 clk = ~clk;
     end

   initial
     begin
        handle3 = $fopen("sha256.out");
        $readmemh("sha256.tv", testvectors);       
        vectornum = 0;
        errors = 0;             
        desc3 = handle3;
     end

  // apply test vectors on rising edge of clk
   always @(posedge clk)
     begin
        // Add message here : "Hello, SHA-256!"
        #1 message = 96'h47756e647920526f636b7321;
        // Expected result
        #0 result = 256'h6afba0bb92737254ed97dd21d5ac868b2226417b8241e020a0996ed2c1ac6b27;
     end

 initial
 begin
  #0 reset = 1'b1;
  #11 reset = 1'b0;
  #1 start = 1'b1;
  #11 start = 1'b0;
 
  #800 $fdisplay(desc3, "%h %h || %h || %b", message, hashed, result, (result == hashed));
 end

   
   
endmodule // stimulus
