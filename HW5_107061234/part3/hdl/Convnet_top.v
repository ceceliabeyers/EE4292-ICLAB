module Convnet_top #(
parameter CH_NUM = 4,
parameter ACT_PER_ADDR = 4,
parameter BW_PER_ACT = 12,
parameter WEIGHT_PER_ADDR = 9, 
parameter BIAS_PER_ADDR = 1,
parameter BW_PER_PARAM = 8
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
// read data from SRAM group B
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b3,
// read data from parameter SRAM
input [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_weight,  
input [BIAS_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_bias,     
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
// write enable for SRAM groups A & B
output reg sram_wen_a0,
output reg sram_wen_a1,
output reg sram_wen_a2,
output reg sram_wen_a3,
output reg sram_wen_b0,
output reg sram_wen_b1,
output reg sram_wen_b2,
output reg sram_wen_b3,
// word mask for SRAM groups A & B
output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a,
output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b,
// write addrress to SRAM groups A & B
output reg [5:0] sram_waddr_a,
output reg [5:0] sram_waddr_b,
// write data to SRAM groups A & B
output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a,
output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b
);

// NEXT output
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
//add
reg sram_wen_a0_nx2;
reg sram_wen_a1_nx2;
reg sram_wen_a2_nx2;
reg sram_wen_a3_nx2;
reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a_nx2;
//reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a_nx2;
reg sram_wen_b0_nx2;
reg sram_wen_b1_nx2;
reg sram_wen_b2_nx2;
reg sram_wen_b3_nx2;
reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b_nx2;
//reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b_nx2;
reg [5:0] sram_waddr_a_nx2;
reg [5:0] sram_waddr_b_nx2;
//
reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a_nx;
reg [5:0] sram_waddr_a_nx;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a_nx;
reg [9:0] sram_raddr_weight_nx;       
reg [5:0] sram_raddr_bias_nx;
reg [5:0] sram_raddr_b0_nx;
reg [5:0] sram_raddr_b1_nx;
reg [5:0] sram_raddr_b2_nx;
reg [5:0] sram_raddr_b3_nx;
reg sram_wen_b0_nx;
reg sram_wen_b1_nx;
reg sram_wen_b2_nx;
reg sram_wen_b3_nx;
reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b_nx;
reg [5:0] sram_waddr_b_nx;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b_nx;
// wire for ctrl signal
wire unshuffle_en;
wire conv1_en;
wire conv2_en;
wire conv3_en;
//wire conv_en;
wire valid_ctrl;
wire valid_un;
wire valid_conv1;
wire valid_conv2;
wire valid_conv3;
// wire for sram a b
wire sram_wen_a0_un, sram_wen_a0_conv, sram_wen_b0_conv;
wire sram_wen_a1_un, sram_wen_a1_conv, sram_wen_b1_conv;
wire sram_wen_a2_un, sram_wen_a2_conv, sram_wen_b2_conv;
wire sram_wen_a3_un, sram_wen_a3_conv, sram_wen_b3_conv;
wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a_un, sram_wordmask_a_conv, sram_wordmask_b_conv;
wire [5:0] sram_waddr_a_un, sram_waddr_a_conv, sram_waddr_b_conv;
wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a_un, sram_wdata_a_conv, sram_wdata_b_conv;
wire [5:0] sram_raddr_a0_conv, sram_raddr_a1_conv, sram_raddr_a2_conv, sram_raddr_a3_conv, sram_raddr_b0_conv, sram_raddr_b1_conv, sram_raddr_b2_conv,  sram_raddr_b3_conv;
// wire for param
wire [9:0] sram_raddr_weight_conv;       
wire [5:0] sram_raddr_bias_conv;

//NEXT ctrl signal
reg unshuffle_en_d1;
//reg conv_en_d1;

control control(
//I
.clk(clk),
.rst_n(rst_n),
.enable(enable),
.valid_un(valid_un),
.valid_conv1(valid_conv1),
.valid_conv2(valid_conv2),
.valid_conv3(valid_conv3),
//O
.unshuffle_en(unshuffle_en),
.conv1_en(conv1_en),
.conv2_en(conv2_en),
.conv3_en(conv3_en),
//.conv_en(conv_en),
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
.valid(valid_un),
.sram_wen_a0(sram_wen_a0_un),
.sram_wen_a1(sram_wen_a1_un),
.sram_wen_a2(sram_wen_a2_un),
.sram_wen_a3(sram_wen_a3_un), 
.sram_wordmask_a(sram_wordmask_a_un),
.sram_waddr_a(sram_waddr_a_un),
.sram_wdata_a(sram_wdata_a_un)
);

conv_ctrl #(
.CH_NUM(CH_NUM),
.ACT_PER_ADDR(ACT_PER_ADDR),
.BW_PER_ACT(BW_PER_ACT),
.WEIGHT_PER_ADDR(WEIGHT_PER_ADDR), 
.BIAS_PER_ADDR(BIAS_PER_ADDR),
.BW_PER_PARAM(BW_PER_PARAM)
) conv_ctrl
(
//I
.clk(clk),
.rst_n(rst_n),
.conv1_en(conv1_en),
.conv2_en(conv2_en),
.conv3_en(conv3_en),
.sram_rdata_a0(sram_rdata_a0),
.sram_rdata_a1(sram_rdata_a1),
.sram_rdata_a2(sram_rdata_a2),
.sram_rdata_a3(sram_rdata_a3),
.sram_rdata_b0(sram_rdata_b0),
.sram_rdata_b1(sram_rdata_b1),
.sram_rdata_b2(sram_rdata_b2),
.sram_rdata_b3(sram_rdata_b3),
.sram_rdata_weight(sram_rdata_weight),  
.sram_rdata_bias(sram_rdata_bias),  
//O
.sram_wen_a0_d1(sram_wen_a0_conv),
.sram_wen_a1_d1(sram_wen_a1_conv),
.sram_wen_a2_d1(sram_wen_a2_conv),
.sram_wen_a3_d1(sram_wen_a3_conv), 
.sram_wordmask_a_d1(sram_wordmask_a_conv),
.sram_waddr_a_d1(sram_waddr_a_conv),
.sram_wen_b0_d1(sram_wen_b0_conv),
.sram_wen_b1_d1(sram_wen_b1_conv),
.sram_wen_b2_d1(sram_wen_b2_conv),
.sram_wen_b3_d1(sram_wen_b3_conv), 
.sram_wordmask_b_d1(sram_wordmask_b_conv),
.sram_waddr_b_d1(sram_waddr_b_conv),
.sram_raddr_a0(sram_raddr_a0_conv),
.sram_raddr_a1(sram_raddr_a1_conv),
.sram_raddr_a2(sram_raddr_a2_conv),
.sram_raddr_a3(sram_raddr_a3_conv),
.sram_raddr_b0(sram_raddr_b0_conv),
.sram_raddr_b1(sram_raddr_b1_conv),
.sram_raddr_b2(sram_raddr_b2_conv),
.sram_raddr_b3(sram_raddr_b3_conv),
.sram_raddr_weight(sram_raddr_weight_conv),
.sram_raddr_bias(sram_raddr_bias_conv),
.sram_wdata_a(sram_wdata_a_conv),
.sram_wdata_b(sram_wdata_b_conv),
.valid1(valid_conv1),
.valid2(valid_conv2),
.valid3(valid_conv3)
);

