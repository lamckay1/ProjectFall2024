///////////////////////////////////////////
// mux.sv
//
// Written: David_Harris@hmc.edu 9 January 2021
// Modified: 
//
// Purpose: Various flavors of multiplexers
// 
// A component of the CORE-V-WALLY configurable RISC-V project.
// 
// Copyright (C) 2021-23 Harvey Mudd College & Oklahoma State University
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may not use this file 
// except in compliance with the License, or, at your option, the Apache License version 2.0. You 
// may obtain a copy of the License at
//
// https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work distributed under the 
// License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 
// and limitations under the License.
////////////////////////////////////////////////////////////////////////////////////////////////

/* verilator lint_off DECLFILENAME */

module mux2 #(parameter WIDTH = 8) (
  input  logic [WIDTH-1:0] d0, d1, 
  input  logic             s, 
  output logic [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule

module mux3 #(parameter WIDTH = 8) (
  input  logic [WIDTH-1:0] d0, d1, d2,
  input  logic [1:0]       s, 
  output logic [WIDTH-1:0] y);

  assign y = s[1] ? d2 : (s[0] ? d1 : d0); // exclusion-tag: mux3
endmodule

module mux4 #(parameter WIDTH = 8) (
  input  logic [WIDTH-1:0] d0, d1, d2, d3,
  input  logic [1:0]       s, 
  output logic [WIDTH-1:0] y);

  assign y = s[1] ? (s[0] ? d3 : d2) : (s[0] ? d1 : d0); 
endmodule

module mux_W (
    input  logic [31:0] d0,  d1,  d2,  d3,  d4,  d5,  d6,  d7,  d8,  d9,  d10, d11, d12, d13, d14, d15,
                       d16, d17, d18, d19, d20, d21, d22, d23, d24, d25, d26, d27, d28, d29, d30, d31,
                       d32, d33, d34, d35, d36, d37, d38, d39, d40, d41, d42, d43, d44, d45, d46, d47,
                       d48, d49, d50, d51, d52, d53, d54, d55, d56, d57, d58, d59, d60, d61, d62, d63,
    input  logic [5:0]  s, 
    output logic [31:0] y
);

    always_comb begin
        case (s)
            6'd63: y = d63;
            6'd62: y = d62;
            6'd61: y = d61;
            6'd60: y = d60;
            6'd59: y = d59;
            6'd58: y = d58;
            6'd57: y = d57;
            6'd56: y = d56;
            6'd55: y = d55;
            6'd54: y = d54;
            6'd53: y = d53;
            6'd52: y = d52;
            6'd51: y = d51;
            6'd50: y = d50;
            6'd49: y = d49;
            6'd48: y = d48;
            6'd47: y = d47;
            6'd46: y = d46;
            6'd45: y = d45;
            6'd44: y = d44;
            6'd43: y = d43;
            6'd42: y = d42;
            6'd41: y = d41;
            6'd40: y = d40;
            6'd39: y = d39;
            6'd38: y = d38;
            6'd37: y = d37;
            6'd36: y = d36;
            6'd35: y = d35;
            6'd34: y = d34;
            6'd33: y = d33;
            6'd32: y = d32;
            6'd31: y = d31;
            6'd30: y = d30;
            6'd29: y = d29;
            6'd28: y = d28;
            6'd27: y = d27;
            6'd26: y = d26;
            6'd25: y = d25;
            6'd24: y = d24;
            6'd23: y = d23;
            6'd22: y = d22;
            6'd21: y = d21;
            6'd20: y = d20;
            6'd19: y = d19;
            6'd18: y = d18;
            6'd17: y = d17;
            6'd16: y = d16;
            6'd15: y = d15;
            6'd14: y = d14;
            6'd13: y = d13;
            6'd12: y = d12;
            6'd11: y = d11;
            6'd10: y = d10;
            6'd9:  y = d9;
            6'd8:  y = d8;
            6'd7:  y = d7;
            6'd6:  y = d6;
            6'd5:  y = d5;
            6'd4:  y = d4;
            6'd3:  y = d3;
            6'd2:  y = d2;
            6'd1:  y = d1;
            6'd0:  y = d0;
            default: y = 32'b0;
        endcase
    end
endmodule


module mux_K (
    input  logic [31:0] d0,  d1,  d2,  d3,  d4,  d5,  d6,  d7,  d8,  d9,  d10, d11, d12, d13, d14, d15,
                       d16, d17, d18, d19, d20, d21, d22, d23, d24, d25, d26, d27, d28, d29, d30, d31,
                       d32, d33, d34, d35, d36, d37, d38, d39, d40, d41, d42, d43, d44, d45, d46, d47,
                       d48, d49, d50, d51, d52, d53, d54, d55, d56, d57, d58, d59, d60, d61, d62, d63,
    input  logic [5:0]  s, 
    output logic [31:0] y
);

    always_comb begin
        case (s)
            6'd63: y = d0;
            6'd62: y = d1;
            6'd61: y = d2;
            6'd60: y = d3;
            6'd59: y = d4;
            6'd58: y = d5;
            6'd57: y = d6;
            6'd56: y = d7;
            6'd55: y = d8;
            6'd54: y = d9;
            6'd53: y = d10;
            6'd52: y = d11;
            6'd51: y = d12;
            6'd50: y = d13;
            6'd49: y = d14;
            6'd48: y = d15;
            6'd47: y = d16;
            6'd46: y = d17;
            6'd45: y = d18;
            6'd44: y = d19;
            6'd43: y = d20;
            6'd42: y = d21;
            6'd41: y = d22;
            6'd40: y = d23;
            6'd39: y = d24;
            6'd38: y = d25;
            6'd37: y = d26;
            6'd36: y = d27;
            6'd35: y = d28;
            6'd34: y = d29;
            6'd33: y = d30;
            6'd32: y = d31;
            6'd31: y = d32;
            6'd30: y = d33;
            6'd29: y = d34;
            6'd28: y = d35;
            6'd27: y = d36;
            6'd26: y = d37;
            6'd25: y = d38;
            6'd24: y = d39;
            6'd23: y = d40;
            6'd22: y = d41;
            6'd21: y = d42;
            6'd20: y = d43;
            6'd19: y = d44;
            6'd18: y = d45;
            6'd17: y = d46;
            6'd16: y = d47;
            6'd15: y = d48;
            6'd14: y = d49;
            6'd13: y = d50;
            6'd12: y = d51;
            6'd11: y = d52;
            6'd10: y = d53;
            6'd9:  y = d54;
            6'd8:  y = d55;
            6'd7:  y = d56;
            6'd6:  y = d57;
            6'd5:  y = d58;
            6'd4:  y = d59;
            6'd3:  y = d60;
            6'd2:  y = d61;
            6'd1:  y = d62;
            6'd0:  y = d63;
            default: y = 32'b0;
        endcase
    end
endmodule



module mux16 #(parameter WIDTH = 8)
   (input logic [WIDTH-1:0] d0, d1, d2, d3, d4, input [3:0] s,
    output logic [WIDTH-1:0] y);

   always_comb
     case(s)
       4'b0001: y = d0;
       4'b0010: y = d1;
       4'b0100: y = d2;
       4'b1000: y = d3;
       default: y = d4;
     endcase // case (s)
endmodule // mux16

/* verilator lint_on DECLFILENAME */
