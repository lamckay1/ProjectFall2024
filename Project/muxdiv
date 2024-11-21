module mux(input logic [3:0] sel, input logic [255:0] result, output logic [15:0] s);


always_comb begin
        case(sel)
          4'b0000: s = result[15:0];
          4'b0001: s = result[31:16];
          4'b0010: s = result[47:32];
          4'b0011: s = result[63:48];
          4'b0100: s = result[79:64];
          4'b0101: s = result[95:80];
          4'b0110: s = result[111:96];
          4'b0111: s = result[127:112];
          4'b1000: s = result[143:128];
          4'b1001: s = result[159:144];
          4'b1010: s = result[175:160];
          4'b1011: s = result[191:176];
          4'b1100: s = result[207:192];
          4'b1101: s = result[223:208];
          4'b1110: s = result[239:224];
          4'b1111: s = result[255:240];
          
        
        endcase
 end
endmodule
