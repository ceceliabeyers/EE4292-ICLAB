module dct1D #(
parameter IN_WIDTH   = 8,
parameter COEF_WIDTH = 9,
parameter COEF_FP    = 8
)
(
input clk,
input signed [IN_WIDTH-1:0] x0,
input signed [IN_WIDTH-1:0] x1,
input signed [IN_WIDTH-1:0] x2,
input signed [IN_WIDTH-1:0] x3,
input signed [IN_WIDTH-1:0] x4,
input signed [IN_WIDTH-1:0] x5,
input signed [IN_WIDTH-1:0] x6,
input signed [IN_WIDTH-1:0] x7,
output reg signed [IN_WIDTH+2-1:0] y0,
output reg signed [IN_WIDTH+2-1:0] y1,
output reg signed [IN_WIDTH+2-1:0] y2,
output reg signed [IN_WIDTH+2-1:0] y3,
output reg signed [IN_WIDTH+2-1:0] y4,
output reg signed [IN_WIDTH+2-1:0] y5,
output reg signed [IN_WIDTH+2-1:0] y6,
output reg signed [IN_WIDTH+2-1:0] y7
);

reg signed [IN_WIDTH+1-1:0] reg0_in0;
reg signed [IN_WIDTH+1-1:0] reg0_in1;
reg signed [IN_WIDTH+1-1:0] reg0_in2;
reg signed [IN_WIDTH+1-1:0] reg0_in3;
reg signed [IN_WIDTH+2-1:0] reg0_in4;
reg signed [IN_WIDTH+1-1:0] reg0_in5;
reg signed [IN_WIDTH+1-1:0] reg0_in6;
reg signed [IN_WIDTH+2-1:0] reg0_in7;
reg signed [IN_WIDTH+1-1:0] reg0_out0;
reg signed [IN_WIDTH+1-1:0] reg0_out1;
reg signed [IN_WIDTH+1-1:0] reg0_out2;
reg signed [IN_WIDTH+1-1:0] reg0_out3;
reg signed [IN_WIDTH+2-1:0] reg0_out4;
reg signed [IN_WIDTH+1-1:0] reg0_out5;
reg signed [IN_WIDTH+1-1:0] reg0_out6;
reg signed [IN_WIDTH+2-1:0] reg0_out7;

reg signed [IN_WIDTH+2-1:0] reg1_in0;
reg signed [IN_WIDTH+2-1:0] reg1_in1;
reg signed [IN_WIDTH+2-1:0] reg1_in2;
reg signed [IN_WIDTH+2-1:0] reg1_in3;
reg signed [IN_WIDTH+2-1:0] reg1_in4;
reg signed [IN_WIDTH+1+COEF_WIDTH-1:0] reg1_in5;
reg signed [IN_WIDTH+1+COEF_WIDTH-1:0] reg1_in6;
reg signed [IN_WIDTH+2-1:0] reg1_in7;
reg signed [IN_WIDTH+2-1:0] reg1_out0;
reg signed [IN_WIDTH+2-1:0] reg1_out1;
reg signed [IN_WIDTH+2-1:0] reg1_out2;
reg signed [IN_WIDTH+2-1:0] reg1_out3;
reg signed [IN_WIDTH+2-1:0] reg1_out4;
reg signed [IN_WIDTH+1+COEF_WIDTH-1:0] reg1_out5;
reg signed [IN_WIDTH+1+COEF_WIDTH-1:0] reg1_out6;
reg signed [IN_WIDTH+2-1:0] reg1_out7;

reg signed [IN_WIDTH+2+COEF_FP-1:0] reg1_out4_sh;
reg signed [IN_WIDTH+2+COEF_FP-1:0] reg1_out7_sh;

reg signed [IN_WIDTH+1+COEF_WIDTH-1:0] reg2_in4;
reg signed [IN_WIDTH+1+COEF_WIDTH-1:0] reg2_in5;
reg signed [IN_WIDTH+1+COEF_WIDTH-1:0] reg2_in6;
reg signed [IN_WIDTH+1+COEF_WIDTH-1:0] reg2_in7;
reg signed [IN_WIDTH+2-1:0] reg2_out0;
reg signed [IN_WIDTH+2-1:0] reg2_out1;
reg signed [IN_WIDTH+2-1:0] reg2_out2;
reg signed [IN_WIDTH+2-1:0] reg2_out3;
reg signed [IN_WIDTH+1+1+COEF_WIDTH-1:0] reg2_out4;
reg signed [IN_WIDTH+1+1+COEF_WIDTH-1:0] reg2_out5;
reg signed [IN_WIDTH+1+1+COEF_WIDTH-1:0] reg2_out6;
reg signed [IN_WIDTH+1+1+COEF_WIDTH-1:0] reg2_out7;

