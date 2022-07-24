/*
* Module      : rop3_smart
* Description : Implement this module using the bit-hack technique mentioned in the assignment handout.
*               This module should support all the possible modes of ROP3.
* Notes       : Please remember to
*               (1) make the bit-length of {P, S, D, Result} parameterizable
*               (2) make the input/output to be a register
*/

module rop3_smart
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
reg [7:0] temp1 [0:N-1];
reg [7:0] temp2 [0:N-1];

integer i;

always@(posedge clk) begin
	P_in <= P;
	S_in <= S;
	D_in <= D;
	Mode_in <= Mode;
	Result <= Result_nx;
end

always@* begin
	for(i = 0; i < N; i = i + 1) begin
		temp1[i][7:0] = 8'h1 << {P_in[i], S_in[i], D_in[i]};
		temp2[i][7:0] = temp1[i][7:0] & Mode_in[7:0];
		Result_nx[i] = |temp2[i][7:0];
	end
end
endmodule
