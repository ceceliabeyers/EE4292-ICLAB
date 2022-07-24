module conv_ctrl#(
parameter CH_NUM = 4,
parameter ACT_PER_ADDR = 4,
parameter BW_PER_ACT = 12,
parameter WEIGHT_PER_ADDR = 9, 
parameter BIAS_PER_ADDR = 1,
parameter BW_PER_PARAM = 8
)
(
input clk,
input rst_n,
input conv1_en,
input conv2_en,
input conv3_en,
// read data from SRAM group A
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a3,
// read data from SRAM group B
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b3,
// read data from parameter SRAM
input [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_weight,  
input [BIAS_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_bias,   
// write enable for SRAM group A
output reg sram_wen_a0_d1,
output reg sram_wen_a1_d1,
output reg sram_wen_a2_d1,
output reg sram_wen_a3_d1,
// wordmask for SRAM group A 
output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a_d1,
// write addrress to SRAM group A 
output reg [5:0] sram_waddr_a_d1,

// write enable for SRAM group B
output reg sram_wen_b0_d1,
output reg sram_wen_b1_d1,
output reg sram_wen_b2_d1,
output reg sram_wen_b3_d1,
// wordmask for SRAM group B
output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b_d1,
// write addrress to SRAM group B 
output reg [5:0] sram_waddr_b_d1,

// read address to SRAM group A
output reg [5:0] sram_raddr_a0,
output reg [5:0] sram_raddr_a1,
output reg [5:0] sram_raddr_a2,
output reg [5:0] sram_raddr_a3,
// read address to SRAM group B
output reg [5:0] sram_raddr_b0,
output reg [5:0] sram_raddr_b1,
output reg [5:0] sram_raddr_b2,
output reg [5:0] sram_raddr_b3,

// read address to parameter SRAM
output reg [9:0] sram_raddr_weight,       
output reg [5:0] sram_raddr_bias,  

// write data to SRAM groups A & B
output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a,
output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b,

output reg valid1,
output reg valid2,
output reg valid3
);

localparam IDLE = 3'd0, LOAD = 3'd1, COMPUTE = 3'd2, WAIT = 3'd3, LOAD2 = 3'd4;

reg [2:0] state, n_state;
reg [5:0] cnt, cnt_nx;
reg [2:0] cnt_read_col, cnt_read_col_nx;
reg [2:0] cnt_read_row, cnt_read_row_nx;
reg [1:0] cnt_read_ch, cnt_read_ch_nx;
reg [2:0] cnt_compute_col, cnt_compute_col_nx;
reg [2:0] cnt_compute_row, cnt_compute_row_nx;
reg [1:0] cnt_compute_ch, cnt_compute_ch_nx;
reg [5:0] cnt_ofmap, cnt_ofmap_nx;
reg [5:0] cnt_ofmap_minus1;
reg refresh;

reg [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] weight [0:11];
reg [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] weight_nx [0:11];
reg [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] weight0;
reg [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] weight1;
reg [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] weight2;
reg [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] weight3;
reg [BIAS_PER_ADDR*BW_PER_PARAM-1:0] bias;
reg [BIAS_PER_ADDR*BW_PER_PARAM-1:0] bias_nx;

reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] map0;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] map1;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] map2;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] map3;

reg [3:0] mask_partial;
reg [4*BW_PER_ACT-1:0] wdata_partial;

wire [4*BW_PER_ACT-1:0] mul_out;

reg valid1_nx;
reg valid2_nx;
reg valid3_nx;
/* add */
reg sram_wen_a0;
reg sram_wen_a1;
reg sram_wen_a2;
reg sram_wen_a3;
// wordmask for SRAM group A 
reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a;
// write addrress to SRAM group A 
reg [5:0] sram_waddr_a;
reg sram_wen_b0;
reg sram_wen_b1;
reg sram_wen_b2;
reg sram_wen_b3;
// wordmask for SRAM group A 
reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b;
// write addrress to SRAM group A 
reg [5:0] sram_waddr_b;

reg q1, q2;
mul #(
.CH_NUM(CH_NUM),
.ACT_PER_ADDR(ACT_PER_ADDR),
.BW_PER_ACT(BW_PER_ACT),
.WEIGHT_PER_ADDR(WEIGHT_PER_ADDR), 
.BIAS_PER_ADDR(BIAS_PER_ADDR),
.BW_PER_PARAM(BW_PER_PARAM)
) mul
(
.clk(clk),
.weight0(weight0),
.weight1(weight1),
.weight2(weight2),
.weight3(weight3),
.map0(map0),
.map1(map1),
.map2(map2),
.map3(map3),
//.idc_row(cnt_compute_row[0]),
//.idc_col(cnt_compute_col[0]),
.idc_row(q1),
.idc_col(q2),
.refresh(refresh),
.conv3_en(conv3_en),
.bias(bias),
.out(mul_out)
);


always@(posedge clk) begin
	q1 <= cnt_compute_row[0];
	q2 <= cnt_compute_col[0];
end
	
always@(posedge clk) begin
	if(~rst_n) begin
		state <= IDLE;
	end
	else begin
	 	state <= n_state;
	end
end

integer i, j, k;

