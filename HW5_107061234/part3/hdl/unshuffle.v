module unshuffle#(
parameter CH_NUM = 4,
parameter ACT_PER_ADDR = 4,
parameter BW_PER_ACT = 12
)
(
input clk,
input rst_n,
input unshuffle_en,
input [BW_PER_ACT-1:0] input_data,
output reg busy,  // control signal for stopping loading input image
output reg valid,
// write enable for SRAM group A 
output reg sram_wen_a0,
output reg sram_wen_a1,
output reg sram_wen_a2,
output reg sram_wen_a3,
// wordmask for SRAM group A 
output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a,
// write addrress to SRAM group A 
output reg [5:0] sram_waddr_a,
// write data to SRAM group A 
output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a
);

reg start, start_nx;
reg [4:0] cnt_row, cnt_col, cnt_row_nx, cnt_col_nx;
reg [3:0] mask_int;
reg valid_nx;
//reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a;
/*
always@(posedge clk) begin
	sram_wdata_a2 <= sram_wdata_a;
end
*/
always@(posedge clk) begin
	if(~rst_n) begin
		cnt_row <= 0;
		cnt_col <= 0;
		start <= 0;
		valid <= 0;
	end
	else begin
		cnt_row <= cnt_row_nx;
		cnt_col <= cnt_col_nx;
		start <= start_nx;
		valid <= valid_nx;
	end
end

always@* begin
	if(unshuffle_en && !start) start_nx = 1;
	else if(!unshuffle_en) start_nx = 0;
	else start_nx = start;
end

always@* begin
	busy = 1;
	if(start_nx) begin
		busy = 0;
	end
end

always@* begin
	cnt_row_nx = cnt_row;
	cnt_col_nx = cnt_col;
	valid_nx = 0;
	if(start) begin
		cnt_col_nx = cnt_col + 1;
		if(cnt_col == 27) begin
			cnt_row_nx = cnt_row + 1;
			cnt_col_nx = 0;
			if(cnt_row == 27) valid_nx = 1;
		end
	end
end

always@* begin
	sram_wen_a0 = 1;
	sram_wen_a1 = 1;
	sram_wen_a2 = 1;
	sram_wen_a3 = 1;
//	sram_wordmask_a = 16'hffff; 
	sram_wdata_a = 0;
	mask_int = 15 - 4 * cnt_col[0] - cnt_col[1] - 8 * cnt_row[0] - 2 * cnt_row[1];
	sram_waddr_a = cnt_row[4:3] * 6 + cnt_col[4:3];

	if(cnt_row[2]) begin
		if(cnt_col[2]) begin
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
		if(cnt_col[2]) begin
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
	//	sram_wordmask_a = 16'hffff ^ {(15 - mask_int)*{1'b0}, 1'b1, (mask_int)*{1'b0}};
	sram_wdata_a[(mask_int+1)*BW_PER_ACT-1-:BW_PER_ACT] = input_data;
end

always@* begin
//	sram_wdata_a = 0;
	sram_wordmask_a = 16'hffff;
	case(mask_int)
 		 0:  begin
			sram_wordmask_a = 16'hfffe;
//			sram_wdata_a[BW_PER_ACT*1-1-:BW_PER_ACT] = input_data;
		end 
		 1: begin
			sram_wordmask_a = 16'hfffd; 
//			sram_wdata_a[BW_PER_ACT*2-1-:BW_PER_ACT] = input_data;
		end
		 2: begin
			sram_wordmask_a = 16'hfffb;
//			sram_wdata_a[BW_PER_ACT*3-1-:BW_PER_ACT] = input_data;
		end 
		 3: begin
			sram_wordmask_a = 16'hfff7; 
//			sram_wdata_a[BW_PER_ACT*4-1-:BW_PER_ACT] = input_data;
		end
		 4: begin 
			sram_wordmask_a = 16'hffef;
//			sram_wdata_a[BW_PER_ACT*5-1-:BW_PER_ACT] = input_data;
 		end
		 5: begin 
			sram_wordmask_a = 16'hffdf;
//			sram_wdata_a[BW_PER_ACT*6-1-:BW_PER_ACT] = input_data;
 		end
		 6: begin 
			sram_wordmask_a = 16'hffbf;
//			sram_wdata_a[BW_PER_ACT*7-1-:BW_PER_ACT] = input_data;
 		end
		 7: begin 
			sram_wordmask_a = 16'hff7f;
//			sram_wdata_a[BW_PER_ACT*8-1-:BW_PER_ACT] = input_data;
 		end
		 8: begin 
			sram_wordmask_a = 16'hfeff;
//			sram_wdata_a[BW_PER_ACT*9-1-:BW_PER_ACT] = input_data;
 		end
		 9: begin 
			sram_wordmask_a = 16'hfdff;
//			sram_wdata_a[BW_PER_ACT*10-1-:BW_PER_ACT] = input_data;
 		end
		10: begin 
			sram_wordmask_a = 16'hfbff;
//			sram_wdata_a[BW_PER_ACT*11-1-:BW_PER_ACT] = input_data;
 		end
		11: begin 
			sram_wordmask_a = 16'hf7ff;
//			sram_wdata_a[BW_PER_ACT*12-1-:BW_PER_ACT] = input_data;
 		end
		12: begin 
			sram_wordmask_a = 16'hefff;
//			sram_wdata_a[BW_PER_ACT*13-1-:BW_PER_ACT] = input_data;
 		end
		13: begin 
			sram_wordmask_a = 16'hdfff;
//			sram_wdata_a[BW_PER_ACT*14-1-:BW_PER_ACT] = input_data;
 		end
		14: begin 
			sram_wordmask_a = 16'hbfff;
//			sram_wdata_a[BW_PER_ACT*15-1-:BW_PER_ACT] = input_data;
 		end
		15: begin 
			sram_wordmask_a = 16'h7fff;
//			sram_wdata_a[BW_PER_ACT*16-1-:BW_PER_ACT] = input_data;
 		end
		default: begin 
			sram_wordmask_a = 16'hffff; 
//			sram_wdata_a = 0;
		end
	endcase
end

endmodule
