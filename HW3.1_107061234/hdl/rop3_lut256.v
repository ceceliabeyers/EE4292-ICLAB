/*
* Module      : rop3_lut256
* Description : Implement this module using the look-up table (LUT) 
*               This module should support all the possible modes of ROP3.
* Notes       : Please remember to
*               (1) make the bit-length of {P, S, D, Result} parameterizable
*               (2) make the input/output to be a register
*/

module rop3_lut256
#(
  parameter N = 32
)
(
  input clk,
  input [N-1:0] P,
  input [N-1:0] S,
  input [N-1:0] D,
  input [7:0] Mode,
  output reg [N-1:0] Result
);

reg [N-1:0] P_in;
reg [N-1:0] S_in;
reg [N-1:0] D_in;
reg [7:0] Mode_in;
reg [N-1:0] Result_nx;

always@(posedge clk) begin
	P_in <= P;
	S_in <= S;
	D_in <= D;
	Mode_in <= Mode;
	Result <= Result_nx;
end

always@* begin
	case(Mode_in)
		8'h00: Result_nx = 0;
		8'h01: Result_nx = (~P_in)&(~S_in)&(~D_in);
		8'h02: Result_nx = (~P_in)&(~S_in)&D_in;
		8'h03: Result_nx = (~P_in)&(~S_in);
		8'h04: Result_nx = (~P_in)&S_in&(~D_in);
		8'h05: Result_nx = (~P_in)&(~D_in);
		8'h06: Result_nx = ((~P_in)&(~S_in)&D_in)|((~P_in)&S_in&(~D_in));
		8'h07: Result_nx = ((~P_in)&(~D_in))|((~P_in)&(~S_in));
		8'h08: Result_nx = (~P_in)&S_in&D_in;
		8'h09: Result_nx = ((~P_in)&S_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'h0A: Result_nx = (~P_in)&D_in;
		8'h0B: Result_nx = ((~P_in)&D_in)|((~P_in)&(~S_in));
		8'h0C: Result_nx = (~P_in)&S_in;
		8'h0D: Result_nx = ((~P_in)&S_in)|((~P_in)&(~D_in));
		8'h0E: Result_nx = ((~P_in)&S_in)|((~P_in)&D_in);
		8'h0F: Result_nx = (~P_in);
		8'h10: Result_nx = P_in&(~S_in)&(~D_in);
		8'h11: Result_nx = (P_in&(~S_in)&(~D_in))|((~P_in)&(~S_in)&(~D_in));
		8'h12: Result_nx = (P_in&(~S_in)&(~D_in))|((~P_in)&(~S_in)&D_in);
		8'h13: Result_nx = (P_in&(~S_in)&(~D_in))|((~P_in)&(~S_in));
		8'h14: Result_nx = (P_in&(~S_in)&(~D_in))|((~P_in)&S_in&(~D_in));
		8'h15: Result_nx = (P_in&(~S_in)&(~D_in))|((~P_in)&(~D_in));
		8'h16: Result_nx = (P_in&(~S_in)&(~D_in))|((~P_in)&(~S_in)&D_in)|((~P_in)&S_in&(~D_in));
		8'h17: Result_nx = (P_in&(~S_in)&(~D_in))|((~P_in)&(~D_in))|((~P_in)&(~S_in));
		8'h18: Result_nx = (P_in&(~S_in)&(~D_in))|((~P_in)&S_in&D_in);
		8'h19: Result_nx = (P_in&(~S_in)&(~D_in))|((~P_in)&S_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'h1A: Result_nx = (P_in&(~S_in)&(~D_in))|((~P_in)&D_in);
		8'h1B: Result_nx = (P_in&(~S_in)&(~D_in))|((~P_in)&D_in)|((~P_in)&(~S_in));
		8'h1C: Result_nx = (P_in&(~S_in)&(~D_in))|((~P_in)&S_in);
		8'h1D: Result_nx = (P_in&(~S_in)&(~D_in))|((~P_in)&S_in)|((~P_in)&(~D_in));
		8'h1E: Result_nx = (P_in&(~S_in)&(~D_in))|((~P_in)&S_in)|((~P_in)&D_in);
		8'h1F: Result_nx = (P_in&(~S_in)&(~D_in))|(~P_in);
		8'h20: Result_nx = P_in&(~S_in)&D_in;
		8'h21: Result_nx = (P_in&(~S_in)&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'h22: Result_nx = (P_in&(~S_in)&D_in)|((~P_in)&(~S_in)&D_in);
		8'h23: Result_nx = (P_in&(~S_in)&D_in)|((~P_in)&(~S_in));
		8'h24: Result_nx = (P_in&(~S_in)&D_in)|((~P_in)&S_in&(~D_in));
		8'h25: Result_nx = (P_in&(~S_in)&D_in)|((~P_in)&(~D_in));
		8'h26: Result_nx = (P_in&(~S_in)&D_in)|((~P_in)&(~S_in)&D_in)|((~P_in)&S_in&(~D_in));
		8'h27: Result_nx = (P_in&(~S_in)&D_in)|((~P_in)&(~D_in))|((~P_in)&(~S_in));
		8'h28: Result_nx = (P_in&(~S_in)&D_in)|((~P_in)&S_in&D_in);
		8'h29: Result_nx = (P_in&(~S_in)&D_in)|((~P_in)&S_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'h2A: Result_nx = (P_in&(~S_in)&D_in)|((~P_in)&D_in);
		8'h2B: Result_nx = (P_in&(~S_in)&D_in)|((~P_in)&D_in)|((~P_in)&(~S_in));
		8'h2C: Result_nx = (P_in&(~S_in)&D_in)|((~P_in)&S_in);
		8'h2D: Result_nx = (P_in&(~S_in)&D_in)|((~P_in)&S_in)|((~P_in)&(~D_in));
		8'h2E: Result_nx = (P_in&(~S_in)&D_in)|((~P_in)&S_in)|((~P_in)&D_in);
		8'h2F: Result_nx = (P_in&(~S_in)&D_in)|(~P_in);
		8'h30: Result_nx = P_in&(~S_in);
		8'h31: Result_nx = (P_in&(~S_in))|((~P_in)&(~S_in)&(~D_in));
		8'h32: Result_nx = (P_in&(~S_in))|((~P_in)&(~S_in)&D_in);
		8'h33: Result_nx = (P_in&(~S_in))|((~P_in)&(~S_in));
		8'h34: Result_nx = (P_in&(~S_in))|((~P_in)&S_in&(~D_in));
		8'h35: Result_nx = (P_in&(~S_in))|((~P_in)&(~D_in));
		8'h36: Result_nx = (P_in&(~S_in))|((~P_in)&(~S_in)&D_in)|((~P_in)&S_in&(~D_in));
		8'h37: Result_nx = (P_in&(~S_in))|((~P_in)&(~D_in))|((~P_in)&(~S_in));
		8'h38: Result_nx = (P_in&(~S_in))|((~P_in)&S_in&D_in);
		8'h39: Result_nx = (P_in&(~S_in))|((~P_in)&S_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'h3A: Result_nx = (P_in&(~S_in))|((~P_in)&D_in);
		8'h3B: Result_nx = (P_in&(~S_in))|((~P_in)&D_in)|((~P_in)&(~S_in));
		8'h3C: Result_nx = (P_in&(~S_in))|((~P_in)&S_in);
		8'h3D: Result_nx = (P_in&(~S_in))|((~P_in)&S_in)|((~P_in)&(~D_in));
		8'h3E: Result_nx = (P_in&(~S_in))|((~P_in)&S_in)|((~P_in)&D_in);
		8'h3F: Result_nx = (P_in&(~S_in))|(~P_in);
		8'h40: Result_nx = P_in&S_in&(~D_in);
		8'h41: Result_nx = (P_in&S_in&(~D_in))|((~P_in)&(~S_in)&(~D_in));
		8'h42: Result_nx = (P_in&S_in&(~D_in))|((~P_in)&(~S_in)&D_in);
		8'h43: Result_nx = (P_in&S_in&(~D_in))|((~P_in)&(~S_in));
		8'h44: Result_nx = (P_in&S_in&(~D_in))|((~P_in)&S_in&(~D_in));
		8'h45: Result_nx = (P_in&S_in&(~D_in))|((~P_in)&(~D_in));
		8'h46: Result_nx = (P_in&S_in&(~D_in))|((~P_in)&(~S_in)&D_in)|((~P_in)&S_in&(~D_in));
		8'h47: Result_nx = (P_in&S_in&(~D_in))|((~P_in)&(~D_in))|((~P_in)&(~S_in));
		8'h48: Result_nx = (P_in&S_in&(~D_in))|((~P_in)&S_in&D_in);
		8'h49: Result_nx = (P_in&S_in&(~D_in))|((~P_in)&S_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'h4A: Result_nx = (P_in&S_in&(~D_in))|((~P_in)&D_in);
		8'h4B: Result_nx = (P_in&S_in&(~D_in))|((~P_in)&D_in)|((~P_in)&(~S_in));
		8'h4C: Result_nx = (P_in&S_in&(~D_in))|((~P_in)&S_in);
		8'h4D: Result_nx = (P_in&S_in&(~D_in))|((~P_in)&S_in)|((~P_in)&(~D_in));
		8'h4E: Result_nx = (P_in&S_in&(~D_in))|((~P_in)&S_in)|((~P_in)&D_in);
		8'h4F: Result_nx = (P_in&S_in&(~D_in))|(~P_in);
		8'h50: Result_nx = P_in&(~D_in);
		8'h51: Result_nx = (P_in&(~D_in))|((~P_in)&(~S_in)&(~D_in));
		8'h52: Result_nx = (P_in&(~D_in))|((~P_in)&(~S_in)&D_in);
		8'h53: Result_nx = (P_in&(~D_in))|((~P_in)&(~S_in));
		8'h54: Result_nx = (P_in&(~D_in))|((~P_in)&S_in&(~D_in));
		8'h55: Result_nx = (P_in&(~D_in))|((~P_in)&(~D_in));
		8'h56: Result_nx = (P_in&(~D_in))|((~P_in)&(~S_in)&D_in)|((~P_in)&S_in&(~D_in));
		8'h57: Result_nx = (P_in&(~D_in))|((~P_in)&(~D_in))|((~P_in)&(~S_in));
		8'h58: Result_nx = (P_in&(~D_in))|((~P_in)&S_in&D_in);
		8'h59: Result_nx = (P_in&(~D_in))|((~P_in)&S_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'h5A: Result_nx = (P_in&(~D_in))|((~P_in)&D_in);
		8'h5B: Result_nx = (P_in&(~D_in))|((~P_in)&D_in)|((~P_in)&(~S_in));
		8'h5C: Result_nx = (P_in&(~D_in))|((~P_in)&S_in);
		8'h5D: Result_nx = (P_in&(~D_in))|((~P_in)&S_in)|((~P_in)&(~D_in));
		8'h5E: Result_nx = (P_in&(~D_in))|((~P_in)&S_in)|((~P_in)&D_in);
		8'h5F: Result_nx = (P_in&(~D_in))|(~P_in);
		8'h60: Result_nx = (P_in&(~S_in)&D_in)|(P_in&S_in&(~D_in));
		8'h61: Result_nx = (P_in&(~S_in)&D_in)|(P_in&S_in&(~D_in))|((~P_in)&(~S_in)&(~D_in));
		8'h62: Result_nx = (P_in&(~S_in)&D_in)|(P_in&S_in&(~D_in))|((~P_in)&(~S_in)&D_in);
		8'h63: Result_nx = (P_in&(~S_in)&D_in)|(P_in&S_in&(~D_in))|((~P_in)&(~S_in));
		8'h64: Result_nx = (P_in&(~S_in)&D_in)|(P_in&S_in&(~D_in))|((~P_in)&S_in&(~D_in));
		8'h65: Result_nx = (P_in&(~S_in)&D_in)|(P_in&S_in&(~D_in))|((~P_in)&(~D_in));
		8'h66: Result_nx = (P_in&(~S_in)&D_in)|(P_in&S_in&(~D_in))|((~P_in)&(~S_in)&D_in)|((~P_in)&S_in&(~D_in));
		8'h67: Result_nx = (P_in&(~S_in)&D_in)|(P_in&S_in&(~D_in))|((~P_in)&(~D_in))|((~P_in)&(~S_in));
		8'h68: Result_nx = (P_in&(~S_in)&D_in)|(P_in&S_in&(~D_in))|((~P_in)&S_in&D_in);
		8'h69: Result_nx = (P_in&(~S_in)&D_in)|(P_in&S_in&(~D_in))|((~P_in)&S_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'h6A: Result_nx = (P_in&(~S_in)&D_in)|(P_in&S_in&(~D_in))|((~P_in)&D_in);
		8'h6B: Result_nx = (P_in&(~S_in)&D_in)|(P_in&S_in&(~D_in))|((~P_in)&D_in)|((~P_in)&(~S_in));
		8'h6C: Result_nx = (P_in&(~S_in)&D_in)|(P_in&S_in&(~D_in))|((~P_in)&S_in);
		8'h6D: Result_nx = (P_in&(~S_in)&D_in)|(P_in&S_in&(~D_in))|((~P_in)&S_in)|((~P_in)&(~D_in));
		8'h6E: Result_nx = (P_in&(~S_in)&D_in)|(P_in&S_in&(~D_in))|((~P_in)&S_in)|((~P_in)&D_in);
		8'h6F: Result_nx = (P_in&(~S_in)&D_in)|(P_in&S_in&(~D_in))|(~P_in);
		8'h70: Result_nx = (P_in&(~D_in))|(P_in&(~S_in));
		8'h71: Result_nx = (P_in&(~D_in))|(P_in&(~S_in))|((~P_in)&(~S_in)&(~D_in));
		8'h72: Result_nx = (P_in&(~D_in))|(P_in&(~S_in))|((~P_in)&(~S_in)&D_in);
		8'h73: Result_nx = (P_in&(~D_in))|(P_in&(~S_in))|((~P_in)&(~S_in));
		8'h74: Result_nx = (P_in&(~D_in))|(P_in&(~S_in))|((~P_in)&S_in&(~D_in));
		8'h75: Result_nx = (P_in&(~D_in))|(P_in&(~S_in))|((~P_in)&(~D_in));
		8'h76: Result_nx = (P_in&(~D_in))|(P_in&(~S_in))|((~P_in)&(~S_in)&D_in)|((~P_in)&S_in&(~D_in));
		8'h77: Result_nx = (P_in&(~D_in))|(P_in&(~S_in))|((~P_in)&(~D_in))|((~P_in)&(~S_in));
		8'h78: Result_nx = (P_in&(~D_in))|(P_in&(~S_in))|((~P_in)&S_in&D_in);
		8'h79: Result_nx = (P_in&(~D_in))|(P_in&(~S_in))|((~P_in)&S_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'h7A: Result_nx = (P_in&(~D_in))|(P_in&(~S_in))|((~P_in)&D_in);
		8'h7B: Result_nx = (P_in&(~D_in))|(P_in&(~S_in))|((~P_in)&D_in)|((~P_in)&(~S_in));
		8'h7C: Result_nx = (P_in&(~D_in))|(P_in&(~S_in))|((~P_in)&S_in);
		8'h7D: Result_nx = (P_in&(~D_in))|(P_in&(~S_in))|((~P_in)&S_in)|((~P_in)&(~D_in));
		8'h7E: Result_nx = (P_in&(~D_in))|(P_in&(~S_in))|((~P_in)&S_in)|((~P_in)&D_in);
		8'h7F: Result_nx = (P_in&(~D_in))|(P_in&(~S_in))|(~P_in);
		8'h80: Result_nx = (P_in&S_in&D_in);
		8'h81: Result_nx = (P_in&S_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'h82: Result_nx = (P_in&S_in&D_in)|((~P_in)&(~S_in)&D_in);
		8'h83: Result_nx = (P_in&S_in&D_in)|((~P_in)&(~S_in));
		8'h84: Result_nx = (P_in&S_in&D_in)|((~P_in)&S_in&(~D_in));
		8'h85: Result_nx = (P_in&S_in&D_in)|((~P_in)&(~D_in));
		8'h86: Result_nx = (P_in&S_in&D_in)|((~P_in)&(~S_in)&D_in)|((~P_in)&S_in&(~D_in));
		8'h87: Result_nx = (P_in&S_in&D_in)|((~P_in)&(~D_in))|((~P_in)&(~S_in));
		8'h88: Result_nx = (P_in&S_in&D_in)|((~P_in)&S_in&D_in);
		8'h89: Result_nx = (P_in&S_in&D_in)|((~P_in)&S_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'h8A: Result_nx = (P_in&S_in&D_in)|((~P_in)&D_in);
		8'h8B: Result_nx = (P_in&S_in&D_in)|((~P_in)&D_in)|((~P_in)&(~S_in));
		8'h8C: Result_nx = (P_in&S_in&D_in)|((~P_in)&S_in);
		8'h8D: Result_nx = (P_in&S_in&D_in)|((~P_in)&S_in)|((~P_in)&(~D_in));
		8'h8E: Result_nx = (P_in&S_in&D_in)|((~P_in)&S_in)|((~P_in)&D_in);
		8'h8F: Result_nx = (P_in&S_in&D_in)|(~P_in);
		8'h90: Result_nx = (P_in&S_in&D_in)|(P_in&(~S_in)&(~D_in));
		8'h91: Result_nx = (P_in&S_in&D_in)|(P_in&(~S_in)&(~D_in))|((~P_in)&(~S_in)&(~D_in));
		8'h92: Result_nx = (P_in&S_in&D_in)|(P_in&(~S_in)&(~D_in))|((~P_in)&(~S_in)&D_in);
		8'h93: Result_nx = (P_in&S_in&D_in)|(P_in&(~S_in)&(~D_in))|((~P_in)&(~S_in));
		8'h94: Result_nx = (P_in&S_in&D_in)|(P_in&(~S_in)&(~D_in))|((~P_in)&S_in&(~D_in));
		8'h95: Result_nx = (P_in&S_in&D_in)|(P_in&(~S_in)&(~D_in))|((~P_in)&(~D_in));
		8'h96: Result_nx = (P_in&S_in&D_in)|(P_in&(~S_in)&(~D_in))|((~P_in)&(~S_in)&D_in)|((~P_in)&S_in&(~D_in));
		8'h97: Result_nx = (P_in&S_in&D_in)|(P_in&(~S_in)&(~D_in))|((~P_in)&(~D_in))|((~P_in)&(~S_in));
		8'h98: Result_nx = (P_in&S_in&D_in)|(P_in&(~S_in)&(~D_in))|((~P_in)&S_in&D_in);
		8'h99: Result_nx = (P_in&S_in&D_in)|(P_in&(~S_in)&(~D_in))|((~P_in)&S_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'h9A: Result_nx = (P_in&S_in&D_in)|(P_in&(~S_in)&(~D_in))|((~P_in)&D_in);
		8'h9B: Result_nx = (P_in&S_in&D_in)|(P_in&(~S_in)&(~D_in))|((~P_in)&D_in)|((~P_in)&(~S_in));
		8'h9C: Result_nx = (P_in&S_in&D_in)|(P_in&(~S_in)&(~D_in))|((~P_in)&S_in);
		8'h9D: Result_nx = (P_in&S_in&D_in)|(P_in&(~S_in)&(~D_in))|((~P_in)&S_in)|((~P_in)&(~D_in));
		8'h9E: Result_nx = (P_in&S_in&D_in)|(P_in&(~S_in)&(~D_in))|((~P_in)&S_in)|((~P_in)&D_in);
		8'h9F: Result_nx = (P_in&S_in&D_in)|(P_in&(~S_in)&(~D_in))|(~P_in);
		8'hA0: Result_nx = (P_in&D_in);
		8'hA1: Result_nx = (P_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'hA2: Result_nx = (P_in&D_in)|((~P_in)&(~S_in)&D_in);
		8'hA3: Result_nx = (P_in&D_in)|((~P_in)&(~S_in));
		8'hA4: Result_nx = (P_in&D_in)|((~P_in)&S_in&(~D_in));
		8'hA5: Result_nx = (P_in&D_in)|((~P_in)&(~D_in));
		8'hA6: Result_nx = (P_in&D_in)|((~P_in)&(~S_in)&D_in)|((~P_in)&S_in&(~D_in));
		8'hA7: Result_nx = (P_in&D_in)|((~P_in)&(~D_in))|((~P_in)&(~S_in));
		8'hA8: Result_nx = (P_in&D_in)|((~P_in)&S_in&D_in);
		8'hA9: Result_nx = (P_in&D_in)|((~P_in)&S_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'hAA: Result_nx = (P_in&D_in)|((~P_in)&D_in);
		8'hAB: Result_nx = (P_in&D_in)|((~P_in)&D_in)|((~P_in)&(~S_in));
		8'hAC: Result_nx = (P_in&D_in)|((~P_in)&S_in);
		8'hAD: Result_nx = (P_in&D_in)|((~P_in)&S_in)|((~P_in)&(~D_in));
		8'hAE: Result_nx = (P_in&D_in)|((~P_in)&S_in)|((~P_in)&D_in);
		8'hAF: Result_nx = (P_in&D_in)|(~P_in);
		8'hB0: Result_nx = (P_in&D_in)|(P_in&(~S_in));
		8'hB1: Result_nx = (P_in&D_in)|(P_in&(~S_in))|((~P_in)&(~S_in)&(~D_in));
		8'hB2: Result_nx = (P_in&D_in)|(P_in&(~S_in))|((~P_in)&(~S_in)&D_in);
		8'hB3: Result_nx = (P_in&D_in)|(P_in&(~S_in))|((~P_in)&(~S_in));
		8'hB4: Result_nx = (P_in&D_in)|(P_in&(~S_in))|((~P_in)&S_in&(~D_in));
		8'hB5: Result_nx = (P_in&D_in)|(P_in&(~S_in))|((~P_in)&(~D_in));
		8'hB6: Result_nx = (P_in&D_in)|(P_in&(~S_in))|((~P_in)&(~S_in)&D_in)|((~P_in)&S_in&(~D_in));
		8'hB7: Result_nx = (P_in&D_in)|(P_in&(~S_in))|((~P_in)&(~D_in))|((~P_in)&(~S_in));
		8'hB8: Result_nx = (P_in&D_in)|(P_in&(~S_in))|((~P_in)&S_in&D_in);
		8'hB9: Result_nx = (P_in&D_in)|(P_in&(~S_in))|((~P_in)&S_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'hBA: Result_nx = (P_in&D_in)|(P_in&(~S_in))|((~P_in)&D_in);
		8'hBB: Result_nx = (P_in&D_in)|(P_in&(~S_in))|((~P_in)&D_in)|((~P_in)&(~S_in));
		8'hBC: Result_nx = (P_in&D_in)|(P_in&(~S_in))|((~P_in)&S_in);
		8'hBD: Result_nx = (P_in&D_in)|(P_in&(~S_in))|((~P_in)&S_in)|((~P_in)&(~D_in));
		8'hBE: Result_nx = (P_in&D_in)|(P_in&(~S_in))|((~P_in)&S_in)|((~P_in)&D_in);
		8'hBF: Result_nx = (P_in&D_in)|(P_in&(~S_in))|(~P_in);
		8'hC0: Result_nx = (P_in&S_in);
		8'hC1: Result_nx = (P_in&S_in)|((~P_in)&(~S_in)&(~D_in));
		8'hC2: Result_nx = (P_in&S_in)|((~P_in)&(~S_in)&D_in);
		8'hC3: Result_nx = (P_in&S_in)|((~P_in)&(~S_in));
		8'hC4: Result_nx = (P_in&S_in)|((~P_in)&S_in&(~D_in));
		8'hC5: Result_nx = (P_in&S_in)|((~P_in)&(~D_in));
		8'hC6: Result_nx = (P_in&S_in)|((~P_in)&(~S_in)&D_in)|((~P_in)&S_in&(~D_in));
		8'hC7: Result_nx = (P_in&S_in)|((~P_in)&(~D_in))|((~P_in)&(~S_in));
		8'hC8: Result_nx = (P_in&S_in)|((~P_in)&S_in&D_in);
		8'hC9: Result_nx = (P_in&S_in)|((~P_in)&S_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'hCA: Result_nx = (P_in&S_in)|((~P_in)&D_in);
		8'hCB: Result_nx = (P_in&S_in)|((~P_in)&D_in)|((~P_in)&(~S_in));
		8'hCC: Result_nx = (P_in&S_in)|((~P_in)&S_in);
		8'hCD: Result_nx = (P_in&S_in)|((~P_in)&S_in)|((~P_in)&(~D_in));
		8'hCE: Result_nx = (P_in&S_in)|((~P_in)&S_in)|((~P_in)&D_in);
		8'hCF: Result_nx = (P_in&S_in)|(~P_in);
		8'hD0: Result_nx = (P_in&S_in)|(P_in&(~D_in));
		8'hD1: Result_nx = (P_in&S_in)|(P_in&(~D_in))|((~P_in)&(~S_in)&(~D_in));
		8'hD2: Result_nx = (P_in&S_in)|(P_in&(~D_in))|((~P_in)&(~S_in)&D_in);
		8'hD3: Result_nx = (P_in&S_in)|(P_in&(~D_in))|((~P_in)&(~S_in));
		8'hD4: Result_nx = (P_in&S_in)|(P_in&(~D_in))|((~P_in)&S_in&(~D_in));
		8'hD5: Result_nx = (P_in&S_in)|(P_in&(~D_in))|((~P_in)&(~D_in));
		8'hD6: Result_nx = (P_in&S_in)|(P_in&(~D_in))|((~P_in)&(~S_in)&D_in)|((~P_in)&S_in&(~D_in));
		8'hD7: Result_nx = (P_in&S_in)|(P_in&(~D_in))|((~P_in)&(~D_in))|((~P_in)&(~S_in));
		8'hD8: Result_nx = (P_in&S_in)|(P_in&(~D_in))|((~P_in)&S_in&D_in);
		8'hD9: Result_nx = (P_in&S_in)|(P_in&(~D_in))|((~P_in)&S_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'hDA: Result_nx = (P_in&S_in)|(P_in&(~D_in))|((~P_in)&D_in);
		8'hDB: Result_nx = (P_in&S_in)|(P_in&(~D_in))|((~P_in)&D_in)|((~P_in)&(~S_in));
		8'hDC: Result_nx = (P_in&S_in)|(P_in&(~D_in))|((~P_in)&S_in);
		8'hDD: Result_nx = (P_in&S_in)|(P_in&(~D_in))|((~P_in)&S_in)|((~P_in)&(~D_in));
		8'hDE: Result_nx = (P_in&S_in)|(P_in&(~D_in))|((~P_in)&S_in)|((~P_in)&D_in);
		8'hDF: Result_nx = (P_in&S_in)|(P_in&(~D_in))|(~P_in);
		8'hE0: Result_nx = (P_in&S_in)|(P_in&D_in);
		8'hE1: Result_nx = (P_in&S_in)|(P_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'hE2: Result_nx = (P_in&S_in)|(P_in&D_in)|((~P_in)&(~S_in)&D_in);
		8'hE3: Result_nx = (P_in&S_in)|(P_in&D_in)|((~P_in)&(~S_in));
		8'hE4: Result_nx = (P_in&S_in)|(P_in&D_in)|((~P_in)&S_in&(~D_in));
		8'hE5: Result_nx = (P_in&S_in)|(P_in&D_in)|((~P_in)&(~D_in));
		8'hE6: Result_nx = (P_in&S_in)|(P_in&D_in)|((~P_in)&(~S_in)&D_in)|((~P_in)&S_in&(~D_in));
		8'hE7: Result_nx = (P_in&S_in)|(P_in&D_in)|((~P_in)&(~D_in))|((~P_in)&(~S_in));
		8'hE8: Result_nx = (P_in&S_in)|(P_in&D_in)|((~P_in)&S_in&D_in);
		8'hE9: Result_nx = (P_in&S_in)|(P_in&D_in)|((~P_in)&S_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'hEA: Result_nx = (P_in&S_in)|(P_in&D_in)|((~P_in)&D_in);
		8'hEB: Result_nx = (P_in&S_in)|(P_in&D_in)|((~P_in)&D_in)|((~P_in)&(~S_in));
		8'hEC: Result_nx = (P_in&S_in)|(P_in&D_in)|((~P_in)&S_in);
		8'hED: Result_nx = (P_in&S_in)|(P_in&D_in)|((~P_in)&S_in)|((~P_in)&(~D_in));
		8'hEE: Result_nx = (P_in&S_in)|(P_in&D_in)|((~P_in)&S_in)|((~P_in)&D_in);
		8'hEF: Result_nx = (P_in&S_in)|(P_in&D_in)|(~P_in);
		8'hF0: Result_nx = P_in;
		8'hF1: Result_nx = P_in|((~P_in)&(~S_in)&(~D_in));
		8'hF2: Result_nx = P_in|((~P_in)&(~S_in)&D_in);
		8'hF3: Result_nx = P_in|((~P_in)&(~S_in));
		8'hF4: Result_nx = P_in|((~P_in)&S_in&(~D_in));
		8'hF5: Result_nx = P_in|((~P_in)&(~D_in));
		8'hF6: Result_nx = P_in|((~P_in)&(~S_in)&D_in)|((~P_in)&S_in&(~D_in));
		8'hF7: Result_nx = P_in|((~P_in)&(~D_in))|((~P_in)&(~S_in));
		8'hF8: Result_nx = P_in|((~P_in)&S_in&D_in);
		8'hF9: Result_nx = P_in|((~P_in)&S_in&D_in)|((~P_in)&(~S_in)&(~D_in));
		8'hFA: Result_nx = P_in|((~P_in)&D_in);
		8'hFB: Result_nx = P_in|((~P_in)&D_in)|((~P_in)&(~S_in));
		8'hFC: Result_nx = P_in|((~P_in)&S_in);
		8'hFD: Result_nx = P_in|((~P_in)&S_in)|((~P_in)&(~D_in));
		8'hFE: Result_nx = P_in|((~P_in)&S_in)|((~P_in)&D_in);
		8'hFF: Result_nx = P_in|(~P_in);
		default: Result_nx = 0;
	endcase
end


endmodule
