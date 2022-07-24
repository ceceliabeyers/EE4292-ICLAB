module mul#(
parameter CH_NUM = 4,
parameter ACT_PER_ADDR = 4,
parameter BW_PER_ACT = 12,
parameter WEIGHT_PER_ADDR = 9, 
parameter BIAS_PER_ADDR = 1,
parameter BW_PER_PARAM = 8
)
(
input clk,
input [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] weight0,
input [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] weight1,
input [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] weight2,
input [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] weight3,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] map0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] map1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] map2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] map3,
input signed [BW_PER_PARAM-1:0] bias,
input refresh,
input idc_col,
input idc_row,
input conv3_en,
output reg signed [4*BW_PER_ACT-1:0] out
);

reg signed [BW_PER_ACT-1:0] out00;
reg signed [BW_PER_ACT-1:0] out01;
reg signed [BW_PER_ACT-1:0] out02;
reg signed [BW_PER_ACT-1:0] out03;
reg signed [BW_PER_ACT-1:0] out_pool;

reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in0;
reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in1;
reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in2;
reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in3;

reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in4;
reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in5;
reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in6;
reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in7;

reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in8;
reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in9;
reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in10;
reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in11;

reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in12;
reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in13;
reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in14;
reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in15;

reg signed [BW_PER_ACT-1:0] ifmap0 [0:3][0:2][0:2];
reg signed [BW_PER_ACT-1:0] ifmap1 [0:3][0:2][0:2];
reg signed [BW_PER_ACT-1:0] ifmap2 [0:3][0:2][0:2];
reg signed [BW_PER_ACT-1:0] ifmap3 [0:3][0:2][0:2];

reg signed [BW_PER_PARAM-1:0] weight [0:3][0:2][0:2];

reg signed [BW_PER_ACT+BW_PER_PARAM-1:0] psum0 [0:3][0:2][0:2];
reg signed [BW_PER_ACT+BW_PER_PARAM-1:0] psum1 [0:3][0:2][0:2];
reg signed [BW_PER_ACT+BW_PER_PARAM-1:0] psum2 [0:3][0:2][0:2];
reg signed [BW_PER_ACT+BW_PER_PARAM-1:0] psum3 [0:3][0:2][0:2];

reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum0_mul_all;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum1_mul_all;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum2_mul_all;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum3_mul_all;
//add
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum00_mul_9;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum01_mul_9;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum02_mul_9;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum03_mul_9;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum10_mul_9;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum11_mul_9;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum12_mul_9;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum13_mul_9;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum20_mul_9;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum21_mul_9;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum22_mul_9;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum23_mul_9;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum30_mul_9;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum31_mul_9;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum32_mul_9;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum33_mul_9;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum00_mul_9_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum01_mul_9_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum02_mul_9_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum03_mul_9_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum10_mul_9_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum11_mul_9_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum12_mul_9_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum13_mul_9_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum20_mul_9_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum21_mul_9_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum22_mul_9_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum23_mul_9_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum30_mul_9_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum31_mul_9_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum32_mul_9_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+4-1:0] psum33_mul_9_nx;
//
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum0_mul_store, psum0_mul_store_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum1_mul_store, psum1_mul_store_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum2_mul_store, psum2_mul_store_nx;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum3_mul_store, psum3_mul_store_nx;

reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum0_mul_forpool;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum1_mul_forpool;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum2_mul_forpool;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum3_mul_forpool;

reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum0_bias;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum1_bias;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum2_bias;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum3_bias;

reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum0_relu;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum1_relu;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum2_relu;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum3_relu;

reg signed [BW_PER_ACT+BW_PER_PARAM+2+6-1:0] psum_pool_sum;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum_pool;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum0_nopool;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum1_nopool;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum2_nopool;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum3_nopool;

reg signed [BW_PER_PARAM+8-1:0] bias_shift;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-7-1:0] psum_bias_shift;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-7-1:0] psum0_bias_shift;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-7-1:0] psum1_bias_shift;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-7-1:0] psum2_bias_shift;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-7-1:0] psum3_bias_shift;

integer i, j, k;

reg refresh_nx;