always@(posedge clk) begin
	cnt <= cnt_nx;
	for(i = 0; i < 12; i = i + 1) begin
		weight[i] <= weight_nx[i];
	end
	bias <= bias_nx;
	cnt_read_col <= cnt_read_col_nx;
	cnt_read_row <= cnt_read_row_nx;
	cnt_read_ch <= cnt_read_ch_nx;
	cnt_compute_col <= cnt_compute_col_nx;
	cnt_compute_row <= cnt_compute_row_nx;
	cnt_compute_ch <= cnt_compute_ch_nx;
	cnt_ofmap <= cnt_ofmap_nx;
	valid1 <= valid1_nx;
	valid2 <= valid2_nx;
	valid3 <= valid3_nx;
	sram_wen_a0_d1 <= sram_wen_a0;
	sram_wen_a1_d1 <= sram_wen_a1;
	sram_wen_a2_d1 <= sram_wen_a2;
	sram_wen_a3_d1 <= sram_wen_a3; 
	sram_wordmask_a_d1 <= sram_wordmask_a;
	sram_waddr_a_d1 <= sram_waddr_a;
	sram_wen_b0_d1 <= sram_wen_b0;
	sram_wen_b1_d1 <= sram_wen_b1;
	sram_wen_b2_d1 <= sram_wen_b2;
	sram_wen_b3_d1 <= sram_wen_b3; 
	sram_wordmask_b_d1 <= sram_wordmask_b;
	sram_waddr_b_d1 <= sram_waddr_b;
end

always@* begin
	cnt_ofmap_minus1 = cnt_ofmap - 1;
end

always@* begin
	case(state)
		IDLE: begin
			if(conv1_en) n_state = LOAD;
			else if(conv2_en) n_state = LOAD;
			else if(conv3_en) n_state = LOAD;
			else n_state = IDLE;
		end
		LOAD: begin
			if(conv3_en) begin
				if(cnt == 12) n_state = COMPUTE;
				else n_state = LOAD;
			end
			else begin
				if(cnt == 4) n_state = COMPUTE;
				else n_state = LOAD;
			end
		end
		LOAD2: begin
			if(conv3_en) begin
				if(cnt == 10) n_state = COMPUTE;
				else n_state = LOAD2;
			end
			else begin
				if(cnt == 2) n_state = COMPUTE;
				else n_state = LOAD2;
			end
		end
		COMPUTE: begin
			if(conv1_en) begin
		//		if(cnt_compute_row == 5 && cnt_compute_col == 5) begin
				if(cnt == 35) begin
				//	n_state = WAIT;
					if(cnt_ofmap == 3) n_state = WAIT;
					else n_state = LOAD2;  //mod
				end
				else n_state = COMPUTE;
			end
			else if(conv2_en) begin
				//if(cnt_compute_row == 4 && cnt_compute_col == 4) begin 
				if(cnt == 24) begin
				//	n_state = WAIT;
					if(cnt_ofmap == 11) n_state = WAIT;
					else n_state = LOAD2;
				end
				else n_state = COMPUTE;
			end
			else if(conv3_en) begin
				//if(cnt_compute_row == 3 && cnt_compute_col == 3 && cnt_compute_ch == 2) begin
				if(cnt == 47) begin
					//n_state = WAIT;
					if(cnt_ofmap == 47) n_state = WAIT;
					else n_state = LOAD2;
				end
				else n_state = COMPUTE;
			end
			else n_state = COMPUTE;
		end	
		WAIT: begin
			 n_state = IDLE;
		end
		default: n_state = IDLE; 
	endcase
end