always@(posedge clk) begin
	/*if(~rst_n) begin
		busy <= 1;
		valid <= 0;
		sram_wen_a0 <= 1;
		sram_wen_a1 <= 1;
		sram_wen_a2 <= 1;
		sram_wen_a3 <= 1;
		sram_wen_b0 <= 1;
		sram_wen_b1 <= 1;
		sram_wen_b2 <= 1;
		sram_wen_b3 <= 1;
		unshuffle_en_d1 <= 0;
	end
	else begin*/
		busy <= busy_nx;
		valid <= valid_nx;
		sram_wen_a0 <= sram_wen_a0_nx;
		sram_wen_a1 <= sram_wen_a1_nx;
		sram_wen_a2 <= sram_wen_a2_nx;
		sram_wen_a3 <= sram_wen_a3_nx;
		sram_wen_b0 <= sram_wen_b0_nx;
		sram_wen_b1 <= sram_wen_b1_nx;
		sram_wen_b2 <= sram_wen_b2_nx;
		sram_wen_b3 <= sram_wen_b3_nx;
	/*	sram_wen_a0_nx2 <= sram_wen_a0_nx;
		sram_wen_a1_nx2 <= sram_wen_a1_nx;
		sram_wen_a2_nx2 <= sram_wen_a2_nx;
		sram_wen_a3_nx2 <= sram_wen_a3_nx;
		sram_wen_b0_nx2 <= sram_wen_b0_nx;
		sram_wen_b1_nx2 <= sram_wen_b1_nx;
		sram_wen_b2_nx2 <= sram_wen_b2_nx;
		sram_wen_b3_nx2 <= sram_wen_b3_nx;*/
		unshuffle_en_d1 <= unshuffle_en;
		//conv_en_d1 <= conv_en;