always@(posedge clk) begin
	psum0_mul_store <= psum0_mul_store_nx;
	psum1_mul_store <= psum1_mul_store_nx;
	psum2_mul_store <= psum2_mul_store_nx;
	psum3_mul_store <= psum3_mul_store_nx;
	// add
	psum00_mul_9 <= psum00_mul_9_nx;
	psum01_mul_9 <= psum01_mul_9_nx;
	psum02_mul_9 <= psum02_mul_9_nx;
	psum03_mul_9 <= psum03_mul_9_nx;
	psum10_mul_9 <= psum10_mul_9_nx;
	psum11_mul_9 <= psum11_mul_9_nx;
	psum12_mul_9 <= psum12_mul_9_nx;
	psum13_mul_9 <= psum13_mul_9_nx;
	psum20_mul_9 <= psum20_mul_9_nx;
	psum21_mul_9 <= psum21_mul_9_nx;
	psum22_mul_9 <= psum22_mul_9_nx;
	psum23_mul_9 <= psum23_mul_9_nx;
	psum30_mul_9 <= psum30_mul_9_nx;
	psum31_mul_9 <= psum31_mul_9_nx;
	psum32_mul_9 <= psum32_mul_9_nx;
	psum33_mul_9 <= psum33_mul_9_nx;
	refresh_nx <= refresh;
end

always@* begin
	if(conv3_en) begin
		if(refresh_nx) begin
			psum0_mul_store_nx = 0;
			psum1_mul_store_nx = 0;
			psum2_mul_store_nx = 0;
			psum3_mul_store_nx = 0;
		end
		else begin
			psum0_mul_store_nx = psum0_mul_forpool;
			psum1_mul_store_nx = psum1_mul_forpool;
			psum2_mul_store_nx = psum2_mul_forpool;
			psum3_mul_store_nx = psum3_mul_forpool;
		end
	end
	else begin
		psum0_mul_store_nx = 0;
		psum1_mul_store_nx = 0;
		psum2_mul_store_nx = 0;
		psum3_mul_store_nx = 0;
	end
end

always@* begin
	psum0_mul_forpool = psum0_mul_store + psum0_mul_all;
	psum1_mul_forpool = psum1_mul_store + psum1_mul_all;
	psum2_mul_forpool = psum2_mul_store + psum2_mul_all;
	psum3_mul_forpool = psum3_mul_store + psum3_mul_all;
end