always@* begin    //OKK
	cnt_nx = 0;
	valid1_nx = 0;
	valid2_nx = 0;
	valid3_nx = 0;
	refresh = 0;
	cnt_read_col_nx = cnt_read_col;
	cnt_read_row_nx = cnt_read_row;
	cnt_read_ch_nx = cnt_read_ch;
	cnt_compute_ch_nx = cnt_compute_ch;
	cnt_compute_row_nx = cnt_compute_row;
	cnt_compute_col_nx = cnt_compute_col;
	cnt_ofmap_nx = cnt_ofmap;
	if(conv1_en) begin
		case(state)
			IDLE: begin
				cnt_nx = 0;
				cnt_read_col_nx = 0;
				cnt_read_row_nx = 0;
				cnt_compute_col_nx = 0;
				cnt_compute_row_nx = 0;
				cnt_ofmap_nx = 0;
				valid1_nx = 0;
				valid2_nx = 0;
			end
			LOAD: begin
				valid1_nx = 0;
				valid2_nx = 0;
				cnt_read_col_nx = 0;
				cnt_read_row_nx = 0;	
				cnt_compute_col_nx = 0;
				cnt_compute_row_nx = 0;
				cnt_ofmap_nx = cnt_ofmap;	
				if(cnt == 4) cnt_nx = 0;
				else cnt_nx = cnt + 1;
				if(cnt == 3) cnt_read_col_nx = 1;
				else if(cnt == 4) cnt_read_col_nx = 2;
			end
			LOAD2: begin  //MOD
				valid1_nx = 0;
				valid2_nx = 0;
				cnt_read_col_nx = 0;
				cnt_read_row_nx = 0;	
				cnt_compute_col_nx = 0;
				cnt_compute_row_nx = 0;
				cnt_ofmap_nx = cnt_ofmap;	
				if(cnt == 2) cnt_nx = 0;
				else cnt_nx = cnt + 1;
				if(cnt == 1) cnt_read_col_nx = 1;
				else if(cnt == 2) cnt_read_col_nx = 2;
			end
			COMPUTE: begin
				//if(cnt_compute_row == 5 && cnt_compute_col == 5) begin
				if(cnt == 35) begin
					valid2_nx = 0;
					cnt_nx = 0;
					cnt_read_col_nx = 0;
					cnt_read_row_nx = 0;	
					cnt_compute_col_nx = 0;
					cnt_compute_row_nx = 0;
					cnt_ofmap_nx = cnt_ofmap + 1;  //+1
					if(cnt_ofmap == 3) valid1_nx = 1;
					else valid1_nx = 0;
				end
				else begin
					cnt_nx = cnt + 1;
					valid1_nx = 0;
					valid2_nx = 0;
					cnt_ofmap_nx = cnt_ofmap;	
					if(cnt_read_col == 5) begin
						cnt_read_row_nx = cnt_read_row + 1; 
						cnt_read_col_nx = 0;
					end
					else begin
						cnt_read_row_nx = cnt_read_row;
						cnt_read_col_nx = cnt_read_col + 1;
					end
					if(cnt_compute_col == 5) begin
						cnt_compute_row_nx = cnt_compute_row + 1;
						cnt_compute_col_nx = 0;
					end
					else begin
						cnt_compute_row_nx = cnt_compute_row;
						cnt_compute_col_nx = cnt_compute_col + 1;
					end
				end
			end
			WAIT: begin	
				cnt_ofmap_nx = cnt_ofmap; //ori +1
			end
			default: begin
				cnt_read_col_nx = 0;
				cnt_read_row_nx = 0;
				cnt_compute_col_nx = 0;
				cnt_compute_row_nx = 0;
				cnt_ofmap_nx = 0;
				cnt_nx = cnt;
				valid1_nx = 0;
				valid2_nx = 0;
			end
		endcase
	end
	else if(conv2_en) begin
		case(state)
			IDLE: begin
				cnt_nx = 0;
				cnt_read_col_nx = 0;
				cnt_read_row_nx = 0;
				cnt_compute_col_nx = 0;
				cnt_compute_row_nx = 0;
				cnt_ofmap_nx = 0;
				valid1_nx = 0;
				valid2_nx = 0;
			end
			LOAD: begin
				valid1_nx = 0;
				valid2_nx = 0;
				cnt_read_col_nx = 0;
				cnt_read_row_nx = 0;	
				cnt_compute_col_nx = 0;
				cnt_compute_row_nx = 0;
				cnt_ofmap_nx = cnt_ofmap;	
				if(cnt == 4) cnt_nx = 0;
				else cnt_nx = cnt + 1;
				if(cnt == 3) cnt_read_col_nx = 1;
				else if(cnt == 4) cnt_read_col_nx = 2;
			end
			LOAD2: begin  //MOD
				valid1_nx = 0;
				valid2_nx = 0;
				cnt_read_col_nx = 0;
				cnt_read_row_nx = 0;	
				cnt_compute_col_nx = 0;
				cnt_compute_row_nx = 0;
				cnt_ofmap_nx = cnt_ofmap;	
				if(cnt == 2) cnt_nx = 0;
				else cnt_nx = cnt + 1;
				if(cnt == 1) cnt_read_col_nx = 1;
				else if(cnt == 2) cnt_read_col_nx = 2;
			end
			COMPUTE: begin
			//	if(cnt_compute_row == 4 && cnt_compute_col == 4) begin 
				if(cnt == 24) begin
					valid1_nx = 0;
					cnt_nx = 0;
					cnt_read_col_nx = 0;
					cnt_read_row_nx = 0;	
					cnt_compute_col_nx = 0;
					cnt_compute_row_nx = 0;
					cnt_ofmap_nx = cnt_ofmap + 1;
					if(cnt_ofmap == 11) valid2_nx = 1;
					else valid2_nx = 0;
				end
				else begin
					cnt_nx = cnt + 1;
					valid1_nx = 0;
					valid2_nx = 0;
					cnt_ofmap_nx = cnt_ofmap;	
					if(cnt_read_col == 4) begin
						cnt_read_row_nx = cnt_read_row + 1; 
						cnt_read_col_nx = 0;
					end
					else begin
						cnt_read_row_nx = cnt_read_row;
						cnt_read_col_nx = cnt_read_col + 1;
					end
					if(cnt_compute_col == 4) begin
						cnt_compute_row_nx = cnt_compute_row + 1;
						cnt_compute_col_nx = 0;
					end
					else begin
						cnt_compute_row_nx = cnt_compute_row;
						cnt_compute_col_nx = cnt_compute_col + 1;
					end
				end
			end
			WAIT: begin	
				cnt_ofmap_nx = cnt_ofmap;
			end
			default: begin
				cnt_read_col_nx = 0;
				cnt_read_row_nx = 0;
				cnt_compute_col_nx = 0;
				cnt_compute_row_nx = 0;
				cnt_ofmap_nx = 0;
				cnt_nx = cnt;
				valid1_nx = 0;
				valid2_nx = 0;
			end
		endcase
	end
	else if(conv3_en) begin
		case(state)
			IDLE: begin
				cnt_nx = 0;
				cnt_read_col_nx = 0;
				cnt_read_row_nx = 0;
				cnt_read_ch_nx = 0;
				cnt_ofmap_nx = 0;
				cnt_compute_ch_nx = 0;
				cnt_compute_col_nx = 0;
				cnt_compute_row_nx = 0;
				valid3_nx = 0;
				refresh = 0;
			end
			LOAD: begin
				valid3_nx = 0;
				cnt_read_col_nx = 0;
				cnt_read_row_nx = 0;	
				cnt_read_ch_nx = cnt - 10;
				cnt_ofmap_nx = cnt_ofmap;	
				cnt_compute_ch_nx = 0;
				cnt_compute_col_nx = 0;
				cnt_compute_row_nx = 0;
				if(cnt == 12) begin
					cnt_nx = 0;
				end
				else begin
					cnt_nx = cnt + 1;
				end
				refresh = 1;
			end
			LOAD2: begin
				valid3_nx = 0;
				cnt_read_col_nx = 0;
				cnt_read_row_nx = 0;	
				cnt_read_ch_nx = cnt - 8;
				cnt_ofmap_nx = cnt_ofmap;	
				cnt_compute_ch_nx = 0;
				cnt_compute_col_nx = 0;
				cnt_compute_row_nx = 0;
				if(cnt == 10) begin
					cnt_nx = 0;
				end
				else begin
					cnt_nx = cnt + 1;
				end
				refresh = 1;
			end
			COMPUTE: begin
				cnt_nx = cnt + 1;
				refresh = 0;
				if(cnt == 47) begin
				//if(cnt_compute_ch == 2 && cnt_compute_row == 3 && cnt_compute_col == 3) begin
					cnt_ofmap_nx = cnt_ofmap + 1;
					cnt_nx = 0;
					if(cnt_ofmap == 47) valid3_nx = 1;
					else valid3_nx = 0;
				end
				else begin
					cnt_ofmap_nx = cnt_ofmap;
					valid3_nx = 0;
				end
				if(cnt_read_ch == 2) cnt_read_ch_nx = 0;
				else cnt_read_ch_nx = cnt_read_ch + 1;
				if(cnt_compute_ch == 2) begin
					cnt_compute_ch_nx = 0;
					refresh = 1;
				end
				else begin 
					cnt_compute_ch_nx = cnt_compute_ch + 1;
					refresh = 0;
				end
				if(cnt_compute_ch == 2) begin
					if(cnt_compute_col == 3) begin
						cnt_compute_col_nx = 0;
						cnt_compute_row_nx = cnt_compute_row + 1;
					end
					else begin
						cnt_compute_col_nx = cnt_compute_col + 1;
						cnt_compute_row_nx = cnt_compute_row;
					end
				end
				else begin
					cnt_compute_col_nx = cnt_compute_col;
					cnt_compute_row_nx = cnt_compute_row;
				end
				if(cnt_read_ch == 2) begin
					if(cnt_read_col == 3) begin
						cnt_read_col_nx = 0;
						cnt_read_row_nx = cnt_read_row + 1;
					end
					else begin
						cnt_read_col_nx = cnt_read_col + 1;
						cnt_read_row_nx = cnt_read_row;
					end
				end
				else begin
					cnt_read_col_nx = cnt_read_col;
					cnt_read_row_nx = cnt_read_row;
				end
			end
			WAIT: begin	
				cnt_ofmap_nx = cnt_ofmap;
			end
			default: begin
				cnt_read_col_nx = 0;
				cnt_read_row_nx = 0;
				cnt_read_ch_nx = 0;
				cnt_ofmap_nx = 0;
				cnt_compute_ch_nx = 0;
				cnt_compute_col_nx = 0;
				cnt_compute_row_nx = 0;
				cnt_nx = cnt;
				valid3_nx = 0;
			end
		endcase
	end
