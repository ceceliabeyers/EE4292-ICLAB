module conv1_ctrl#(
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
// read data from SRAM group A
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a3,
// read data from SRAM group B
//input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b0,
//input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b1,
//input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b2,
//input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b3,
// read data from parameter SRAM
input [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_weight,  
input [BIAS_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_bias,   
// write enable for SRAM group A
output reg sram_wen_a0,
output reg sram_wen_a1,
output reg sram_wen_a2,
output reg sram_wen_a3,
// wordmask for SRAM group A 
output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a,
// write addrress to SRAM group A 
output reg [5:0] sram_waddr_a,

// write enable for SRAM group B
output reg sram_wen_b0,
output reg sram_wen_b1,
output reg sram_wen_b2,
output reg sram_wen_b3,
// wordmask for SRAM group B
output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b,
// write addrress to SRAM group B 
output reg [5:0] sram_waddr_b,

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

output reg valid
);

localparam IDLE = 2'd0, LOAD = 2'd1, COMPUTE = 2'd2;

reg [1:0] state, n_state;
reg [7:0] cnt, cnt_nx;
reg [2:0] cnt_read_col, cnt_read_col_nx;
reg [2:0] cnt_read_row, cnt_read_row_nx;
reg [2:0] cnt_compute_col, cnt_compute_col_nx;
reg [2:0] cnt_compute_row, cnt_compute_row_nx;
reg [1:0] cnt_compute, cnt_compute_nx;
reg [1:0] cnt_wait, cnt_wait_nx;
reg [1:0] cnt_ofmap, cnt_ofmap_nx;

reg [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] weight [0:3];
reg [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] weight_nx [0:3];
reg [BIAS_PER_ADDR*BW_PER_PARAM-1:0] bias;
reg [BIAS_PER_ADDR*BW_PER_PARAM-1:0] bias_nx;

reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] map0;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] map1;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] map2;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] map3;

reg [3:0] mask_partial;
reg [4*BW_PER_ACT-1:0] wdata_partial;

wire [BW_PER_ACT-1:0] mul_out;

mul #(
.CH_NUM(CH_NUM),
.ACT_PER_ADDR(ACT_PER_ADDR),
.BW_PER_ACT(BW_PER_ACT),
.WEIGHT_PER_ADDR(WEIGHT_PER_ADDR), 
.BIAS_PER_ADDR(BIAS_PER_ADDR),
.BW_PER_PARAM(BW_PER_PARAM)
) mul
(
.weight0(weight[0]),
.weight1(weight[1]),
.weight2(weight[2]),
.weight3(weight[3]),
.map0(map0),
.map1(map1),
.map2(map2),
.map3(map3),
.bias(bias),
.cnt(cnt_compute),
.out(mul_out)
);

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
	for(i = 0; i < 4; i = i + 1) begin
		weight[i] <= weight_nx[i];
	end
	bias <= bias_nx;
	cnt_read_col <= cnt_read_col_nx;
	cnt_read_row <= cnt_read_row_nx;
	cnt_compute_col <= cnt_compute_col_nx;
	cnt_compute_row <= cnt_compute_row_nx;
	cnt_compute <= cnt_compute_nx;
	cnt_wait <= cnt_wait_nx;
	cnt_ofmap <= cnt_ofmap_nx;
end

always@* begin
	case(state)
		IDLE: begin
			if(conv1_en) n_state = LOAD;
			else n_state = IDLE;
		end
		LOAD: begin
			if(cnt == 5) n_state = COMPUTE;
			else n_state = LOAD;
		end
		COMPUTE: begin
			if(cnt_compute_row == 5 && cnt_compute_col == 5 && cnt_compute == 3) begin
				if(cnt_ofmap == 3) n_state = IDLE;
				else n_state = LOAD;
			end
			else n_state = COMPUTE;
		end
		default: n_state = IDLE; 
	endcase
end