reg signed [IN_WIDTH+COEF_WIDTH+3-1:0] y0_nx;
reg signed [IN_WIDTH+1+1+COEF_WIDTH+COEF_WIDTH+1-1:0] y1_nx;
reg signed [IN_WIDTH+COEF_WIDTH+3-1:0] y2_nx;
reg signed [IN_WIDTH+1+1+COEF_WIDTH+COEF_WIDTH+1-1:0] y3_nx;
reg signed [IN_WIDTH+COEF_WIDTH+3-1:0] y4_nx;
reg signed [IN_WIDTH+1+1+COEF_WIDTH+COEF_WIDTH+1-1:0] y5_nx;
reg signed [IN_WIDTH+COEF_WIDTH+3-1:0] y6_nx;
reg signed [IN_WIDTH+1+1+COEF_WIDTH+COEF_WIDTH+1-1:0] y7_nx;

wire signed [COEF_WIDTH-1:0] c[0:6];
assign c[0] = 9'b010110101;
assign c[1] = 9'b011101101;
assign c[2] = 9'b001100010;
assign c[3] = 9'b011111011;
assign c[4] = 9'b011010101;
assign c[5] = 9'b010001110;
assign c[6] = 9'b000110010;

always@(posedge clk) begin
	y0 <= y0_nx[COEF_WIDTH+IN_WIDTH+2-1:9];
	y1 <= y1_nx[COEF_WIDTH+IN_WIDTH+IN_WIDTH+1-1:17];
	y2 <= y2_nx[COEF_WIDTH+IN_WIDTH+2-1:9];
	y3 <= y3_nx[COEF_WIDTH+IN_WIDTH+IN_WIDTH+1-1:17];
	y4 <= y4_nx[COEF_WIDTH+IN_WIDTH+2-1:9];
	y5 <= y5_nx[COEF_WIDTH+IN_WIDTH+IN_WIDTH+1-1:17];
	y6 <=y6_nx[COEF_WIDTH+IN_WIDTH+2-1:9];
	y7 <= y7_nx[COEF_WIDTH+IN_WIDTH+IN_WIDTH+1-1:17];
	//y2 <= y2_nx[9+8+2-1:9];
	//y3 <= y3_nx[17+8+2-1:17];
	//y4 <= y4_nx[9+8+2-1:9];
	//y5 <= y5_nx[17+8+2-1:17];
	//y6 <= y6_nx[9+8+2-1:9];
	//y7 <= y7_nx[17+8+2-1:17];
	reg0_out0 <= reg0_in0;
	reg0_out1 <= reg0_in1;
	reg0_out2 <= reg0_in2;
	reg0_out3 <= reg0_in3;
	reg0_out4 <= reg0_in4;
	reg0_out5 <= reg0_in5;
	reg0_out6 <= reg0_in6;
	reg0_out7 <= reg0_in7;
	reg1_out0 <= reg1_in0;
	reg1_out1 <= reg1_in1;
	reg1_out2 <= reg1_in2;
	reg1_out3 <= reg1_in3;
	reg1_out4 <= reg1_in4;
	reg1_out5 <= reg1_in5;
	reg1_out6 <= reg1_in6;
	reg1_out7 <= reg1_in7;
	reg2_out0 <= reg1_out0;
	reg2_out1 <= reg1_out1;
	reg2_out2 <= reg1_out2;
	reg2_out3 <= reg1_out3;
	reg2_out4 <= reg2_in4;
	reg2_out5 <= reg2_in5;
	reg2_out6 <= reg2_in6;
	reg2_out7 <= reg2_in7;
end

always@* begin
	reg0_in0 = x0 + x7;
	reg0_in1 = x1 + x6;
	reg0_in2 = x2 + x5;
	reg0_in3 = x3 + x4;
	reg0_in4 = x3 - x4;
	reg0_in5 = x2 - x5;
	reg0_in6 = x1 - x6;
	reg0_in7 = x0 - x7;

	reg1_in0 = reg0_out0 + reg0_out3;
	reg1_in1 = reg0_out1 + reg0_out2;
	reg1_in2 = reg0_out1 - reg0_out2;
	reg1_in3 = reg0_out0 - reg0_out3;
	reg1_in4 = reg0_out4;
	reg1_in5 = reg0_out5 * c[0];
	reg1_in6 = reg0_out6 * c[0];
	reg1_in7 = reg0_out7;
	
	reg1_out4_sh = reg1_out4 <<< COEF_FP;
	reg1_out7_sh = reg1_out7 <<< COEF_FP;

	reg2_in4 = reg1_out4_sh + (reg1_out6 - reg1_out5);
	reg2_in5 = reg1_out4_sh - (reg1_out6 - reg1_out5);
	reg2_in6 = reg1_out7_sh - (reg1_out6 + reg1_out5);
	reg2_in7 = reg1_out7_sh + (reg1_out6 + reg1_out5);	
	y0_nx = (reg2_out0 + reg2_out1) * c[0] + 256;
	y4_nx = (reg2_out0 - reg2_out1) * c[0] + 256;
	y2_nx = reg2_out2 * c[2] + reg2_out3 * c[1] + 256;
	y6_nx = reg2_out3 * c[2] - reg2_out2 * c[1] + 256;
	y1_nx = reg2_out4 * c[6] + reg2_out7 * c[3] + 65536;
	y5_nx = reg2_out5 * c[4] + reg2_out6 * c[5] + 65536;
	y3_nx = reg2_out6 * c[4] - reg2_out5 * c[5] + 65536;
	y7_nx = reg2_out7 * c[6] - reg2_out4 * c[3] + 65536;  
end

endmodule