end

always@* begin
	bias_nx = bias;
	for(i = 0; i < 12; i = i + 1) begin
		weight_nx[i] = weight[i];
	end

	case(state) 
		LOAD: begin
			if(cnt >= 2) begin
				weight_nx[cnt-2] = sram_rdata_weight;
				bias_nx = sram_rdata_bias;
			end
		end
		LOAD2: begin
			//if(cnt >= 2) begin
				weight_nx[cnt] = sram_rdata_weight;
				bias_nx = sram_rdata_bias;
			//end
		end
		COMPUTE: begin
			if(conv3_en) begin
				if(cnt == 0) begin
					weight_nx[11] = sram_rdata_weight;
					bias_nx = sram_rdata_bias;
				end
			end
			else begin
				if(cnt == 0) begin
					weight_nx[3] = sram_rdata_weight;
					bias_nx = sram_rdata_bias;
				end
			end
		end		
		default: begin
			bias_nx = bias;
			for(i = 0; i < 12; i = i + 1) begin
				weight_nx[i] = weight[i];
			end
		end
	endcase
end

always@* begin
	sram_wen_a0 = 1;
	sram_wen_a1 = 1;
	sram_wen_a2 = 1;
	sram_wen_a3 = 1;
	sram_wordmask_a = 16'hffff;
	sram_waddr_a = 0;
	sram_wen_b0 = 1;
	sram_wen_b1 = 1;
	sram_wen_b2 = 1;
	sram_wen_b3 = 1;
	sram_wordmask_b = 16'hffff;
	sram_waddr_b = 0;
	sram_raddr_b0 = 0;
	sram_raddr_b1 = 0;
	sram_raddr_b2 = 0;
	sram_raddr_b3 = 0;
	sram_raddr_weight = 0;       
	sram_raddr_bias = 0;
	sram_wdata_a = 0;
	sram_wdata_b = 0;
	sram_raddr_a0 = 0;
	sram_raddr_a1 = 0;
	sram_raddr_a2 = 0;
	sram_raddr_a3 = 0;
	if(conv1_en) begin
		sram_raddr_a0 = 6 * ((cnt_read_row + 1) >> 1) + ((cnt_read_col + 1) >> 1);
		sram_raddr_a1 = 6 * ((cnt_read_row + 1) >> 1) + (cnt_read_col >> 1);
		sram_raddr_a2 = 6 * (cnt_read_row >> 1) + ((cnt_read_col + 1) >> 1);
		sram_raddr_a3 = 6 * (cnt_read_row >> 1) + (cnt_read_col >> 1);
	end
	else if(conv2_en) begin
		sram_raddr_b0 = 6 * ((cnt_read_row + 1) >> 1) + ((cnt_read_col + 1) >> 1);
		sram_raddr_b1 = 6 * ((cnt_read_row + 1) >> 1) + (cnt_read_col >> 1);
		sram_raddr_b2 = 6 * (cnt_read_row >> 1) + ((cnt_read_col + 1) >> 1);
		sram_raddr_b3 = 6 * (cnt_read_row >> 1) + (cnt_read_col >> 1);
	end
	else if(conv3_en) begin
		case(cnt_read_ch)
			0: begin
				sram_raddr_a0 = 6 * ((cnt_read_row + 1) >> 1) + ((cnt_read_col + 1) >> 1);
				sram_raddr_a1 = 6 * ((cnt_read_row + 1) >> 1) + (cnt_read_col >> 1);
				sram_raddr_a2 = 6 * (cnt_read_row >> 1) + ((cnt_read_col + 1) >> 1);
				sram_raddr_a3 = 6 * (cnt_read_row >> 1) + (cnt_read_col >> 1);
			end
			1: begin
				sram_raddr_a0 = 6 * ((cnt_read_row + 1) >> 1) + ((cnt_read_col + 1) >> 1) + 3;
				sram_raddr_a1 = 6 * ((cnt_read_row + 1) >> 1) + (cnt_read_col >> 1) + 3;
				sram_raddr_a2 = 6 * (cnt_read_row >> 1) + ((cnt_read_col + 1) >> 1) + 3;
				sram_raddr_a3 = 6 * (cnt_read_row >> 1) + (cnt_read_col >> 1) + 3;
			end
			2: begin
				sram_raddr_a0 = 6 * (((cnt_read_row + 1) >> 1) + 3) + ((cnt_read_col + 1) >> 1);
				sram_raddr_a1 = 6 * (((cnt_read_row + 1) >> 1) + 3) + (cnt_read_col >> 1);
				sram_raddr_a2 = 6 * ((cnt_read_row >> 1) + 3) + ((cnt_read_col + 1) >> 1);
				sram_raddr_a3 = 6 * ((cnt_read_row >> 1) + 3) + (cnt_read_col >> 1);
			end
			default: begin
				sram_raddr_a0 = 0;
				sram_raddr_a1 = 0;
				sram_raddr_a2 = 0;
				sram_raddr_a3 = 0;
			end
		endcase
	end

	wdata_partial = mul_out;
	if(!conv3_en) begin
		mask_partial = 4'b0000;
	//	wdata_partial = mul_out;
	end
	else begin
		if(cnt_compute_row[0]) begin
			if(cnt_compute_col[0]) begin
				mask_partial = 4'b1110;
			//	wdata_partial = {36'b0, mul_out};	
			end
			else begin
				mask_partial = 4'b1101;
			//	wdata_partial = {24'b0, mul_out, 12'b0};
			end
		end
		else begin
			if(cnt_compute_col[0]) begin
				mask_partial = 4'b1011;
			//	wdata_partial = {12'b0, mul_out, 24'b0};
			end
			else begin
				mask_partial = 4'b0111;
			//	wdata_partial = {mul_out, 36'b0};
			end
		end
	end

	if(conv1_en) begin
		case(state)	
			LOAD: begin //MOD
				sram_raddr_weight = cnt; //MOD
				sram_raddr_bias = 0;   // MOD
			end
			LOAD2: begin //MOD
				sram_raddr_weight = cnt + 4 * cnt_ofmap + 2; //MOD
				sram_raddr_bias = cnt_ofmap;   // MOD
				if(cnt == 0) begin
					case(cnt_ofmap_minus1[1:0])
					0: begin
						sram_wordmask_b = {mask_partial, 12'hfff};
						sram_wdata_b = {wdata_partial, 144'b0};
					end
					1: begin 
						sram_wordmask_b = {4'hf, mask_partial, 8'hff};
						sram_wdata_b = {48'b0, wdata_partial, 96'b0};
					end
					2: begin 
						sram_wordmask_b = {8'hff, mask_partial, 4'hf};
						sram_wdata_b = {96'b0, wdata_partial, 48'b0};
					end	
					3: begin 
						sram_wordmask_b = {12'hfff, mask_partial};
						sram_wdata_b = {144'b0, wdata_partial};
					end
					default: begin 
						sram_wordmask_b = 16'hffff;
						sram_wdata_b = 0;
					end
					endcase
				end
			end
			COMPUTE: begin
				if(cnt == 35) sram_raddr_weight = 4 * cnt_ofmap + 1 + 4;//MOD
				else if(cnt == 34) sram_raddr_weight = 4 * cnt_ofmap + 4;//MOD
				sram_waddr_b = 6 * cnt_compute_row[2:1] + cnt_compute_col[2:1];
				if(cnt_compute_row[0]) begin
					if(cnt_compute_col[0]) begin
						sram_wen_b0 = 1;
						sram_wen_b1 = 1;
						sram_wen_b2 = 1;
						sram_wen_b3 = 0;
					end
					else begin
						sram_wen_b0 = 1;
						sram_wen_b1 = 1;
						sram_wen_b2 = 0;
						sram_wen_b3 = 1;
					end
				end
				else begin
					if(cnt_compute_col[0]) begin
						sram_wen_b0 = 1;
						sram_wen_b1 = 0;
						sram_wen_b2 = 1;
						sram_wen_b3 = 1;
					end
					else begin
						sram_wen_b0 = 0;
						sram_wen_b1 = 1;
						sram_wen_b2 = 1;
						sram_wen_b3 = 1;
					end
				end	
				case(cnt_ofmap[1:0])
					0: begin
						sram_wordmask_b = {mask_partial, 12'hfff};
						sram_wdata_b = {wdata_partial, 144'b0};
					end
					1: begin 
						sram_wordmask_b = {4'hf, mask_partial, 8'hff};
						sram_wdata_b = {48'b0, wdata_partial, 96'b0};
					end
					2: begin 
						sram_wordmask_b = {8'hff, mask_partial, 4'hf};
						sram_wdata_b = {96'b0, wdata_partial, 48'b0};
					end	
					3: begin 
						sram_wordmask_b = {12'hfff, mask_partial};
						sram_wdata_b = {144'b0, wdata_partial};
					end
					default: begin 
						sram_wordmask_b = 16'hffff;
						sram_wdata_b = 0;
					end
				endcase
			end
			WAIT: begin
				sram_wordmask_b = {12'hfff, mask_partial};
				sram_wdata_b = {144'b0, wdata_partial};
			end
			default: begin
				sram_wen_a0 = 1;
				sram_wen_a1 = 1;
				sram_wen_a2 = 1;
				sram_wen_a3 = 1;
				sram_wordmask_a = 16'hffff;
				sram_waddr_a = 0;
				sram_wen_b0 = 1;
				sram_wen_b1 = 1;
				sram_wen_b2 = 1;
				sram_wen_b3 = 1;
				sram_wordmask_b = 16'hffff;
				sram_waddr_b = 0;
				sram_raddr_weight = 0;       
				sram_raddr_bias = 0;
				sram_wdata_a = 0;
				sram_wdata_b = 0;
			end
		endcase
	end
	else if(conv2_en) begin
		case(state)	
			LOAD: begin //MOD
				sram_raddr_weight = cnt + 16; //MOD
				sram_raddr_bias = 4;   // MOD
			end
			LOAD2: begin //MOD
				sram_raddr_weight = cnt + 4 * cnt_ofmap + 16 + 2;
				sram_raddr_bias = cnt_ofmap + 4; 
				if(cnt == 0) begin
					case(cnt_ofmap_minus1[1:0])
						0: begin
							sram_wordmask_a = {mask_partial, 12'hfff};
							sram_wdata_a = {wdata_partial, 144'b0};
						end
						1: begin 
							sram_wordmask_a = {4'hf, mask_partial, 8'hff};
							sram_wdata_a = {48'b0, wdata_partial, 96'b0};
						end
						2: begin 
							sram_wordmask_a = {8'hff, mask_partial, 4'hf};
							sram_wdata_a = {96'b0, wdata_partial, 48'b0};
						end	
						3: begin 
							sram_wordmask_a = {12'hfff, mask_partial};
							sram_wdata_a = {144'b0, wdata_partial};
						end
						default: begin 
							sram_wordmask_a = 16'hffff;
							sram_wdata_a = 0;
						end
					endcase
				end  
			end
			COMPUTE: begin
				if(cnt == 24) sram_raddr_weight = 4 * cnt_ofmap + 1 + 16 + 4;//MOD
				if(cnt == 23) sram_raddr_weight = 4 * cnt_ofmap + 16 + 4;//MOD
				//if(cnt_ofmap < 4) sram_waddr_a = 6 * (cnt_compute_row >> 1) + (cnt_compute_col >> 1);
				if(cnt_ofmap < 4) sram_waddr_a = 6 * cnt_compute_row[2:1] + cnt_compute_col[2:1];
				else if(cnt_ofmap < 8) sram_waddr_a = 6 * cnt_compute_row[2:1] + cnt_compute_col[2:1] + 3;
				else sram_waddr_a = 6 * (cnt_compute_row[2:1] + 3)+ cnt_compute_col[2:1];
				if(cnt_compute_row[0]) begin
					if(cnt_compute_col[0]) begin
						sram_wen_a0 = 1;
						sram_wen_a1 = 1;
						sram_wen_a2 = 1;
						sram_wen_a3 = 0;
					end
					else begin
						sram_wen_a0 = 1;
						sram_wen_a1 = 1;
						sram_wen_a2 = 0;
						sram_wen_a3 = 1;
					end
				end
				else begin
					if(cnt_compute_col[0]) begin
						sram_wen_a0 = 1;
						sram_wen_a1 = 0;
						sram_wen_a2 = 1;
						sram_wen_a3 = 1;
					end
					else begin
						sram_wen_a0 = 0;
						sram_wen_a1 = 1;
						sram_wen_a2 = 1;
						sram_wen_a3 = 1;
					end
				end	
				case(cnt_ofmap[1:0])
					0: begin
						sram_wordmask_a = {mask_partial, 12'hfff};
						sram_wdata_a = {wdata_partial, 144'b0};
					end
					1: begin 
						sram_wordmask_a = {4'hf, mask_partial, 8'hff};
						sram_wdata_a = {48'b0, wdata_partial, 96'b0};
					end
					2: begin 
						sram_wordmask_a = {8'hff, mask_partial, 4'hf};
						sram_wdata_a = {96'b0, wdata_partial, 48'b0};
					end	
					3: begin 
						sram_wordmask_a = {12'hfff, mask_partial};
						sram_wdata_a = {144'b0, wdata_partial};
					end
					default: begin 
						sram_wordmask_a = 16'hffff;
						sram_wdata_a = 0;
					end
				endcase
			end
			WAIT: begin
				sram_wordmask_a = {12'hfff, mask_partial};
				sram_wdata_a = {144'b0, wdata_partial};
			end
			default: begin
				sram_wen_a0 = 1;
				sram_wen_a1 = 1;
				sram_wen_a2 = 1;
				sram_wen_a3 = 1;
				sram_wordmask_a = 16'hffff;
				sram_waddr_a = 0;
				sram_wen_b0 = 1;
				sram_wen_b1 = 1;
				sram_wen_b2 = 1;
				sram_wen_b3 = 1;
				sram_wordmask_b = 16'hffff;
				sram_waddr_b = 0;
				sram_raddr_weight = 0;       
				sram_raddr_bias = 0;
				sram_wdata_a = 0;
				sram_wdata_b = 0;
			end
		endcase
	end
	else if(conv3_en) begin
		case(state)	
			LOAD: begin //MOD
				sram_raddr_weight = cnt + 64; //MOD
				sram_raddr_bias = 16;   // MOD
			end
			LOAD2: begin //MOD
				sram_raddr_weight = 64 + 12 * cnt_ofmap + cnt + 2;
				sram_raddr_bias = 16 + cnt_ofmap;   
				if(cnt == 0) begin
					case(cnt_ofmap_minus1[1:0])
						0: begin
							sram_wordmask_b = {mask_partial, 12'hfff};
							sram_wdata_b = {wdata_partial, 144'b0};
						end
						1: begin 
							sram_wordmask_b = {4'hf, mask_partial, 8'hff};
							sram_wdata_b = {48'b0, wdata_partial, 96'b0};
						end
						2: begin 
							sram_wordmask_b = {8'hff, mask_partial, 4'hf};
							sram_wdata_b = {96'b0, wdata_partial, 48'b0};
						end	
						3: begin 
							sram_wordmask_b = {12'hfff, mask_partial};
							sram_wdata_b = {144'b0, wdata_partial};
						end
						default: begin 
							sram_wordmask_b = 16'hffff;
							sram_wdata_b = 0;
						end
					endcase
				end
			end
			COMPUTE: begin
				if(cnt == 47) sram_raddr_weight = 12 * cnt_ofmap + 1 + 64 + 12;//MOD
				else if(cnt == 46) sram_raddr_weight = 12 * cnt_ofmap + 64 + 12;//MOD
				sram_waddr_b = cnt_ofmap[5:2];
				if(cnt_compute_row[1]) begin
					if(cnt_compute_col[1]) begin
						sram_wen_b0 = 1;
						sram_wen_b1 = 1;
						sram_wen_b2 = 1;
						sram_wen_b3 = 0;
					end
					else begin
						sram_wen_b0 = 1;
						sram_wen_b1 = 1;
						sram_wen_b2 = 0;
						sram_wen_b3 = 1;
					end
				end
				else begin
					if(cnt_compute_col[1]) begin
						sram_wen_b0 = 1;
						sram_wen_b1 = 0;
						sram_wen_b2 = 1;
						sram_wen_b3 = 1;
					end
					else begin
						sram_wen_b0 = 0;
						sram_wen_b1 = 1;
						sram_wen_b2 = 1;
						sram_wen_b3 = 1;
					end
				end	
				case(cnt_ofmap[1:0])
					0: begin
						sram_wordmask_b = {mask_partial, 12'hfff};
						sram_wdata_b = {wdata_partial, 144'b0};
					end
					1: begin 
						sram_wordmask_b = {4'hf, mask_partial, 8'hff};
						sram_wdata_b = {48'b0, wdata_partial, 96'b0};
					end
					2: begin 
						sram_wordmask_b = {8'hff, mask_partial, 4'hf};
						sram_wdata_b = {96'b0, wdata_partial, 48'b0};
					end	
					3: begin 
						sram_wordmask_b = {12'hfff, mask_partial};
						sram_wdata_b = {144'b0, wdata_partial};
					end
					default: begin 
						sram_wordmask_b = 16'hffff;
						sram_wdata_b = 0;
					end
				endcase
			end
			WAIT: begin
				sram_wordmask_b = {12'hfff, mask_partial};
				sram_wdata_b = {144'b0, wdata_partial};
			end
			default: begin
				sram_wen_b0 = 1;
				sram_wen_b1 = 1;
				sram_wen_b2 = 1;
				sram_wen_b3 = 1;
				sram_wordmask_b = 16'hffff;
				sram_waddr_b = 0;
				sram_raddr_weight = 0;       
				sram_raddr_bias = 0;
				sram_wdata_b = 0;
			end
		endcase
	end
end

always@* begin
	map0 = sram_rdata_a0;
	map1 = sram_rdata_a1;
	map2 = sram_rdata_a2;
	map3 = sram_rdata_a3;
	if(conv1_en) begin
		if(cnt_compute_row[0]) begin
			if(cnt_compute_col[0]) begin
				map0 = sram_rdata_a3;
				map1 = sram_rdata_a2;
				map2 = sram_rdata_a1;
				map3 = sram_rdata_a0;
			end
			else begin
				map0 = sram_rdata_a2;
				map1 = sram_rdata_a3;
				map2 = sram_rdata_a0;
				map3 = sram_rdata_a1;
			end
		end
		else begin
			if(cnt_compute_col[0]) begin
				map0 = sram_rdata_a1;
				map1 = sram_rdata_a0;
				map2 = sram_rdata_a3;
				map3 = sram_rdata_a2;
			end
			else begin
				map0 = sram_rdata_a0;
				map1 = sram_rdata_a1;
				map2 = sram_rdata_a2;
				map3 = sram_rdata_a3;
			end
		end	
	end
	else if(conv2_en) begin
		if(cnt_compute_row[0]) begin
			if(cnt_compute_col[0]) begin
				map0 = sram_rdata_b3;
				map1 = sram_rdata_b2;
				map2 = sram_rdata_b1;
				map3 = sram_rdata_b0;
			end
			else begin
				map0 = sram_rdata_b2;
				map1 = sram_rdata_b3;
				map2 = sram_rdata_b0;
				map3 = sram_rdata_b1;
			end
		end
		else begin
			if(cnt_compute_col[0]) begin
				map0 = sram_rdata_b1;
				map1 = sram_rdata_b0;
				map2 = sram_rdata_b3;
				map3 = sram_rdata_b2;
			end
			else begin
				map0 = sram_rdata_b0;
				map1 = sram_rdata_b1;
				map2 = sram_rdata_b2;
				map3 = sram_rdata_b3;
			end
		end	
	end
	else if(conv3_en) begin
		if(cnt_compute_row[0]) begin
			if(cnt_compute_col[0]) begin
				map0 = sram_rdata_a3;
				map1 = sram_rdata_a2;
				map2 = sram_rdata_a1;
				map3 = sram_rdata_a0;
			end
			else begin
				map0 = sram_rdata_a2;
				map1 = sram_rdata_a3;
				map2 = sram_rdata_a0;
				map3 = sram_rdata_a1;
			end
		end
		else begin
			if(cnt_compute_col[0]) begin
				map0 = sram_rdata_a1;
				map1 = sram_rdata_a0;
				map2 = sram_rdata_a3;
				map3 = sram_rdata_a2;
			end
			else begin
				map0 = sram_rdata_a0;
				map1 = sram_rdata_a1;
				map2 = sram_rdata_a2;
				map3 = sram_rdata_a3;
			end
		end	
	end
end

always@* begin
	if(conv3_en) begin
		case(cnt_compute_ch)
			0: begin
				weight0 = weight_nx[0];
				weight1 = weight_nx[1];
				weight2 = weight_nx[2];
				weight3 = weight_nx[3];
			end
			1: begin
				weight0 = weight_nx[4];
				weight1 = weight_nx[5];
				weight2 = weight_nx[6];
				weight3 = weight_nx[7];
			end
			2: begin
				weight0 = weight_nx[8];
				weight1 = weight_nx[9];
				weight2 = weight_nx[10];
				weight3 = weight_nx[11];
			end
			default: begin
				weight0 = weight_nx[0];
				weight1 = weight_nx[1];
				weight2 = weight_nx[2];
				weight3 = weight_nx[3];
			end
		endcase
	end
	else begin
		weight0 = weight_nx[0];
		weight1 = weight_nx[1];
		weight2 = weight_nx[2];
		weight3 = weight_nx[3];
	end
end

endmodule
