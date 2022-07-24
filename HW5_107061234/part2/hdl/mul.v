module mul#(
parameter CH_NUM = 4,
parameter ACT_PER_ADDR = 4,
parameter BW_PER_ACT = 12,
parameter WEIGHT_PER_ADDR = 9, 
parameter BIAS_PER_ADDR = 1,
parameter BW_PER_PARAM = 8
)
(
input [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] weight0,
input [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] weight1,
input [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] weight2,
input [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] weight3,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] map0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] map1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] map2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] map3,
input signed [BW_PER_PARAM-1:0] bias,
input [1:0] cnt,
output reg signed [BW_PER_ACT-1:0] out
);

reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in0;
reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in1;
reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in2;
reg [WEIGHT_PER_ADDR*BW_PER_ACT-1:0] in3;

reg signed [BW_PER_ACT-1:0] ifmap [0:3][0:2][0:2];
reg signed [BW_PER_PARAM-1:0] weight [0:3][0:2][0:2];
reg signed [BW_PER_ACT+BW_PER_PARAM-1:0] psum [0:3][0:2][0:2];
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum_mul_all;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-1:0] psum_bias;
reg signed [BW_PER_PARAM+8-1:0] bias_shift;
reg signed [BW_PER_ACT+BW_PER_PARAM+6-7-1:0] psum_bias_shift;
reg signed [BW_PER_ACT-1:0] out_prerelu;

integer i, j, k;

always@* begin
	bias_shift = {bias, 8'b0};
	for(i = 0; i < 4; i = i + 1) begin
		for(j = 0; j < 3; j = j + 1) begin
			for(k = 0; k < 3; k = k + 1) begin
				psum[i][j][k] = ifmap[i][j][k] * weight[i][j][k];
			end
		end
	end
	psum_mul_all = psum[0][0][0] + psum[0][0][1] + psum[0][0][2] + psum[0][1][0] + psum[0][1][1] + psum[0][1][2] + psum[0][2][0] + psum[0][2][1] + psum[0][2][2] + psum[1][0][0] + psum[1][0][1] + psum[1][0][2] + psum[1][1][0] + psum[1][1][1] + psum[1][1][2] + psum[1][2][0] + psum[1][2][1] + psum[1][2][2] + psum[2][0][0] + psum[2][0][1] + psum[2][0][2] + psum[2][1][0] + psum[2][1][1] + psum[2][1][2] + psum[2][2][0] + psum[2][2][1] + psum[2][2][2] + psum[3][0][0] + psum[3][0][1] + psum[3][0][2] + psum[3][1][0] + psum[3][1][1] + psum[3][1][2] + psum[3][2][0] + psum[3][2][1] + psum[3][2][2];
	psum_bias = psum_mul_all + bias_shift + 64;
	//psum_bias_shift = psum_bias >> 7;
	psum_bias_shift = psum_bias[BW_PER_ACT+BW_PER_PARAM+6-1:7];
	if(psum_bias_shift > 2047) out_prerelu = 2047;
	else if(psum_bias_shift < -2048) out_prerelu = -2048;
	else out_prerelu = psum_bias_shift[11:0];
	if(out_prerelu < 0) out = 0;
	else out = out_prerelu;
end

always@* begin
	for(i = 0; i < 3; i = i + 1) begin
		for(j = 0; j < 3; j = j + 1) begin
			ifmap[0][i][j] = in0[(3*i+j+1)*12-1-:12];
			ifmap[1][i][j] = in1[(3*i+j+1)*12-1-:12];
			ifmap[2][i][j] = in2[(3*i+j+1)*12-1-:12];
			ifmap[3][i][j] = in3[(3*i+j+1)*12-1-:12];
			weight[0][i][j] = weight0[(3*i+j+1)*8-1-:8];
			weight[1][i][j] = weight1[(3*i+j+1)*8-1-:8];
			weight[2][i][j] = weight2[(3*i+j+1)*8-1-:8];
			weight[3][i][j] = weight3[(3*i+j+1)*8-1-:8];
		end
	end	
end

always@* begin
	in0 = 0;
	in1 = 0;
	in2 = 0;
	in3 = 0;
	case(cnt) 
		0: begin
			in0 = {map0[191:180], map0[179:168], map1[191:180], map0[167:156], map0[155:144], map1[167:156], map2[191:180], map2[179:168], map3[191:180]};
			in1 = {map0[143:132], map0[131:120], map1[143:132], map0[119:108], map0[107:96], map1[119:108], map2[143:132], map2[131:120], map3[143:132]};
			in2 = {map0[95:84], map0[83:72], map1[95:84], map0[71:60], map0[59:48], map1[71:60], map2[95:84], map2[83:72], map3[95:84]};
			in3 = {map0[47:36], map0[35:24], map1[47:36], map0[23:12], map0[11:0], map1[23:12], map2[47:36], map2[35:24], map3[47:36]};
		end
		1: begin
			in0 = {map0[179:168], map1[191:180], map1[179:168], map0[155:144], map1[167:156], map1[155:144], map2[179:168], map3[191:180], map3[179:168]};
			in1 = {map0[131:120], map1[143:132], map1[131:120], map0[107:96], map1[119:108], map1[107:96], map2[131:120], map3[143:132], map3[131:120]};
			in2 = {map0[83:72], map1[95:84], map1[83:72], map0[59:48], map1[71:60], map1[59:48], map2[83:72], map3[95:84], map3[83:72]};
			in3 = {map0[35:24], map1[47:36], map1[35:24], map0[11:0], map1[23:12], map1[11:0], map2[35:24], map3[47:36], map3[35:24]};
		end
		2: begin
			in0 = {map0[167:156], map0[155:144], map1[167:156], map2[191:180], map2[179:168], map3[191:180], map2[167:156], map2[155:144], map3[167:156]};
			in1 = {map0[119:108], map0[107:96], map1[119:108], map2[143:132], map2[131:120], map3[143:132], map2[119:108], map2[107:96], map3[119:108]};
			in2 = {map0[71:60], map0[59:48], map1[71:60], map2[95:84], map2[83:72], map3[95:84], map2[71:60], map2[59:48], map3[71:60]};
			in3 = {map0[23:12], map0[11:0], map1[23:12], map2[47:36], map2[35:24], map3[47:36], map2[23:12], map2[11:0], map3[23:12]};
		end		
		3: begin
			in0 = {map0[155:144], map1[167:156], map1[155:144], map2[179:168], map3[191:180], map3[179:168], map2[155:144], map3[167:156], map3[155:144]};
			in1 = {map0[107:96], map1[119:108], map1[107:96], map2[131:120], map3[143:132], map3[131:120], map2[107:96], map3[119:108], map3[107:96]};
			in2 = {map0[59:48], map1[71:60], map1[59:48], map2[83:72], map3[95:84], map3[83:72], map2[59:48], map3[71:60], map3[59:48]};
			in3 = {map0[11:0], map1[23:12], map1[11:0], map2[35:24], map3[47:36], map3[35:24], map2[11:0], map3[23:12], map3[11:0]};
		end
		default: begin
			in0 = 0;
			in1 = 0;
			in2 = 0;
			in3 = 0;
		end
	endcase
end

endmodule