//	end
end

always@(posedge clk) begin
	sram_raddr_a0 <= sram_raddr_a0_nx;
	sram_raddr_a1 <= sram_raddr_a1_nx;
	sram_raddr_a2 <= sram_raddr_a2_nx;
	sram_raddr_a3 <= sram_raddr_a3_nx;
	sram_wordmask_a <= sram_wordmask_a_nx;
	sram_waddr_a <= sram_waddr_a_nx;
	sram_wdata_a <= sram_wdata_a_nx;
	sram_raddr_b0 <= sram_raddr_b0_nx;
	sram_raddr_b1 <= sram_raddr_b1_nx;
	sram_raddr_b2 <= sram_raddr_b2_nx;
	sram_raddr_b3 <= sram_raddr_b3_nx;
	sram_wordmask_b <= sram_wordmask_b_nx;
	sram_waddr_b <= sram_waddr_b_nx;
	sram_wdata_b <= sram_wdata_b_nx;
	sram_raddr_weight <= sram_raddr_weight_nx;
	sram_raddr_bias <= sram_raddr_bias_nx;
/*
	//add
	sram_wordmask_a_nx2 <= sram_wordmask_a_nx;
	sram_waddr_a_nx2 <= sram_waddr_a_nx;
	//sram_wdata_a_nx2 <= sram_wdata_a_nx;
	sram_wordmask_b_nx2 <= sram_wordmask_b_nx;
	sram_waddr_b_nx2 <= sram_waddr_b_nx;
	//sram_wdata_b_nx2 <= sram_wdata_b_nx;*/
end

