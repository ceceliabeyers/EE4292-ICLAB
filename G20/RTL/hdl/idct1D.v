module idct1D #(
parameter IN_WIDTH   = 12,
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
output reg signed [IN_WIDTH-1:0] y0,
output reg signed [IN_WIDTH-1:0] y1,
output reg signed [IN_WIDTH-1:0] y2,
output reg signed [IN_WIDTH-1:0] y3,
output reg signed [IN_WIDTH-1:0] y4,
output reg signed [IN_WIDTH-1:0] y5,
output reg signed [IN_WIDTH-1:0] y6,
output reg signed [IN_WIDTH-1:0] y7
);

reg signed [IN_WIDTH+9-1:0] reg0_in0;
reg signed [IN_WIDTH+9-1:0] reg0_in1;
reg signed [IN_WIDTH+9-1:0] reg0_in2;
reg signed [IN_WIDTH+9-1:0] reg0_in3;
reg signed [IN_WIDTH+9-1:0] reg0_in4;
reg signed [IN_WIDTH+9-1:0] reg0_in5;
reg signed [IN_WIDTH+9-1:0] reg0_in6;
reg signed [IN_WIDTH+9-1:0] reg0_in7;
reg signed [IN_WIDTH+9-1:0] reg0_in8;
reg signed [IN_WIDTH+9-1:0] reg0_in9;
reg signed [IN_WIDTH+9-1:0] reg0_in10;
reg signed [IN_WIDTH+9-1:0] reg0_in11;
reg signed [IN_WIDTH+9-1:0] reg0_in12;
reg signed [IN_WIDTH+9-1:0] reg0_in13;
reg signed [IN_WIDTH+9-1:0] reg0_in14;
reg signed [IN_WIDTH+9-1:0] reg0_out0;
reg signed [IN_WIDTH+9-1:0] reg0_out1;
reg signed [IN_WIDTH+9-1:0] reg0_out2;
reg signed [IN_WIDTH+9-1:0] reg0_out3;
reg signed [IN_WIDTH+9-1:0] reg0_out4;
reg signed [IN_WIDTH+9-1:0] reg0_out5;
reg signed [IN_WIDTH+9-1:0] reg0_out6;
reg signed [IN_WIDTH+9-1:0] reg0_out7;
reg signed [IN_WIDTH+9-1:0] reg0_out8;
reg signed [IN_WIDTH+9-1:0] reg0_out9;
reg signed [IN_WIDTH+9-1:0] reg0_out10;
reg signed [IN_WIDTH+9-1:0] reg0_out11;
reg signed [IN_WIDTH+9-1:0] reg0_out12;
reg signed [IN_WIDTH+9-1:0] reg0_out13;
reg signed [IN_WIDTH+9-1:0] reg0_out14;

reg signed [IN_WIDTH+9+2-1:0] reg1_in0;
reg signed [IN_WIDTH+9+2-1:0] reg1_in1;
reg signed [IN_WIDTH+9+2-1:0] reg1_in2;
reg signed [IN_WIDTH+9+2-1:0] reg1_in3;
reg signed [IN_WIDTH+9+2-1:0] reg1_in4;
reg signed [IN_WIDTH+9+2-1:0] reg1_in5;
reg signed [IN_WIDTH+9+2-1:0] reg1_in6;
reg signed [IN_WIDTH+9+2-1:0] reg1_in7;
reg signed [IN_WIDTH+9+2-1:0] reg1_out0;
reg signed [IN_WIDTH+9+2-1:0] reg1_out1;
reg signed [IN_WIDTH+9+2-1:0] reg1_out2;
reg signed [IN_WIDTH+9+2-1:0] reg1_out3;
reg signed [IN_WIDTH+9+2-1:0] reg1_out4;
reg signed [IN_WIDTH+9+2-1:0] reg1_out5;
reg signed [IN_WIDTH+9+2-1:0] reg1_out6;
reg signed [IN_WIDTH+9+2-1:0] reg1_out7;

reg signed [IN_WIDTH+9+9+2-1:0] reg2_in5;
reg signed [IN_WIDTH+9+9+2-1:0] reg2_in6;
reg signed [IN_WIDTH+9+9+2-1:0] reg2_in7;
reg signed [IN_WIDTH+9+2-1:0] reg2_out0;
reg signed [IN_WIDTH+9+2-1:0] reg2_out1;
reg signed [IN_WIDTH+9+2-1:0] reg2_out2;
reg signed [IN_WIDTH+9+2-1:0] reg2_out3;
reg signed [IN_WIDTH+9+2-1:0] reg2_out4;
reg signed [IN_WIDTH+9+9+2-1:0] reg2_out5;
reg signed [IN_WIDTH+9+9+2-1:0] reg2_out6;
reg signed [IN_WIDTH+9+9+2-1:0] reg2_out7;
reg signed [IN_WIDTH+9+2-1:0] reg2_out8;

reg signed [IN_WIDTH+9+9+2-1:0] reg2_out1_sh;
reg signed [IN_WIDTH+9+9+2-1:0] reg2_out2_sh;

