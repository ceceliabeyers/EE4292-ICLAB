module Convnet_top #(
parameter CH_NUM = 4,
parameter ACT_PER_ADDR = 4,
parameter BW_PER_ACT = 12
)
(
input clk,                          
input rst_n,  // synchronous reset (active low)
input enable, // start sending image from testbanch
output reg busy,  // control signal for stopping loading input image
output reg valid, // output valid for testbench to check answers in corresponding SRAM groups
input [BW_PER_ACT-1:0] input_data, // input image data
// read data from SRAM group A
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a3,
// read address from SRAM group A
output reg [5:0] sram_raddr_a0,
output reg [5:0] sram_raddr_a1,
output reg [5:0] sram_raddr_a2,
output reg [5:0] sram_raddr_a3,       
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

reg busy_nx;
reg valid_nx;
reg [5:0] sram_raddr_a0_nx;
reg [5:0] sram_raddr_a1_nx;
reg [5:0] sram_raddr_a2_nx;
reg [5:0] sram_raddr_a3_nx;
reg sram_wen_a0_nx;
reg sram_wen_a1_nx;
reg sram_wen_a2_nx;
reg sram_wen_a3_nx;
reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a_nx;
reg [5:0] sram_waddr_a_nx;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a_nx;

wire unshuffle_en;
wire sram_wen_a0_un;
wire sram_wen_a1_un;
wire sram_wen_a2_un;
wire sram_wen_a3_un;
wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a_un;
wire [5:0] sram_waddr_a_un;
wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a_un;
wire valid_ctrl;
wire valid_un;

reg unshuffle_en_d1;

control control(
//I
.clk(clk),
.rst_n(rst_n),
.enable(enable),
//.busy(busy_nx),  //?
.valid_un(valid_un),
//O
.unshuffle_en(unshuffle_en),
.valid(valid_ctrl)
);

unshuffle #(
.CH_NUM(CH_NUM),
.ACT_PER_ADDR(ACT_PER_ADDR),
.BW_PER_ACT(BW_PER_ACT)
) unshuffle
(
//I
.clk(clk),
.rst_n(rst_n),
.unshuffle_en(unshuffle_en),
.input_data(input_data),
//O
.busy(busy_un),
.sram_wen_a0(sram_wen_a0_un),
.sram_wen_a1(sram_wen_a1_un),
.sram_wen_a2(sram_wen_a2_un),
.sram_wen_a3(sram_wen_a3_un), 
.sram_wordmask_a(sram_wordmask_a_un),
.sram_waddr_a(sram_waddr_a_un),
.sram_wdata_a(sram_wdata_a_un),
.valid(valid_un)
);

always@(posedge clk) begin
	if(~rst_n) begin
		busy <= 1;
		valid <= 0;
		sram_wen_a0 <= 1;
		sram_wen_a1 <= 1;
		sram_wen_a2 <= 1;
		sram_wen_a3 <= 1;
		unshuffle_en_d1 <= 0;
	end
	else begin
		busy <= busy_nx;
		valid <= valid_nx;
		sram_wen_a0 <= sram_wen_a0_nx;
		sram_wen_a1 <= sram_wen_a1_nx;
		sram_wen_a2 <= sram_wen_a2_nx;
		sram_wen_a3 <= sram_wen_a3_nx;
		unshuffle_en_d1 <= unshuffle_en;
	end
end

always@(posedge clk) begin
	sram_raddr_a0 <= sram_raddr_a0_nx;
	sram_raddr_a1 <= sram_raddr_a1_nx;
	sram_raddr_a2 <= sram_raddr_a2_nx;
	sram_raddr_a3 <= sram_raddr_a3_nx;
	sram_wordmask_a <= sram_wordmask_a_nx;
	sram_waddr_a <= sram_waddr_a_nx;
	sram_wdata_a <= sram_wdata_a_nx;
end

always@* begin
	if(unshuffle_en_d1) begin
		sram_wen_a0_nx = sram_wen_a0_un;	
		sram_wen_a1_nx = sram_wen_a1_un;
		sram_wen_a2_nx = sram_wen_a2_un;
		sram_wen_a3_nx = sram_wen_a3_un; 
		sram_wordmask_a_nx = sram_wordmask_a_un;
		sram_waddr_a_nx = sram_waddr_a_un;
		sram_wdata_a_nx = sram_wdata_a_un;
		valid_nx = valid_ctrl;
		busy_nx = busy_un;
		sram_raddr_a0_nx = 0;
		sram_raddr_a1_nx = 0;
		sram_raddr_a2_nx = 0;
		sram_raddr_a3_nx = 0;
	end
	else begin
		sram_wen_a0_nx = 0;	
		sram_wen_a1_nx = 0;
		sram_wen_a2_nx = 0;
		sram_wen_a3_nx = 0; 
		sram_wordmask_a_nx = 0;
		sram_waddr_a_nx = 0;
		sram_wdata_a_nx = 0;
		valid_nx = valid_ctrl;
		busy_nx = busy_un;
		sram_raddr_a0_nx = 0;
		sram_raddr_a1_nx = 0;
		sram_raddr_a2_nx = 0;
		sram_raddr_a3_nx = 0;
	end
end

endmodule