always@* begin
	cnt_nx = 0;
	valid = 0;
	cnt_read_col_nx = cnt_read_col;
	cnt_read_row_nx = cnt_read_row;
	cnt_compute_nx = cnt_compute;
	cnt_compute_row_nx = cnt_compute_row;
	cnt_compute_col_nx = cnt_compute_col;
	cnt_wait_nx = cnt_wait;
	cnt_ofmap_nx = cnt_ofmap;
	if(conv1_en) begin
	case(state)
		IDLE: begin
			cnt_nx = 0;
			cnt_read_col_nx = 0;
			cnt_read_row_nx = 0;
			cnt_compute_col_nx = 0;
			cnt_compute_row_nx = 0;
			cnt_compute_nx = 0;
			cnt_wait_nx = 0;
			cnt_ofmap_nx = 0;
			valid = 0;
		end
		LOAD: begin
			valid = 0;
			cnt_read_col_nx = 0;
			cnt_read_row_nx = 0;
			cnt_compute_col_nx = 0;
			cnt_compute_row_nx = 0;
			cnt_compute_nx = 0;
			cnt_wait_nx = 0;
			cnt_ofmap_nx = cnt_ofmap;
			if(cnt == 5) cnt_nx = 0;
			else cnt_nx = cnt + 1;
			if(cnt >= 4) cnt_wait_nx = cnt_wait + 1;
		end
		COMPUTE: begin
			if(cnt_compute_row == 5 && cnt_compute_col == 5 && cnt_compute == 3) begin
				cnt_nx = 0;
				cnt_read_col_nx = 0;
				cnt_read_row_nx = 0;	
				cnt_compute_nx = 0;
				cnt_compute_col_nx = 0;
				cnt_compute_row_nx = 0;
				cnt_wait_nx = 0;
				cnt_ofmap_nx = cnt_ofmap + 1;
				if(cnt_ofmap == 3) valid = 1;
				else valid = 0;
			end
			else begin
				cnt_nx = cnt + 1;
				valid = 0;
				cnt_compute_nx = cnt_compute + 1;
				cnt_wait_nx = cnt_wait + 1;
				cnt_ofmap_nx = cnt_ofmap;
				if(cnt_wait == 3) begin
					if(cnt_read_col == 5) begin
						cnt_read_row_nx = cnt_read_row + 1; 
						cnt_read_col_nx = 0;
					end
					else begin
						cnt_read_row_nx = cnt_read_row;
						cnt_read_col_nx = cnt_read_col + 1;
					end
				end
				else begin 
					cnt_read_col_nx = cnt_read_col;
					cnt_read_row_nx = cnt_read_row;
				end
				if(cnt_compute == 3) begin
					if(cnt_compute_col == 5) begin
						cnt_compute_row_nx = cnt_compute_row + 1;
						cnt_compute_col_nx = 0;
					end
					else begin
						cnt_compute_row_nx = cnt_compute_row;
						cnt_compute_col_nx = cnt_compute_col + 1;
					end
				end
				else begin 
					cnt_compute_col_nx = cnt_compute_col;
					cnt_compute_row_nx = cnt_compute_row;
				end
			end
		end
		default: begin
			cnt_read_col_nx = 0;
			cnt_read_row_nx = 0;
			cnt_compute_col_nx = 0;
			cnt_compute_row_nx = 0;
			cnt_compute_nx = 0;
			cnt_wait_nx = 0;
			cnt_ofmap_nx = 0;
			cnt_nx = cnt;
			valid = 0;
		end
	endcase
	end
end

always@* begin
	bias_nx = bias;
	for(i = 0; i < 4; i = i + 1) begin
		weight_nx[i] = weight[i];
	end

	case(state) 
		LOAD: begin
			if(cnt >= 2) begin
				weight_nx[cnt-2] = sram_rdata_weight;
				bias_nx = sram_rdata_bias;
			end
		end
		/*compute begin
		end*/
		default: begin
			bias_nx = bias;
			for(i = 0; i < 4; i = i + 1) begin
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

	case(cnt_compute) 
		0: begin
			mask_partial = 4'b0111;
			wdata_partial = {mul_out, 36'b0};
		end
		1: begin
			mask_partial = 4'b1011;
			wdata_partial = {12'b0, mul_out, 24'b0};
		end
		2: begin 
			mask_partial = 4'b1101;
			wdata_partial = {24'b0, mul_out, 12'b0};
		end
		3: begin
			mask_partial = 4'b1110;
			wdata_partial = {36'b0, mul_out};
		end
		default: begin
			mask_partial = 4'b1111;
			wdata_partial = 0;
		end
	endcase
	
	if(conv1_en) begin
	case(state)
		LOAD: begin
			sram_raddr_weight = cnt + 4 * cnt_ofmap;
			sram_raddr_bias = cnt_ofmap;   // modify
		end
		COMPUTE: begin
			sram_waddr_b = 6 * (cnt_compute_row >> 1) + (cnt_compute_col >> 1);
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
			sram_raddr_b0 = 0;
			sram_raddr_b1 = 0;
			sram_raddr_b2 = 0;
			sram_raddr_b3 = 0;
			sram_raddr_weight = 0;       
			sram_raddr_bias = 0;
			sram_wdata_a = 0;
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
end

endmodule