always@* begin
	sram_wen_a0_nx = 0;	
	sram_wen_a1_nx = 0;
	sram_wen_a2_nx = 0;
	sram_wen_a3_nx = 0; 
	sram_wordmask_a_nx = 16'hffff;
	sram_waddr_a_nx = 0;
	sram_wdata_a_nx = 0;
	sram_wen_b0_nx = 0;	
	sram_wen_b1_nx = 0;
	sram_wen_b2_nx = 0;
	sram_wen_b3_nx = 0; 
	sram_wordmask_b_nx = 16'hffff;
	sram_waddr_b_nx = 0;
	sram_wdata_b_nx = 0;
	sram_raddr_weight_nx = 0;
	sram_raddr_bias_nx = 0;
	valid_nx = valid_ctrl;
	busy_nx = busy_un;
	sram_raddr_a0_nx = 0;
	sram_raddr_a1_nx = 0;
	sram_raddr_a2_nx = 0;
	sram_raddr_a3_nx = 0;
	sram_raddr_b0_nx = 0;
	sram_raddr_b1_nx = 0;
	sram_raddr_b2_nx = 0;
	sram_raddr_b3_nx = 0;
	if(unshuffle_en_d1) begin
		sram_wen_a0_nx = sram_wen_a0_un;	
		sram_wen_a1_nx = sram_wen_a1_un;
		sram_wen_a2_nx = sram_wen_a2_un;
		sram_wen_a3_nx = sram_wen_a3_un; 
		sram_wordmask_a_nx = sram_wordmask_a_un;
		sram_waddr_a_nx = sram_waddr_a_un;
		sram_wdata_a_nx = sram_wdata_a_un;
		sram_wen_b0_nx = 0;	
		sram_wen_b1_nx = 0;
		sram_wen_b2_nx = 0;
		sram_wen_b3_nx = 0; 
		sram_wordmask_b_nx = 16'hffff;
		sram_waddr_b_nx = 0;
		sram_wdata_b_nx = 0;
		sram_raddr_weight_nx = 0;
		sram_raddr_bias_nx = 0;
		valid_nx = valid_ctrl;
		busy_nx = busy_un;
		sram_raddr_a0_nx = 0;
		sram_raddr_a1_nx = 0;
		sram_raddr_a2_nx = 0;
		sram_raddr_a3_nx = 0;
		sram_raddr_b0_nx = 0;
		sram_raddr_b1_nx = 0;
		sram_raddr_b2_nx = 0;
		sram_raddr_b3_nx = 0;
	end
	else /*if(conv_en_d1)*/ begin
		sram_wen_a0_nx = sram_wen_a0_conv;	
		sram_wen_a1_nx = sram_wen_a1_conv;
		sram_wen_a2_nx = sram_wen_a2_conv;
		sram_wen_a3_nx = sram_wen_a3_conv; 
		sram_wordmask_a_nx = sram_wordmask_a_conv;
		sram_waddr_a_nx = sram_waddr_a_conv;
		sram_wdata_a_nx = sram_wdata_a_conv;
		sram_wen_b0_nx = sram_wen_b0_conv;	
		sram_wen_b1_nx = sram_wen_b1_conv;
		sram_wen_b2_nx = sram_wen_b2_conv;
		sram_wen_b3_nx = sram_wen_b3_conv; 
		sram_wordmask_b_nx = sram_wordmask_b_conv;
		sram_waddr_b_nx = sram_waddr_b_conv;
		sram_wdata_b_nx = sram_wdata_b_conv;
		sram_raddr_weight_nx = sram_raddr_weight_conv;
		sram_raddr_bias_nx = sram_raddr_bias_conv;
		valid_nx = valid_ctrl;
		busy_nx = busy_un;
		sram_raddr_a0_nx = sram_raddr_a0_conv;
		sram_raddr_a1_nx = sram_raddr_a1_conv;
		sram_raddr_a2_nx = sram_raddr_a2_conv;
		sram_raddr_a3_nx = sram_raddr_a3_conv;
		sram_raddr_b0_nx = sram_raddr_b0_conv;
		sram_raddr_b1_nx = sram_raddr_b1_conv;
		sram_raddr_b2_nx = sram_raddr_b2_conv;
		sram_raddr_b3_nx = sram_raddr_b3_conv;
	end
	/*else begin
		sram_wen_a0_nx = 0;	
		sram_wen_a1_nx = 0;
		sram_wen_a2_nx = 0;
		sram_wen_a3_nx = 0; 
		sram_wordmask_a_nx = 16'hffff;
		sram_waddr_a_nx = 0;
		sram_wdata_a_nx = 0;
		sram_wen_b0_nx = 0;	
		sram_wen_b1_nx = 0;
		sram_wen_b2_nx = 0;
		sram_wen_b3_nx = 0; 
		sram_wordmask_b_nx = 16'hffff;
		sram_waddr_b_nx = 0;
		sram_wdata_b_nx = 0;
		sram_raddr_weight_nx = 0;
		sram_raddr_bias_nx = 0;
		valid_nx = valid_ctrl;
		busy_nx = busy_un;
		sram_raddr_a0_nx = 0;
		sram_raddr_a1_nx = 0;
		sram_raddr_a2_nx = 0;
		sram_raddr_a3_nx = 0;
		sram_raddr_b0_nx = 0;
		sram_raddr_b1_nx = 0;
		sram_raddr_b2_nx = 0;
		sram_raddr_b3_nx = 0;
	end*/
end

endmodule