always@* begin
	bias_shift = {bias, 8'b0};
	for(i = 0; i < 4; i = i + 1) begin
		for(j = 0; j < 3; j = j + 1) begin
			for(k = 0; k < 3; k = k + 1) begin
				psum0[i][j][k] = ifmap0[i][j][k] * weight[i][j][k];
				psum1[i][j][k] = ifmap1[i][j][k] * weight[i][j][k];
				psum2[i][j][k] = ifmap2[i][j][k] * weight[i][j][k];
				psum3[i][j][k] = ifmap3[i][j][k] * weight[i][j][k];
			end
		end
	end
	psum00_mul_9_nx = psum0[0][0][0] + psum0[0][0][1] + psum0[0][0][2] + psum0[0][1][0] + psum0[0][1][1] + psum0[0][1][2] + psum0[0][2][0] + psum0[0][2][1] + psum0[0][2][2];
	psum10_mul_9_nx = psum1[0][0][0] + psum1[0][0][1] + psum1[0][0][2] + psum1[0][1][0] + psum1[0][1][1] + psum1[0][1][2] + psum1[0][2][0] + psum1[0][2][1] + psum1[0][2][2];
	psum20_mul_9_nx = psum2[0][0][0] + psum2[0][0][1] + psum2[0][0][2] + psum2[0][1][0] + psum2[0][1][1] + psum2[0][1][2] + psum2[0][2][0] + psum2[0][2][1] + psum2[0][2][2];
	psum30_mul_9_nx = psum3[0][0][0] + psum3[0][0][1] + psum3[0][0][2] + psum3[0][1][0] + psum3[0][1][1] + psum3[0][1][2] + psum3[0][2][0] + psum3[0][2][1] + psum3[0][2][2];
	psum01_mul_9_nx = psum0[1][0][0] + psum0[1][0][1] + psum0[1][0][2] + psum0[1][1][0] + psum0[1][1][1] + psum0[1][1][2] + psum0[1][2][0] + psum0[1][2][1] + psum0[1][2][2];
	psum11_mul_9_nx = psum1[1][0][0] + psum1[1][0][1] + psum1[1][0][2] + psum1[1][1][0] + psum1[1][1][1] + psum1[1][1][2] + psum1[1][2][0] + psum1[1][2][1] + psum1[1][2][2];
	psum21_mul_9_nx = psum2[1][0][0] + psum2[1][0][1] + psum2[1][0][2] + psum2[1][1][0] + psum2[1][1][1] + psum2[1][1][2] + psum2[1][2][0] + psum2[1][2][1] + psum2[1][2][2];// + psum2[2][0][0] + psum2[2][0][1] + psum2[2][0][2] + psum2[2][1][0] + psum2[2][1][1] + psum2[2][1][2] + psum2[2][2][0] + psum2[2][2][1] + psum2[2][2][2] + psum2[3][0][0] + psum2[3][0][1] + psum2[3][0][2] + psum2[3][1][0] + psum2[3][1][1] + psum2[3][1][2] + psum2[3][2][0] + psum2[3][2][1] + psum2[3][2][2];
	psum31_mul_9_nx = psum3[1][0][0] + psum3[1][0][1] + psum3[1][0][2] + psum3[1][1][0] + psum3[1][1][1] + psum3[1][1][2] + psum3[1][2][0] + psum3[1][2][1] + psum3[1][2][2];// + psum3[2][0][0] + psum3[2][0][1] + psum3[2][0][2] + psum3[2][1][0] + psum3[2][1][1] + psum3[2][1][2] + psum3[2][2][0] + psum3[2][2][1] + psum3[2][2][2] + psum3[3][0][0] + psum3[3][0][1] + psum3[3][0][2] + psum3[3][1][0] + psum3[3][1][1] + psum3[3][1][2] + psum3[3][2][0] + psum3[3][2][1] + psum3[3][2][2];
	psum02_mul_9_nx = psum0[2][0][0] + psum0[2][0][1] + psum0[2][0][2] + psum0[2][1][0] + psum0[2][1][1] + psum0[2][1][2] + psum0[2][2][0] + psum0[2][2][1] + psum0[2][2][2];// + psum0[3][0][0] + psum0[3][0][1] + psum0[3][0][2] + psum0[3][1][0] + psum0[3][1][1] + psum0[3][1][2] + psum0[3][2][0] + psum0[3][2][1] + psum0[3][2][2];
	psum12_mul_9_nx = psum1[2][0][0] + psum1[2][0][1] + psum1[2][0][2] + psum1[2][1][0] + psum1[2][1][1] + psum1[2][1][2] + psum1[2][2][0] + psum1[2][2][1] + psum1[2][2][2];// + psum1[3][0][0] + psum1[3][0][1] + psum1[3][0][2] + psum1[3][1][0] + psum1[3][1][1] + psum1[3][1][2] + psum1[3][2][0] + psum1[3][2][1] + psum1[3][2][2];
	psum22_mul_9_nx = psum2[2][0][0] + psum2[2][0][1] + psum2[2][0][2] + psum2[2][1][0] + psum2[2][1][1] + psum2[2][1][2] + psum2[2][2][0] + psum2[2][2][1] + psum2[2][2][2];// + psum2[3][0][0] + psum2[3][0][1] + psum2[3][0][2] + psum2[3][1][0] + psum2[3][1][1] + psum2[3][1][2] + psum2[3][2][0] + psum2[3][2][1] + psum2[3][2][2];
	psum32_mul_9_nx = psum3[2][0][0] + psum3[2][0][1] + psum3[2][0][2] + psum3[2][1][0] + psum3[2][1][1] + psum3[2][1][2] + psum3[2][2][0] + psum3[2][2][1] + psum3[2][2][2];// + psum3[3][0][0] + psum3[3][0][1] + psum3[3][0][2] + psum3[3][1][0] + psum3[3][1][1] + psum3[3][1][2] + psum3[3][2][0] + psum3[3][2][1] + psum3[3][2][2];
	psum03_mul_9_nx = psum0[3][0][0] + psum0[3][0][1] + psum0[3][0][2] + psum0[3][1][0] + psum0[3][1][1] + psum0[3][1][2] + psum0[3][2][0] + psum0[3][2][1] + psum0[3][2][2];
	psum13_mul_9_nx = psum1[3][0][0] + psum1[3][0][1] + psum1[3][0][2] + psum1[3][1][0] + psum1[3][1][1] + psum1[3][1][2] + psum1[3][2][0] + psum1[3][2][1] + psum1[3][2][2];
	psum23_mul_9_nx = psum2[3][0][0] + psum2[3][0][1] + psum2[3][0][2] + psum2[3][1][0] + psum2[3][1][1] + psum2[3][1][2] + psum2[3][2][0] + psum2[3][2][1] + psum2[3][2][2];
	psum33_mul_9_nx = psum3[3][0][0] + psum3[3][0][1] + psum3[3][0][2] + psum3[3][1][0] + psum3[3][1][1] + psum3[3][1][2] + psum3[3][2][0] + psum3[3][2][1] + psum3[3][2][2];
	psum0_mul_all = psum00_mul_9 + psum01_mul_9 + psum02_mul_9 + psum03_mul_9;
	psum1_mul_all = psum10_mul_9 + psum11_mul_9 + psum12_mul_9 + psum13_mul_9;
	psum2_mul_all = psum20_mul_9 + psum21_mul_9 + psum22_mul_9 + psum23_mul_9;
	psum3_mul_all = psum30_mul_9 + psum31_mul_9 + psum32_mul_9 + psum33_mul_9;
	/*
	psum0_mul_all = psum0[0][0][0] + psum0[0][0][1] + psum0[0][0][2] + psum0[0][1][0] + psum0[0][1][1] + psum0[0][1][2] + psum0[0][2][0] + psum0[0][2][1] + psum0[0][2][2] + psum0[1][0][0] + psum0[1][0][1] + psum0[1][0][2] + psum0[1][1][0] + psum0[1][1][1] + psum0[1][1][2] + psum0[1][2][0] + psum0[1][2][1] + psum0[1][2][2] + psum0[2][0][0] + psum0[2][0][1] + psum0[2][0][2] + psum0[2][1][0] + psum0[2][1][1] + psum0[2][1][2] + psum0[2][2][0] + psum0[2][2][1] + psum0[2][2][2] + psum0[3][0][0] + psum0[3][0][1] + psum0[3][0][2] + psum0[3][1][0] + psum0[3][1][1] + psum0[3][1][2] + psum0[3][2][0] + psum0[3][2][1] + psum0[3][2][2];
	psum1_mul_all = psum1[0][0][0] + psum1[0][0][1] + psum1[0][0][2] + psum1[0][1][0] + psum1[0][1][1] + psum1[0][1][2] + psum1[0][2][0] + psum1[0][2][1] + psum1[0][2][2] + psum1[1][0][0] + psum1[1][0][1] + psum1[1][0][2] + psum1[1][1][0] + psum1[1][1][1] + psum1[1][1][2] + psum1[1][2][0] + psum1[1][2][1] + psum1[1][2][2] + psum1[2][0][0] + psum1[2][0][1] + psum1[2][0][2] + psum1[2][1][0] + psum1[2][1][1] + psum1[2][1][2] + psum1[2][2][0] + psum1[2][2][1] + psum1[2][2][2] + psum1[3][0][0] + psum1[3][0][1] + psum1[3][0][2] + psum1[3][1][0] + psum1[3][1][1] + psum1[3][1][2] + psum1[3][2][0] + psum1[3][2][1] + psum1[3][2][2];
	psum2_mul_all = psum2[0][0][0] + psum2[0][0][1] + psum2[0][0][2] + psum2[0][1][0] + psum2[0][1][1] + psum2[0][1][2] + psum2[0][2][0] + psum2[0][2][1] + psum2[0][2][2] + psum2[1][0][0] + psum2[1][0][1] + psum2[1][0][2] + psum2[1][1][0] + psum2[1][1][1] + psum2[1][1][2] + psum2[1][2][0] + psum2[1][2][1] + psum2[1][2][2] + psum2[2][0][0] + psum2[2][0][1] + psum2[2][0][2] + psum2[2][1][0] + psum2[2][1][1] + psum2[2][1][2] + psum2[2][2][0] + psum2[2][2][1] + psum2[2][2][2] + psum2[3][0][0] + psum2[3][0][1] + psum2[3][0][2] + psum2[3][1][0] + psum2[3][1][1] + psum2[3][1][2] + psum2[3][2][0] + psum2[3][2][1] + psum2[3][2][2];
	psum3_mul_all = psum3[0][0][0] + psum3[0][0][1] + psum3[0][0][2] + psum3[0][1][0] + psum3[0][1][1] + psum3[0][1][2] + psum3[0][2][0] + psum3[0][2][1] + psum3[0][2][2] + psum3[1][0][0] + psum3[1][0][1] + psum3[1][0][2] + psum3[1][1][0] + psum3[1][1][1] + psum3[1][1][2] + psum3[1][2][0] + psum3[1][2][1] + psum3[1][2][2] + psum3[2][0][0] + psum3[2][0][1] + psum3[2][0][2] + psum3[2][1][0] + psum3[2][1][1] + psum3[2][1][2] + psum3[2][2][0] + psum3[2][2][1] + psum3[2][2][2] + psum3[3][0][0] + psum3[3][0][1] + psum3[3][0][2] + psum3[3][1][0] + psum3[3][1][1] + psum3[3][1][2] + psum3[3][2][0] + psum3[3][2][1] + psum3[3][2][2];*/
end

always@* begin
	psum0_bias = psum0_mul_forpool + bias_shift;
	psum1_bias = psum1_mul_forpool + bias_shift;
	psum2_bias = psum2_mul_forpool + bias_shift;
	psum3_bias = psum3_mul_forpool + bias_shift;

	if(psum0_bias < 0) psum0_relu = 0;
	else psum0_relu = psum0_bias;
	if(psum1_bias < 0) psum1_relu = 0;
	else psum1_relu = psum1_bias;
	if(psum2_bias < 0) psum2_relu = 0;
	else psum2_relu = psum2_bias;
	if(psum3_bias < 0) psum3_relu = 0;
	else psum3_relu = psum3_bias;

	psum_pool_sum = psum0_relu + psum1_relu + psum2_relu + psum3_relu;
	psum_pool = psum_pool_sum[BW_PER_ACT+BW_PER_PARAM+2+6-1:2] + 64;
	psum0_nopool = psum0_relu + 64;
	psum1_nopool = psum1_relu + 64;
	psum2_nopool = psum2_relu + 64;
	psum3_nopool = psum3_relu + 64;
	

	psum_bias_shift = psum_pool[BW_PER_ACT+BW_PER_PARAM+6-1:7]; 
	psum0_bias_shift = psum0_nopool[BW_PER_ACT+BW_PER_PARAM+6-1:7]; 
	psum1_bias_shift = psum1_nopool[BW_PER_ACT+BW_PER_PARAM+6-1:7]; 
	psum2_bias_shift = psum2_nopool[BW_PER_ACT+BW_PER_PARAM+6-1:7]; 
	psum3_bias_shift = psum3_nopool[BW_PER_ACT+BW_PER_PARAM+6-1:7]; 
	if(conv3_en) begin
		if(psum_bias_shift > 2047) out_pool = 2047;
		else if(psum_bias_shift < -2048) out_pool = -2048;
		else out_pool = psum_bias_shift[11:0];
	end
	else begin
		out_pool = 0;
	end
end

always@* begin
	if(psum0_bias_shift > 2047) out00 = 2047;
	else if(psum0_bias_shift < -2048) out00 = -2048;
	else out00 = psum0_bias_shift[11:0];
	if(psum1_bias_shift > 2047) out01 = 2047;
	else if(psum1_bias_shift < -2048) out01 = -2048;
	else out01 = psum1_bias_shift[11:0];
	if(psum2_bias_shift > 2047) out02 = 2047;
	else if(psum2_bias_shift < -2048) out02 = -2048;
	else out02 = psum2_bias_shift[11:0];
	if(psum3_bias_shift > 2047) out03 = 2047;
	else if(psum3_bias_shift < -2048) out03 = -2048;
	else out03 = psum3_bias_shift[11:0];
end

always@* begin
	if(!conv3_en) begin
		out = {out00, out01, out02, out03};
	end
	else begin
		if(idc_row) begin
			if(idc_col) begin
				out = {36'b0, out_pool};	
			end
			else begin
				out = {24'b0, out_pool, 12'b0};
			end
		end
		else begin
			if(idc_col) begin
				out = {12'b0, out_pool, 24'b0};
			end
			else begin
				out = {out_pool, 36'b0};
			end
		end
	end
end

always@* begin
	for(i = 0; i < 3; i = i + 1) begin
		for(j = 0; j < 3; j = j + 1) begin
			ifmap0[0][i][j] = in0[(3*i+j+1)*12-1-:12];
			ifmap0[1][i][j] = in1[(3*i+j+1)*12-1-:12];
			ifmap0[2][i][j] = in2[(3*i+j+1)*12-1-:12];
			ifmap0[3][i][j] = in3[(3*i+j+1)*12-1-:12];
			ifmap1[0][i][j] = in4[(3*i+j+1)*12-1-:12];
			ifmap1[1][i][j] = in5[(3*i+j+1)*12-1-:12];
			ifmap1[2][i][j] = in6[(3*i+j+1)*12-1-:12];
			ifmap1[3][i][j] = in7[(3*i+j+1)*12-1-:12];
			ifmap2[0][i][j] = in8[(3*i+j+1)*12-1-:12];
			ifmap2[1][i][j] = in9[(3*i+j+1)*12-1-:12];
			ifmap2[2][i][j] = in10[(3*i+j+1)*12-1-:12];
			ifmap2[3][i][j] = in11[(3*i+j+1)*12-1-:12];
			ifmap3[0][i][j] = in12[(3*i+j+1)*12-1-:12];
			ifmap3[1][i][j] = in13[(3*i+j+1)*12-1-:12];
			ifmap3[2][i][j] = in14[(3*i+j+1)*12-1-:12];
			ifmap3[3][i][j] = in15[(3*i+j+1)*12-1-:12];
			weight[0][i][j] = weight0[(3*i+j+1)*8-1-:8];
			weight[1][i][j] = weight1[(3*i+j+1)*8-1-:8];
			weight[2][i][j] = weight2[(3*i+j+1)*8-1-:8];
			weight[3][i][j] = weight3[(3*i+j+1)*8-1-:8];
		end
	end	
end

always@* begin
	in0 = {map0[191:180], map0[179:168], map1[191:180], map0[167:156], map0[155:144], map1[167:156], map2[191:180], map2[179:168], map3[191:180]};
	in1 = {map0[143:132], map0[131:120], map1[143:132], map0[119:108], map0[107:96], map1[119:108], map2[143:132], map2[131:120], map3[143:132]};
	in2 = {map0[95:84], map0[83:72], map1[95:84], map0[71:60], map0[59:48], map1[71:60], map2[95:84], map2[83:72], map3[95:84]};
	in3 = {map0[47:36], map0[35:24], map1[47:36], map0[23:12], map0[11:0], map1[23:12], map2[47:36], map2[35:24], map3[47:36]};
	in4 = {map0[179:168], map1[191:180], map1[179:168], map0[155:144], map1[167:156], map1[155:144], map2[179:168], map3[191:180], map3[179:168]};
	in5 = {map0[131:120], map1[143:132], map1[131:120], map0[107:96], map1[119:108], map1[107:96], map2[131:120], map3[143:132], map3[131:120]};
	in6 = {map0[83:72], map1[95:84], map1[83:72], map0[59:48], map1[71:60], map1[59:48], map2[83:72], map3[95:84], map3[83:72]};
	in7 = {map0[35:24], map1[47:36], map1[35:24], map0[11:0], map1[23:12], map1[11:0], map2[35:24], map3[47:36], map3[35:24]};
	in8 = {map0[167:156], map0[155:144], map1[167:156], map2[191:180], map2[179:168], map3[191:180], map2[167:156], map2[155:144], map3[167:156]};
	in9 = {map0[119:108], map0[107:96], map1[119:108], map2[143:132], map2[131:120], map3[143:132], map2[119:108], map2[107:96], map3[119:108]};
	in10= {map0[71:60], map0[59:48], map1[71:60], map2[95:84], map2[83:72], map3[95:84], map2[71:60], map2[59:48], map3[71:60]};
	in11= {map0[23:12], map0[11:0], map1[23:12], map2[47:36], map2[35:24], map3[47:36], map2[23:12], map2[11:0], map3[23:12]};
	in12= {map0[155:144], map1[167:156], map1[155:144], map2[179:168], map3[191:180], map3[179:168], map2[155:144], map3[167:156], map3[155:144]};
	in13= {map0[107:96], map1[119:108], map1[107:96], map2[131:120], map3[143:132], map3[131:120], map2[107:96], map3[119:108], map3[107:96]};
	in14= {map0[59:48], map1[71:60], map1[59:48], map2[83:72], map3[95:84], map3[83:72], map2[59:48], map3[71:60], map3[59:48]};
	in15= {map0[11:0], map1[23:12], map1[11:0], map2[35:24], map3[47:36], map3[35:24], map2[11:0], map3[23:12], map3[11:0]};
end

endmodule
