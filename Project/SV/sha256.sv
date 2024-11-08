//
// Secure Hash Standard (SHA-256)
//
`timescale 1ns / 1ps
module flopenr #(parameter WIDTH = 32) (
  input  logic             clk, reset, en,
  input  logic [WIDTH-1:0] d, 
  output logic [WIDTH-1:0] q);

  always_ff @(posedge clk)
    if (reset)   q <= #1 0;
    else if (en) q <= #1 d;
endmodule

module flopenrhashed #(parameter WIDTH = 256) (
  input  logic             clk, reset, en, 
  input  logic [31:0] a,b,c,d,e,f,g,h, 
  output logic [WIDTH-1:0] hash);

  always_ff @(posedge clk)
    if (reset)   hash <= #1 0;
    else if (en) hash <= #1 {a,b,c,d,e,f,g,h};
endmodule 
module counter64 (
    input  logic clk,        // Clock input
    input  logic rst,        // Reset input (active high)
    input  logic start,      // Start signal (activates counting)
    output logic [5:0] count // 6-bit counter output (counts from 0 to 63)
);

    // Internal enable signal for counting
    logic count_enable;

    // Always block to handle reset and counting
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 6'b000000;             // Reset counter to 0
            count_enable <= 1'b0;           // Disable counting on reset
        end else if (count_enable) begin
            if (count == 6'b111111) begin   // End of count
               count_enable <= 1'b0;
	       count <= 6'h0;	            // Reset count to 0
            end else begin
                count <= count + 1;         // Increment counter
            end
        end else if (start) begin
            count_enable <= 1'b1;           // Enable counting when start is high
        end
    end

endmodule

module top #(parameter MSG_SIZE=24,
	     parameter PADDED_SIZE = 512)
   (input logic [MSG_SIZE-1:0] message, input logic clk , input logic reset, input logic start,
    output logic [255:0] hashed);

   logic [PADDED_SIZE-1:0] padded;
	sha_padder #(MSG_SIZE,PADDED_SIZE) padder(message, padded);
   
      logic [5:0] count;
		logic en, en2;
	counter64 counter( clk, reset, start, count );
	  

	typedef enum logic [1:0] {S0, S1, S2} statetype;
   statetype state, nextstate;

	always_ff @(posedge clk, posedge reset)
     if (reset) state <= S0;
     else       state <= nextstate;



	always_comb
	 	case (state)
		S0: begin

			en<=0;
			en2<=0;
			
			if(start) nextstate<=S1;
			else nextstate<=S0;
			
			
			end

		S1:begin 
				en<=1;
				en2<=0;
				if(count<64) nextstate<=S1;
				else nextstate<=S2;
		end
		S2:begin
			en<=0;
			en2<=1;
			nextstate<=S0;
		end
	endcase
		


			sha256 #(PADDED_SIZE) main(padded, clk, reset, en,count, hashed);
	  
		
endmodule // sha_256

module sha_padder #(parameter MSG_SIZE = 24,
                    parameter PADDED_SIZE = 512)
   (input logic [MSG_SIZE-1:0] message,
    output logic [PADDED_SIZE-1:0] padded);

 //  localparam zero_width = PADDED_SIZE - MSG_SIZE - 64 - 1;
//	localparam backwidth = 64 - MSG_SIZE;

	assign padded = {message[23:0], 1'b1, {455{1'b0}}, MSG_SIZE};
endmodule // sha_padder

module sha256 #(parameter PADDED_SIZE = 512)
   (input logic [PADDED_SIZE-1:0] padded, input logic clk , reset, en, input logic [5:0]count,
    output logic [255:0] hashed);   

   logic [255:0] H = {32'h6a09e667, 32'hbb67ae85,
		      32'h3c6ef372, 32'ha54ff53a, 32'h510e527f, 32'h9b05688c,
		      32'h1f83d9ab, 32'h5be0cd19};   
	
   logic [2047:0] K = {32'h428a2f98, 32'h71374491, 32'hb5c0fbcf,
		       32'he9b5dba5, 32'h3956c25b, 32'h59f111f1, 32'h923f82a4,
		       32'hab1c5ed5, 32'hd807aa98, 32'h12835b01, 32'h243185be,
		       32'h550c7dc3, 32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7,
		       32'hc19bf174, 32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6,
		       32'h240ca1cc, 32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc,
		       32'h76f988da, 32'h983e5152, 32'ha831c66d, 32'hb00327c8,
		       32'hbf597fc7, 32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351,
		       32'h14292967, 32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc,
		       32'h53380d13, 32'h650a7354, 32'h766a0abb, 32'h81c2c92e,
		       32'h92722c85, 32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70,
		       32'hc76c51a3, 32'hd192e819, 32'hd6990624, 32'hf40e3585,
		       32'h106aa070, 32'h19a4c116, 32'h1e376c08, 32'h2748774c,
		       32'h34b0bcb5, 32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f,
		       32'h682e6ff3, 32'h748f82ee, 32'h78a5636f, 32'h84c87814,
		       32'h8cc70208, 32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7,
		       32'hc67178f2};

   // Define your intermediate variables here (forgetting them assumes variables are 1-bit)
  logic [31:0] a,b,c,d,e,f,g,h;
   logic [31:0]   a0_out, b0_out, c0_out, d0_out, e0_out, f0_out, g0_out, h0_out, regA_out, regB_out, regC_out,regD_out,regE_out,regF_out,regG_out,regH_out;
    logic [31:0] W0, W1, W2, W3, W4;
	 logic [31:0] W5, W6, W7, W8, W9;
	logic [31:0] W10, W11, W12, W13, W14; 
	 logic [31:0] W15, W16, W17, W18, W19;
	 logic [31:0] W20, W21, W22, W23, W24; 
	 logic [31:0] W25, W26, W27, W28, W29;
	logic [31:0] W30, W31, W32, W33, W34;
	 logic [31:0] W35, W36, W37, W38, W39;
	 logic [31:0] W40, W41, W42, W43, W44; 
	 logic [31:0] W45, W46, W47, W48, W49;
	 logic [31:0] W50, W51, W52, W53, W54; 
	 logic [31:0] W55, W56, W57, W58, W59;
	 logic [31:0] W60, W61, W62, W63;
    logic [31:0] h0o, h1o, h2o, h3o, h4o, h5o, h6o, h7o;
    logic [31:0] Kin, Win;
   

   // Initialize a through h



	
prepare p1 (padded[511:480], padded[479:448], padded[447:416],
               padded[415:384], padded[383:352], padded[351:320],
               padded[319:288], padded[287:256], padded[255:224],
               padded[223:192], padded[191:160], padded[159:128],
               padded[127:96], padded[95:64], padded[63:32],
               padded[31:0], W0, W1, W2, W3, W4, W5, W6, W7, W8, W9,
               W10, W11, W12, W13, W14, W15, W16, W17, W18, W19,
               W20, W21, W22, W23, W24, W25, W26, W27, W28, W29,
               W30, W31, W32, W33, W34, W35, W36, W37, W38, W39,
               W40, W41, W42, W43, W44, W45, W46, W47, W48, W49,
               W50, W51, W52, W53, W54, W55, W56, W57, W58, W59,
               W60, W61, W62, W63);



	
       
 
	
	always_ff @(posedge clk) begin
		if (count == 0) Win <= W0;
else if (count == 1) Win <= W1;
else if (count == 2) Win <= W2;
else if (count == 3) Win <= W3;
else if (count == 4) Win <= W4;
else if (count == 5) Win <= W5;
else if (count == 6) Win <= W6;
else if (count == 7) Win <= W7;
else if (count == 8) Win <= W8;
else if (count == 9) Win <= W9;
else if (count == 10) Win <= W10;
else if (count == 11) Win <= W11;
else if (count == 12) Win <= W12;
else if (count == 13) Win <= W13;
else if (count == 14) Win <= W14;
else if (count == 15) Win <= W15;
else if (count == 16) Win <= W16;
else if (count == 17) Win <= W17;
else if (count == 18) Win <= W18;
else if (count == 19) Win <= W19;
else if (count == 20) Win <= W20;
else if (count == 21) Win <= W21;
else if (count == 22) Win <= W22;
else if (count == 23) Win <= W23;
else if (count == 24) Win <= W24;
else if (count == 25) Win <= W25;
else if (count == 26) Win <= W26;
else if (count == 27) Win <= W27;
else if (count == 28) Win <= W28;
else if (count == 29) Win <= W29;
else if (count == 30) Win <= W30;
else if (count == 31) Win <= W31;
else if (count == 32) Win <= W32;
else if (count == 33) Win <= W33;
else if (count == 34) Win <= W34;
else if (count == 35) Win <= W35;
else if (count == 36) Win <= W36;
else if (count == 37) Win <= W37;
else if (count == 38) Win <= W38;
else if (count == 39) Win <= W39;
else if (count == 40) Win <= W40;
else if (count == 41) Win <= W41;
else if (count == 42) Win <= W42;
else if (count == 43) Win <= W43;
else if (count == 44) Win <= W44;
else if (count == 45) Win <= W45;
else if (count == 46) Win <= W46;
else if (count == 47) Win <= W47;
else if (count == 48) Win <= W48;
else if (count == 49) Win <= W49;
else if (count == 50) Win <= W50;
else if (count == 51) Win <= W51;
else if (count == 52) Win <= W52;
else if (count == 53) Win <= W53;
else if (count == 54) Win <= W54;
else if (count == 55) Win <= W55;
else if (count == 56) Win <= W56;
else if (count == 57) Win <= W57;
else if (count == 58) Win <= W58;
else if (count == 59) Win <= W59;
else if (count == 60) Win <= W60;
else if (count == 61) Win <= W61;
else if (count == 62) Win <= W62;
else if (count == 63) Win <= W63;
else Win <= 0;
	end


		always_ff @(posedge clk) begin
    if (count == 0) Kin <= K[2047:2016];
    else if (count == 1) Kin <= K[2015:1984];
    else if (count == 2) Kin <= K[1983:1952];
    else if (count == 3) Kin <= K[1951:1920];
    else if (count == 4) Kin <= K[1919:1888];
    else if (count == 5) Kin <= K[1887:1856];
    else if (count == 6) Kin <= K[1855:1824];
    else if (count == 7) Kin <= K[1823:1792];
    else if (count == 8) Kin <= K[1791:1760];
    else if (count == 9) Kin <= K[1759:1728];
    else if (count == 10) Kin <= K[1727:1696];
    else if (count == 11) Kin <= K[1695:1664];
    else if (count == 12) Kin <= K[1663:1632];
    else if (count == 13) Kin <= K[1631:1600];
    else if (count == 14) Kin <= K[1599:1568];
    else if (count == 15) Kin <= K[1567:1536];
    else if (count == 16) Kin <= K[1535:1504];
    else if (count == 17) Kin <= K[1503:1472];
    else if (count == 18) Kin <= K[1471:1440];
    else if (count == 19) Kin <= K[1439:1408];
    else if (count == 20) Kin <= K[1407:1376];
    else if (count == 21) Kin <= K[1375:1344];
    else if (count == 22) Kin <= K[1343:1312];
    else if (count == 23) Kin <= K[1311:1280];
    else if (count == 24) Kin <= K[1279:1248];
    else if (count == 25) Kin <= K[1247:1216];
    else if (count == 26) Kin <= K[1215:1184];
    else if (count == 27) Kin <= K[1183:1152];
    else if (count == 28) Kin <= K[1151:1120];
    else if (count == 29) Kin <= K[1119:1088];
    else if (count == 30) Kin <= K[1087:1056];
    else if (count == 31) Kin <= K[1055:1024];
    else if (count == 32) Kin <= K[1023:992];
    else if (count == 33) Kin <= K[991:960];
    else if (count == 34) Kin <= K[959:928];
    else if (count == 35) Kin <= K[927:896];
    else if (count == 36) Kin <= K[895:864];
    else if (count == 37) Kin <= K[863:832];
    else if (count == 38) Kin <= K[831:800];
    else if (count == 39) Kin <= K[799:768];
    else if (count == 40) Kin <= K[767:736];
    else if (count == 41) Kin <= K[735:704];
    else if (count == 42) Kin <= K[703:672];
    else if (count == 43) Kin <= K[671:640];
    else if (count == 44) Kin <= K[639:608];
    else if (count == 45) Kin <= K[607:576];
    else if (count == 46) Kin <= K[575:544];
    else if (count == 47) Kin <= K[543:512];
    else if (count == 48) Kin <= K[511:480];
    else if (count == 49) Kin <= K[479:448];
    else if (count == 50) Kin <= K[447:416];
    else if (count == 51) Kin <= K[415:384];
    else if (count == 52) Kin <= K[383:352];
    else if (count == 53) Kin <= K[351:320];
    else if (count == 54) Kin <= K[319:288];
    else if (count == 55) Kin <= K[287:256];
    else if (count == 56) Kin <= K[255:224];
    else if (count == 57) Kin <= K[223:192];
    else if (count == 58) Kin <= K[191:160];
    else if (count == 59) Kin <= K[159:128];
    else if (count == 60) Kin <= K[127:96];
    else if (count == 61) Kin <= K[95:64];
    else if (count == 62) Kin <= K[63:32];
    else if (count == 63) Kin <= K[31:0];
end

logic first;
 assign first = (count==0);
   assign a = first ? H[255:224] : regA_out;
   assign b = first ? H[223:192] : regB_out;
   assign c = first ? H[191:160] : regC_out;
   assign d = first ? H[159:128] : regD_out;
   assign e = first ? H[127:96] : regE_out;
   assign f = first ? H[95:64] : regF_out;
   assign g = first ? H[63:32] : regG_out;
   assign h = first ? H[31:0] : regH_out;

 main_comp mc01 (a, b, c, d, e, f, g, h,
		   Kin, Win,
		   a0_out, b0_out, c0_out, d0_out, 
		   e0_out, f0_out, g0_out, h0_out);


		         flopenr #(32) regA (clk, reset, en, a0_out, regA_out);
			     flopenr #(32) regB (clk, reset, en, b0_out, regB_out);
				 flopenr #(32) regC (clk, reset, en, c0_out, regC_out);
			     flopenr #(32) regD (clk, reset, en, d0_out, regD_out);
				 flopenr #(32) regE (clk, reset, en, e0_out, regE_out);
			     flopenr #(32) regF (clk, reset, en, f0_out, regF_out);
				 flopenr #(32) regG (clk, reset, en, g0_out, regG_out);
			     flopenr #(32) regH (clk, reset, en, h0_out, regH_out);



				 




intermediate_hash ih1 (a, b, c, d, e, f, g, h, regA_out,regB_out,regC_out,regD_out,regE_out,regF_out,regG_out,regH_out,
			   			   
			   			   h0o, h1o, h2o, h3o, h4o, h5o, h6o, h7o);



flopenrhashed #(256) reghashed (clk, reset, en2, h0o, h1o, h2o, h3o, h4o, h5o, h6o, h7o,hashed);
				 
	
   // Final output


endmodule // sha_main

module prepare (input logic [31:0] M0, M1, M2, M3,
		input logic [31:0]  M4, M5, M6, M7,
		input logic [31:0]  M8, M9, M10, M11,
		input logic [31:0]  M12, M13, M14, M15,
		output logic [31:0] W0, W1, W2, W3, W4, 
		output logic [31:0] W5, W6, W7, W8, W9,
		output logic [31:0] W10, W11, W12, W13, W14, 
		output logic [31:0] W15, W16, W17, W18, W19,
		output logic [31:0] W20, W21, W22, W23, W24,
		output logic [31:0] W25, W26, W27, W28, W29,
		output logic [31:0] W30, W31, W32, W33, W34, 
		output logic [31:0] W35, W36, W37, W38, W39,
		output logic [31:0] W40, W41, W42, W43, W44, 
		output logic [31:0] W45, W46, W47, W48, W49,
		output logic [31:0] W50, W51, W52, W53, W54, 
		output logic [31:0] W55, W56, W57, W58, W59,
		output logic [31:0] W60, W61, W62, W63);

	logic [31:0] W14_sigma1_out,
W15_sigma1_out,
W16_sigma1_out,
W17_sigma1_out,
W18_sigma1_out,
W19_sigma1_out,
W20_sigma1_out,
W21_sigma1_out,
W22_sigma1_out,
W23_sigma1_out,
W24_sigma1_out,
W25_sigma1_out,
W26_sigma1_out,
W27_sigma1_out,
W28_sigma1_out,
W29_sigma1_out,
W30_sigma1_out,
W31_sigma1_out,
W32_sigma1_out,
W33_sigma1_out,
W34_sigma1_out,
W35_sigma1_out,
W36_sigma1_out,
W37_sigma1_out,
W38_sigma1_out,
W39_sigma1_out,
W40_sigma1_out,
W41_sigma1_out,
W42_sigma1_out,
W43_sigma1_out,
W44_sigma1_out,
W45_sigma1_out,
W46_sigma1_out,
W47_sigma1_out,
W48_sigma1_out,
W49_sigma1_out,
W50_sigma1_out,
W51_sigma1_out,
W52_sigma1_out,
W53_sigma1_out,
W54_sigma1_out,
W55_sigma1_out,
W56_sigma1_out,
W57_sigma1_out,
W58_sigma1_out,
W59_sigma1_out,
W60_sigma1_out,
W61_sigma1_out,
W1_sigma0_out,
W2_sigma0_out,
W3_sigma0_out,
W4_sigma0_out,
W5_sigma0_out,
W6_sigma0_out,
W7_sigma0_out,
W8_sigma0_out,
W9_sigma0_out,
W10_sigma0_out,
W11_sigma0_out,
W12_sigma0_out,
W13_sigma0_out,
W14_sigma0_out,
W15_sigma0_out,
W16_sigma0_out,
W17_sigma0_out,
W18_sigma0_out,
W19_sigma0_out,
W20_sigma0_out,
W21_sigma0_out,
W22_sigma0_out,
W23_sigma0_out,
W24_sigma0_out,
W25_sigma0_out,
W26_sigma0_out,
W27_sigma0_out,
W28_sigma0_out,
W29_sigma0_out,
W30_sigma0_out,
W31_sigma0_out,
W32_sigma0_out,
W33_sigma0_out,
W34_sigma0_out,
W35_sigma0_out,
W36_sigma0_out,
W37_sigma0_out,
W38_sigma0_out,
W39_sigma0_out,
W40_sigma0_out,
W41_sigma0_out,
W42_sigma0_out,
W43_sigma0_out,
W44_sigma0_out,
W45_sigma0_out,
W46_sigma0_out,
W47_sigma0_out,
W48_sigma0_out;


	
	assign W0 = M0;
	assign W1 = M1;
	assign W2 = M2;
	assign W3 = M3;
	assign W4 = M4;
	assign W5 = M5;
	assign W6 = M6;
	assign W7 = M7;
	assign W8 = M8;
	assign W9 = M9;
	assign W10 = M10;
	assign W11 = M11;
	assign W12 = M12;
	assign W13 = M13;
	assign W14 = M14;
	assign W15 = M15;

	
	
// sigma 1 (see bottom of page 6)
	sigma1 sig1_1 (W14, W14_sigma1_out);
	sigma1 sig1_2 (W15, W15_sigma1_out);
	sigma1 sig1_3 (W16, W16_sigma1_out);
	sigma1 sig1_4 (W17, W17_sigma1_out);
	sigma1 sig1_5 (W18, W18_sigma1_out);
	sigma1 sig1_6 (W19, W19_sigma1_out);
	sigma1 sig1_7 (W20, W20_sigma1_out);
	sigma1 sig1_8 (W21, W21_sigma1_out);
	sigma1 sig1_9 (W22, W22_sigma1_out);
	sigma1 sig1_10 (W23, W23_sigma1_out);
	sigma1 sig1_11 (W24, W24_sigma1_out);
	sigma1 sig1_12 (W25, W25_sigma1_out);
	sigma1 sig1_13 (W26, W26_sigma1_out);
	sigma1 sig1_14 (W27, W27_sigma1_out);
	sigma1 sig1_15 (W28, W28_sigma1_out);
	sigma1 sig1_16 (W29, W29_sigma1_out);
	sigma1 sig1_17 (W30, W30_sigma1_out);
	sigma1 sig1_18 (W31, W31_sigma1_out);
	sigma1 sig1_19 (W32, W32_sigma1_out);
	sigma1 sig1_20 (W33, W33_sigma1_out);
	sigma1 sig1_21 (W34, W34_sigma1_out);
	sigma1 sig1_22 (W35, W35_sigma1_out);
	sigma1 sig1_23 (W36, W36_sigma1_out);
	sigma1 sig1_24 (W37, W37_sigma1_out);
	sigma1 sig1_25 (W38, W38_sigma1_out);
	sigma1 sig1_26 (W39, W39_sigma1_out);
	sigma1 sig1_27 (W40, W40_sigma1_out);
	sigma1 sig1_28 (W41, W41_sigma1_out);
	sigma1 sig1_29 (W42, W42_sigma1_out);
	sigma1 sig1_30 (W43, W43_sigma1_out);
	sigma1 sig1_31 (W44, W44_sigma1_out);
	sigma1 sig1_32 (W45, W45_sigma1_out);
	sigma1 sig1_33 (W46, W46_sigma1_out);
	sigma1 sig1_34 (W47, W47_sigma1_out);
	sigma1 sig1_35 (W48, W48_sigma1_out);
	sigma1 sig1_36 (W49, W49_sigma1_out);
	sigma1 sig1_37 (W50, W50_sigma1_out);
	sigma1 sig1_38 (W51, W51_sigma1_out);
	sigma1 sig1_39 (W52, W52_sigma1_out);
	sigma1 sig1_40 (W53, W53_sigma1_out);
	sigma1 sig1_41 (W54, W54_sigma1_out);
	sigma1 sig1_42 (W55, W55_sigma1_out);
	sigma1 sig1_43 (W56, W56_sigma1_out);
	sigma1 sig1_44 (W57, W57_sigma1_out);
	sigma1 sig1_45 (W58, W58_sigma1_out);
	sigma1 sig1_46 (W59, W59_sigma1_out);
	sigma1 sig1_47 (W60, W60_sigma1_out);
	sigma1 sig1_48 (W61, W61_sigma1_out);




   // sigma 0 (see bottom of page 6)
	sigma0 sig0_1 (W1, W1_sigma0_out);
	sigma0 sig0_2 (W2, W2_sigma0_out);
	sigma0 sig0_3 (W3, W3_sigma0_out);
	sigma0 sig0_4 (W4, W4_sigma0_out);
	sigma0 sig0_5 (W5, W5_sigma0_out);
	sigma0 sig0_6 (W6, W6_sigma0_out);
	sigma0 sig0_7 (W7, W7_sigma0_out);
	sigma0 sig0_8 (W8, W8_sigma0_out);
	sigma0 sig0_9 (W9, W9_sigma0_out);
	sigma0 sig0_10 (W10, W10_sigma0_out);
	sigma0 sig0_11 (W11, W11_sigma0_out);
	sigma0 sig0_12 (W12, W12_sigma0_out);
	sigma0 sig0_13 (W13, W13_sigma0_out);
	sigma0 sig0_14 (W14, W14_sigma0_out);
	sigma0 sig0_15 (W15, W15_sigma0_out);
	sigma0 sig0_16 (W16, W16_sigma0_out);
	sigma0 sig0_17 (W17, W17_sigma0_out);
	sigma0 sig0_18 (W18, W18_sigma0_out);
	sigma0 sig0_19 (W19, W19_sigma0_out);
	sigma0 sig0_20 (W20, W20_sigma0_out);
	sigma0 sig0_21 (W21, W21_sigma0_out);
	sigma0 sig0_22 (W22, W22_sigma0_out);
	sigma0 sig0_23 (W23, W23_sigma0_out);
	sigma0 sig0_24 (W24, W24_sigma0_out);
	sigma0 sig0_25 (W25, W25_sigma0_out);
	sigma0 sig0_26 (W26, W26_sigma0_out);
	sigma0 sig0_27 (W27, W27_sigma0_out);
	sigma0 sig0_28 (W28, W28_sigma0_out);
	sigma0 sig0_29 (W29, W29_sigma0_out);
	sigma0 sig0_30 (W30, W30_sigma0_out);
	sigma0 sig0_31 (W31, W31_sigma0_out);
	sigma0 sig0_32 (W32, W32_sigma0_out);
	sigma0 sig0_33 (W33, W33_sigma0_out);
	sigma0 sig0_34 (W34, W34_sigma0_out);
	sigma0 sig0_35 (W35, W35_sigma0_out);
	sigma0 sig0_36 (W36, W36_sigma0_out);
	sigma0 sig0_37 (W37, W37_sigma0_out);
	sigma0 sig0_38 (W38, W38_sigma0_out);
	sigma0 sig0_39 (W39, W39_sigma0_out);
	sigma0 sig0_40 (W40, W40_sigma0_out);
	sigma0 sig0_41 (W41, W41_sigma0_out);
	sigma0 sig0_42 (W42, W42_sigma0_out);
	sigma0 sig0_43 (W43, W43_sigma0_out);
	sigma0 sig0_44 (W44, W44_sigma0_out);
	sigma0 sig0_45 (W45, W45_sigma0_out);
	sigma0 sig0_46 (W46, W46_sigma0_out);
	sigma0 sig0_47 (W47, W47_sigma0_out);
	sigma0 sig0_48 (W48, W48_sigma0_out);

   // fill in other sigma0 blocks

   // Equation for W_i (top of page 7)
	assign W16 = W14_sigma1_out + W9 + W1_sigma0_out + W0;
	assign W17 = W15_sigma1_out + W10 + W2_sigma0_out + W1;
	assign W18 = W16_sigma1_out + W11 + W3_sigma0_out + W2;
	assign W19 = W17_sigma1_out + W12 + W4_sigma0_out + W3;
	assign W20 = W18_sigma1_out + W13 + W5_sigma0_out + W4;
	assign W21 = W19_sigma1_out + W14 + W6_sigma0_out + W5;
	assign W22 = W20_sigma1_out + W15 + W7_sigma0_out + W6;
	assign W23 = W21_sigma1_out + W16 + W8_sigma0_out + W7;
	assign W24 = W22_sigma1_out + W17 + W9_sigma0_out + W8;
	assign W25 = W23_sigma1_out + W18 + W10_sigma0_out + W9;
	assign W26 = W24_sigma1_out + W19 + W11_sigma0_out + W10;
	assign W27 = W25_sigma1_out + W20 + W12_sigma0_out + W11;
	assign W28 = W26_sigma1_out + W21 + W13_sigma0_out + W12;
	assign W29 = W27_sigma1_out + W22 + W14_sigma0_out + W13;
	assign W30 = W28_sigma1_out + W23 + W15_sigma0_out + W14;
	assign W31 = W29_sigma1_out + W24 + W16_sigma0_out + W15;
	assign W32 = W30_sigma1_out + W25 + W17_sigma0_out + W16;
	assign W33 = W31_sigma1_out + W26 + W18_sigma0_out + W17;
	assign W34 = W32_sigma1_out + W27 + W19_sigma0_out + W18;
	assign W35 = W33_sigma1_out + W28 + W20_sigma0_out + W19;
	assign W36 = W34_sigma1_out + W29 + W21_sigma0_out + W20;
	assign W37 = W35_sigma1_out + W30 + W22_sigma0_out + W21;
	assign W38 = W36_sigma1_out + W31 + W23_sigma0_out + W22;
	assign W39 = W37_sigma1_out + W32 + W24_sigma0_out + W23;
	assign W40 = W38_sigma1_out + W33 + W25_sigma0_out + W24;
	assign W41 = W39_sigma1_out + W34 + W26_sigma0_out + W25;
	assign W42 = W40_sigma1_out + W35 + W27_sigma0_out + W26;
	assign W43 = W41_sigma1_out + W36 + W28_sigma0_out + W27;
	assign W44 = W42_sigma1_out + W37 + W29_sigma0_out + W28;
	assign W45 = W43_sigma1_out + W38 + W30_sigma0_out + W29;
	assign W46 = W44_sigma1_out + W39 + W31_sigma0_out + W30;
	assign W47 = W45_sigma1_out + W40 + W32_sigma0_out + W31;
	assign W48 = W46_sigma1_out + W41 + W33_sigma0_out + W32;
	assign W49 = W47_sigma1_out + W42 + W34_sigma0_out + W33;
	assign W50 = W48_sigma1_out + W43 + W35_sigma0_out + W34;
	assign W51 = W49_sigma1_out + W44 + W36_sigma0_out + W35;
	assign W52 = W50_sigma1_out + W45 + W37_sigma0_out + W36;
	assign W53 = W51_sigma1_out + W46 + W38_sigma0_out + W37;
	assign W54 = W52_sigma1_out + W47 + W39_sigma0_out + W38;
	assign W55 = W53_sigma1_out + W48 + W40_sigma0_out + W39;
	assign W56 = W54_sigma1_out + W49 + W41_sigma0_out + W40;
	assign W57 = W55_sigma1_out + W50 + W42_sigma0_out + W41;
	assign W58 = W56_sigma1_out + W51 + W43_sigma0_out + W42;
	assign W59 = W57_sigma1_out + W52 + W44_sigma0_out + W43;
	assign W60 = W58_sigma1_out + W53 + W45_sigma0_out + W44;
	assign W61 = W59_sigma1_out + W54 + W46_sigma0_out + W45;
	assign W62 = W60_sigma1_out + W55 + W47_sigma0_out + W46;
	assign W63 = W61_sigma1_out + W56 + W48_sigma0_out + W47;

	
endmodule // prepare


module main_comp (input logic [31:0] a_in, b_in, c_in, d_in, e_in, f_in, g_in, h_in,
		  input logic [31:0] K_in, W_in,
		  output logic [31:0] a_out, b_out, c_out, d_out, e_out, f_out, g_out,
		  output logic [31:0] h_out);


	logic[31:0] T1, T2;

	logic [31:0] s1, s0, cho, maj;
	Sigma1 S1(e_in, s1);
	choice cho1(e_in, f_in, g_in, cho);
	Sigma0 S0(a_in, s0);
	majority Maj(a_in, b_in, c_in, maj);

	assign T1 = h_in[31:0] + s1[31:0] + cho[31:0] + K_in[31:0] + W_in[31:0];
	assign T2 = s0[31:0] + maj[31:0];

	assign a_out = T1 + T2;
	assign b_out = a_in;
	assign c_out = b_in;
	assign d_out = c_in;
	assign e_out = d_in + T1;
	assign f_out = e_in;
	assign g_out = f_in;
	assign h_out = g_in;

endmodule // main_comp

module intermediate_hash (input logic [31:0] a_in, b_in, c_in, d_in, e_in, f_in, g_in, h_in,
			  input logic [31:0]  h0_in, h1_in, h2_in, h3_in, h4_in, h5_in, h6_in, h7_in, 
			  output logic [31:0] h0_out, h1_out, h2_out, h3_out, h4_out, h5_out, h6_out, h7_out);

   assign h0_out = a_in + h0_in;
   assign h1_out = b_in + h1_in;
   assign h2_out = c_in + h2_in;
   assign h3_out = d_in + h3_in;
   assign h4_out = e_in + h4_in;
   assign h5_out = f_in + h5_in;
   assign h6_out = g_in + h6_in;
   assign h7_out = h_in + h7_in;
   
endmodule
			  
module majority (input logic [31:0] x, y, z, output logic [31:0] maj);
	assign maj = (x & y) ^ (x & z) ^ (y & z);

endmodule // majority

module choice (input logic [31:0] x, y, z, output logic [31:0] ch);
	assign ch = (x & y) ^ (~x & z);

endmodule // choice

module Sigma0 (input logic [31:0] x, output logic [31:0] Sig0);
	assign Sig0 = ({x[1:0],x[31:2]}) ^ ({x[12:0], x[31:13]}) ^ ({x[21:0], x[31:22]});

endmodule // Sigma0

module sigma0 (input logic [31:0] x, output logic [31:0] sigma0);
	assign sigma0 = ({x[6:0],x[31:7]}) ^ ({x[17:0], x[31:18]}) ^ (x>>3);

endmodule // sigma0

module Sigma1 (input logic [31:0] x, output logic [31:0] Sig1);
	assign Sig1 = ({x[5:0],x[31:6]}) ^ ({x[10:0], x[31:11]}) ^ ({x[24:0], x[31:25]});

endmodule // Sigma1

module sigma1 (input logic [31:0] x, output logic [31:0] sigma1);
	assign sigma1 = ({x[16:0],x[31:17]}) ^ ({x[18:0], x[31:19]}) ^ (x>>10);

endmodule// sigma1

     
   