reg signed [IN_WIDTH+9+2+1-1:0] y0_nx;
reg signed [IN_WIDTH+9+9+2+1-1:0] y1_nx;
reg signed [IN_WIDTH+9+9+2+1-1:0] y2_nx;
reg signed [IN_WIDTH+9+2+1-1:0] y3_nx;
reg signed [IN_WIDTH+9+2+1-1:0] y4_nx;
reg signed [IN_WIDTH+9+9+2+1-1:0] y5_nx;
reg signed [IN_WIDTH+9+9+2+1-1:0] y6_nx;
reg signed [IN_WIDTH+9+2+1-1:0] y7_nx;

wire signed [COEF_WIDTH-1:0] c[0:6];
assign c[0] = 9'b010110101;  //cos pi/4    A
assign c[1] = 9'b011101101;  //cos pi/8    B
assign c[2] = 9'b001100010;  //sin pi/8    C
assign c[3] = 9'b011111011;  //cos pi/16   D
assign c[4] = 9'b011010101;  //cos 3pi/16  E
assign c[5] = 9'b010001110;  //sin 3pi/16  F
assign c[6] = 9'b000110010;  //sin pi/16   G

always@(posedge clk) begin
	y0 <= y0_nx[20:9];
	y1 <= y1_nx[28:17];
	y2 <= y2_nx[28:17];
	y3 <= y3_nx[20:9];
	y4 <= y4_nx[20:9];
	y5 <= y5_nx[28:17];
	y6 <= y6_nx[28:17];
	y7 <= y7_nx[20:9];
	reg0_out0 <= reg0_in0;
	reg0_out1 <= reg0_in1;
	reg0_out2 <= reg0_in2;
	reg0_out3 <= reg0_in3;
	reg0_out4 <= reg0_in4;
	reg0_out5 <= reg0_in5;
	reg0_out6 <= reg0_in6;
	reg0_out7 <= reg0_in7;
	reg0_out8 <= reg0_in8;
	reg0_out9 <= reg0_in9;
	reg0_out10<= reg0_in10;
	reg0_out11<= reg0_in11;
	reg0_out12<= reg0_in12;
	reg0_out13<= reg0_in13;
	reg0_out14<= reg0_in14;
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
	reg2_out4 <= reg1_out4;
	reg2_out5 <= reg2_in5;
	reg2_out6 <= reg2_in6;
	reg2_out7 <= reg2_in7;
	reg2_out8 <= reg1_out7;
end

always@* begin
	reg0_in0 = x0 * c[0]; // x0*A
	reg0_in1 = x4 * c[0]; // x4*A
	reg0_in2 = -(x4 * c[0]);
	reg0_in3 = x2 * c[2]; 
	reg0_in4 = x2 * c[1]; // x2*B
	reg0_in5 = -(x6 * c[1]);
	reg0_in6 = x6 * c[2]; // x6*C 
	reg0_in7 = x1 * c[6];
	reg0_in8 = x1 * c[3]; // x1*D
	reg0_in9 = x5 * c[4];
	reg0_in10= x5 * c[5]; // x5*F
	reg0_in11= -(x3 * c[5]);
	reg0_in12= x3 * c[4]; // x3*E
	reg0_in13= -(x7 * c[3]);
	reg0_in14= x7 * c[6]; // x7*G

	reg1_in0 = reg0_out0 + reg0_out1 + reg0_out4 + reg0_out6; // v
	reg1_in1 = reg0_out0 + reg0_out2 + reg0_out3 + reg0_out5;
	reg1_in2 = reg0_out0 + reg0_out2 - reg0_out3 - reg0_out5;
	reg1_in3 = reg0_out0 + reg0_out1 - reg0_out4 - reg0_out6;
	reg1_in4 = reg0_out7 + reg0_out13+ reg0_out9 + reg0_out11;
	reg1_in5 = reg0_out7 + reg0_out13- reg0_out9 - reg0_out11;
	reg1_in6 = reg0_out8 + reg0_out14- reg0_out10- reg0_out12;
	reg1_in7 = reg0_out8 + reg0_out14+ reg0_out10+ reg0_out12; // v

	reg2_in5 = -(reg1_out5 * c[0]);
	reg2_in6 = reg1_out5 * c[0];
	reg2_in7 = reg1_out6 * c[0];	

	reg2_out1_sh = reg2_out1 <<< COEF_FP;
	reg2_out2_sh = reg2_out2 <<< COEF_FP;

	y0_nx = reg2_out0 + reg2_out8 + 256;
	y1_nx = reg2_out1_sh + reg2_out6 + reg2_out7 + 65536;
	y2_nx = reg2_out2_sh + reg2_out5 + reg2_out7 + 65536;
	y3_nx = reg2_out3 + reg2_out4 + 256;
	y4_nx = reg2_out3 - reg2_out4 + 256;
	y5_nx = reg2_out2_sh - reg2_out5 - reg2_out7 + 65536;
	y6_nx = reg2_out1_sh - reg2_out6 - reg2_out7 + 65536;
	y7_nx = reg2_out0 - reg2_out8 + 256;
end

endmodule
