module top
#(
parameter N=2500000,
parameter ACT_PER_ADDR = 1,
parameter IN_WIDTH     = 8,   // IN  = encode
parameter OUT_WIDTH    = 23,  // OUT = decode
parameter COEF_WIDTH   = 9,
parameter COEF_FP      = 8,
parameter IMG_SIZE     = 11,
parameter SRAM_ADDR_R  = 22,  // 8b, read RGB
parameter SRAM_ADDR_W  = 20,  // 23b, read code
parameter REG_WIDTH    = 12
)  
(
input clk,
input rst_n,
input enable,
input sample_mode,
input encode,
input [ACT_PER_ADDR*IN_WIDTH-1:0] R,  // input pixel R, unsigned
input [ACT_PER_ADDR*IN_WIDTH-1:0] G,  // input pixel G, unsigned
input [ACT_PER_ADDR*IN_WIDTH-1:0] B,  // input pixel B, unsigned
input [ACT_PER_ADDR*OUT_WIDTH-1:0] code, 
input [IMG_SIZE-1:0] img_width,
input [IMG_SIZE-1:0] img_height,

output wsb_Y,
output wsb_U,
output wsb_V,
output reg wsb_23b,
output [SRAM_ADDR_R-1:0] sram_raddr_8b,   // read RGB
output [SRAM_ADDR_W-1:0] sram_raddr_23b,
output reg [IN_WIDTH-1:0] wdata_8b,
output reg [OUT_WIDTH-1:0] wdata_23b,
output [SRAM_ADDR_R-1:0] waddr_8b, 
output reg [SRAM_ADDR_W-1:0] waddr_23b, 
output reg [4:0] bit_valid_out,
output reg finish
);

// sram Nx23b
reg [SRAM_ADDR_W-1:0] cnt_addr, cnt_addr_nx;
reg wsb_23b_nx;
reg [OUT_WIDTH-1:0] wdata_23b_nx;
reg [SRAM_ADDR_W-1:0] waddr_23b_nx;
reg in_enco;
wire [OUT_WIDTH-1:0] code_out;
wire [4:0] bit_valid;

always @(posedge clk ) begin
  if(~rst_n) begin
    wsb_23b <= 1;
    cnt_addr <= 0;
	bit_valid_out <= 0;
  end
  else begin
    wsb_23b <= (in_enco) ? wsb_23b_nx : 1;
    cnt_addr <= cnt_addr_nx;
	bit_valid_out <= bit_valid;
  end
  waddr_23b <= waddr_23b_nx;
  wdata_23b <= wdata_23b_nx;
end

always @(*) begin
  wdata_23b_nx = code_out <<< (23 - bit_valid);
  waddr_23b_nx = cnt_addr;
  if(bit_valid != 0) begin
    wsb_23b_nx = 0;
    cnt_addr_nx = cnt_addr + 1;
  end
  else begin
    wsb_23b_nx = 1;
    cnt_addr_nx = cnt_addr;
  end
end
// control_en
// state signal
wire CST_en;
wire DCT1_en;
wire DCT2_en;
wire ENCO_en;
// register 0 control signal
wire ctrl0_wen;
wire ctrl0_r_c;
wire ctrl0_wmode;
wire [2:0] ctrl0_raddr;
wire [2:0] ctrl0_waddr;
// register 1 control signal
wire reg1_wen;
wire reg1_r_c;
wire reg1_wmode;
wire [2:0] reg1_raddr;
wire [2:0] quan_waddr;
// YUV table control signal, 1: state = Y, 0: state != Y
wire [1:0] yuv_state1;
wire [1:0] yuv_state2;
// encoder control signal
wire [2:0] sel_in_addr;
wire pad_en;
wire dc_en;
wire clear;
wire dc_clear; // high when YUV mode is changed
wire ctrl_finish;

// control_de
wire [2:0] decode_state;
wire decode_en;
wire decode_wen;
wire decode_r_c;
wire decode_wmode;
wire [2:0] decode_raddr;
wire [2:0] decode_waddr;
wire decode_finish;
wire mode_out;
wire decode_clear;

// register 0
reg reg0_wen;
reg reg0_r_c;
reg reg0_wmode;
reg [8*(IN_WIDTH+2+2)-1:0] reg0_in;
reg [2:0] reg0_raddr;
reg [2:0] reg0_waddr;

wire ctrl_stop0;
wire [IN_WIDTH+2+2-1:0] reg0_out0;
wire [IN_WIDTH+2+2-1:0] reg0_out1;
wire [IN_WIDTH+2+2-1:0] reg0_out2;
wire [IN_WIDTH+2+2-1:0] reg0_out3;
wire [IN_WIDTH+2+2-1:0] reg0_out4;
wire [IN_WIDTH+2+2-1:0] reg0_out5;
wire [IN_WIDTH+2+2-1:0] reg0_out6;
wire [IN_WIDTH+2+2-1:0] reg0_out7;
wire [2:0] en0_in_addr;

// register 1
wire ctrl_stop1;
wire [8*(IN_WIDTH+2+2)-1:0] reg1_in;
wire [IN_WIDTH+2+2-1:0] reg1_out0;
wire [IN_WIDTH+2+2-1:0] reg1_out1;
wire [IN_WIDTH+2+2-1:0] reg1_out2;
wire [IN_WIDTH+2+2-1:0] reg1_out3;
wire [IN_WIDTH+2+2-1:0] reg1_out4;
wire [IN_WIDTH+2+2-1:0] reg1_out5;
wire [IN_WIDTH+2+2-1:0] reg1_out6;
wire [IN_WIDTH+2+2-1:0] reg1_out7;
wire [2:0] en1_in_addr;

// reg2yuv
wire [ACT_PER_ADDR*IN_WIDTH-1:0] rgb2yuv_o;

// DCT
reg  [IN_WIDTH+2-1:0] dct_1D_in0;
reg  [IN_WIDTH+2-1:0] dct_1D_in1;
reg  [IN_WIDTH+2-1:0] dct_1D_in2;
reg  [IN_WIDTH+2-1:0] dct_1D_in3;
reg  [IN_WIDTH+2-1:0] dct_1D_in4;
reg  [IN_WIDTH+2-1:0] dct_1D_in5;
reg  [IN_WIDTH+2-1:0] dct_1D_in6;
reg  [IN_WIDTH+2-1:0] dct_1D_in7;
wire [IN_WIDTH+2+2-1:0] dct_1D_out0;
wire [IN_WIDTH+2+2-1:0] dct_1D_out1;
wire [IN_WIDTH+2+2-1:0] dct_1D_out2;
wire [IN_WIDTH+2+2-1:0] dct_1D_out3;
wire [IN_WIDTH+2+2-1:0] dct_1D_out4;
wire [IN_WIDTH+2+2-1:0] dct_1D_out5;
wire [IN_WIDTH+2+2-1:0] dct_1D_out6;
wire [IN_WIDTH+2+2-1:0] dct_1D_out7;

// iDCT
reg  [REG_WIDTH-1:0] idct_1D0_in00;
reg  [REG_WIDTH-1:0] idct_1D0_in11;
reg  [REG_WIDTH-1:0] idct_1D0_in22;
reg  [REG_WIDTH-1:0] idct_1D0_in33;
reg  [REG_WIDTH-1:0] idct_1D0_in44;
reg  [REG_WIDTH-1:0] idct_1D0_in55;
reg  [REG_WIDTH-1:0] idct_1D0_in66;
reg  [REG_WIDTH-1:0] idct_1D0_in77;
wire [REG_WIDTH-1:0] idct_1D0_out0;
wire [REG_WIDTH-1:0] idct_1D0_out1;
wire [REG_WIDTH-1:0] idct_1D0_out2;
wire [REG_WIDTH-1:0] idct_1D0_out3;
wire [REG_WIDTH-1:0] idct_1D0_out4;
wire [REG_WIDTH-1:0] idct_1D0_out5;
wire [REG_WIDTH-1:0] idct_1D0_out6;
wire [REG_WIDTH-1:0] idct_1D0_out7;

reg  [REG_WIDTH-1:0] idct_1D0_in0;
reg  [REG_WIDTH-1:0] idct_1D0_in1;
reg  [REG_WIDTH-1:0] idct_1D0_in2;
reg  [REG_WIDTH-1:0] idct_1D0_in3;
reg  [REG_WIDTH-1:0] idct_1D0_in4;
reg  [REG_WIDTH-1:0] idct_1D0_in5;
reg  [REG_WIDTH-1:0] idct_1D0_in6;
reg  [REG_WIDTH-1:0] idct_1D0_in7;

// quan_DCT2D
wire [2:0] reg1_waddr;

// dequan
reg [2:0] dequan_raddr;
wire [8*REG_WIDTH-1:0] dequan_out;

// encoder
wire stop;

// decoder
wire wen_deco;
wire [4:0] zcnt1;
wire [2:0] zcnt2;
wire [REG_WIDTH-1:0] decode_out;
wire decoder_finish;
/////////////////////////////////////////////
///         Input register
/////////////////////////////////////////////

reg [ACT_PER_ADDR*IN_WIDTH-1:0] in_R, in_G, in_B;
reg [ACT_PER_ADDR*OUT_WIDTH-1:0] in_code; 
reg in_en;
reg in_mode;
reg [IMG_SIZE-1:0] in_w;
reg [IMG_SIZE-1:0] in_h;

always @(posedge clk) begin
  in_R    <= R;
  in_G    <= G;
  in_B    <= B;
  in_code <= code;
  in_en   <= enable;
  in_mode <= sample_mode;
  in_enco <= encode;
  in_w    <= img_width;
  in_h    <= img_height;
end

/////////////////////////////////////////////
//      Output register
/////////////////////////////////////////////

always @(posedge clk)
begin
  if (~rst_n)
    finish <= 0;
  else
    finish <= (in_enco) ? ctrl_finish : decode_finish;
end

control_en #(
	.N(N),
  .IMG_SIZE(IMG_SIZE),
  .SRAM_ADDR_R(SRAM_ADDR_R)
) control_en (
  // input
  .clk(clk),
  .rst_n(rst_n),
  .enable(in_en),
  .stop(ctrl_stop1),
  .mode_sample(in_mode),
  .img_width(in_w),
  .img_height(in_h),
  // sram read address
  .sram_raddr(sram_raddr_8b),
  // state signal
  .CST_en(CST_en),
  .DCT1_en(DCT1_en),
  .DCT2_en(DCT2_en),
  .ENCO_en0(ENCO_en),
  // register 0 control signal
  .reg0_wen(ctrl0_wen),
  .reg0_r_c(ctrl0_r_c),
  .reg0_wmode(ctrl0_wmode),
  .reg0_raddr(ctrl0_raddr),
  .reg0_waddr(ctrl0_waddr),
  // register 1 control signal
  .reg1_wen(reg1_wen),
  .reg1_r_c(reg1_r_c),
  .reg1_wmode(reg1_wmode),
  .reg1_raddr(reg1_raddr),
  .reg1_waddr(quan_waddr),
  // YUV table control signal, 1: state = Y, 0: state != Y
  .yuv_state1(yuv_state1),
  .yuv_state2(yuv_state2),
  // encoder control signal
  .pad_en(pad_en),
  .en_in_addr(sel_in_addr),
  .dc_en(dc_en),
  .clear(clear),
  .dc_clear(dc_clear), // high when YUV mode is changed
  // high when one 8x8 block encoding is done
  .finish(ctrl_finish)
);

control_de #(
  .SRAM_ADDR_W(SRAM_ADDR_R),
  .IMG_SIZE(IMG_SIZE)
) control_de (
  // input
  .clk(clk),
  .rst_n(rst_n),
  .enable(in_en),
  .encode(in_enco),
  .mode_sample(in_mode),
  .decode_finish(decoder_finish),
  .img_width(in_w),
  .img_height(in_h),
  // output
  .state(decode_state),
  .decode_en(decode_en),
  .reg_wen(decode_wen),
  .reg_r_c(decode_r_c),
  .reg_wmode(decode_wmode),
  .reg_raddr(decode_raddr),
  .reg_waddr(decode_waddr),
  .wsb_Y(wsb_Y),
  .wsb_U(wsb_U),
  .wsb_V(wsb_V),
  .waddr(waddr_8b),
  .finish(decode_finish),
  .mode_out(mode_out),
  .clear(decode_clear)
);

// the reg storing CST output and DCT1 output
reg8x8 #(
  .IN_WIDTH(IN_WIDTH)
) reg_U0 (
  // input
  .clk(clk),
  .rst_n(rst_n),
  .wen(reg0_wen),           // selected
  .r_c(reg0_r_c),           // selected
  .wmode(reg0_wmode),       // selected
  .stop(1'b0),
  .encode(in_enco),
  .state(decode_state),
  .write_addr(reg0_waddr),  // selected
  .read_addr(reg0_raddr),   // selected
  .in(reg0_in),             // selected
  .ctrl_cnt(zcnt1),
  .ctrl_zcnt(zcnt2),
  .sel_in_addr(sel_in_addr),
  .ENCO_en(1'b0),
  // output
  .ctrl_stop(ctrl_stop0),
  .en_in_addr(en0_in_addr),
  .out0(reg0_out0),
  .out1(reg0_out1),
  .out2(reg0_out2),
  .out3(reg0_out3),
  .out4(reg0_out4),
  .out5(reg0_out5),
  .out6(reg0_out6),
  .out7(reg0_out7)
);

reg8x8 #(
  .IN_WIDTH(IN_WIDTH)
) reg_U1 (
  // input
  .clk(clk),
  .rst_n(rst_n),
  .wen(reg1_wen),
  .r_c(reg1_r_c),
  .wmode(reg1_wmode),
  .stop(stop),
  .encode(in_enco),
  .state(decode_state),
  .write_addr(reg1_waddr),
  .read_addr(reg1_raddr),
  .in(reg1_in),
  .ctrl_cnt(zcnt1),
  .ctrl_zcnt(zcnt2),
  .sel_in_addr(sel_in_addr),
  .ENCO_en(ENCO_en),
  // output
  .ctrl_stop(ctrl_stop1),
  .en_in_addr(en1_in_addr),
  .out0(reg1_out0),
  .out1(reg1_out1),
  .out2(reg1_out2),
  .out3(reg1_out3),
  .out4(reg1_out4),
  .out5(reg1_out5),
  .out6(reg1_out6),
  .out7(reg1_out7)
);

rgb2yuv #(
  .ACT_PER_ADDR(ACT_PER_ADDR),
  .IN_WIDTH(IN_WIDTH)
) rgb2yuv (
  // input
  .clk(clk),
  .mode(yuv_state1),
  .R(in_R),
  .G(in_G),
  .B(in_B),
  .pad_en(pad_en),
  // output
  .out(rgb2yuv_o)
);

dct1D #(
  .IN_WIDTH(IN_WIDTH+2),
  .COEF_WIDTH(COEF_WIDTH),
  .COEF_FP(COEF_FP)
) dct1D_U0 (
  //input
  .clk(clk),
  .x0(dct_1D_in0),
  .x1(dct_1D_in1),
  .x2(dct_1D_in2),
  .x3(dct_1D_in3),
  .x4(dct_1D_in4),
  .x5(dct_1D_in5),
  .x6(dct_1D_in6),
  .x7(dct_1D_in7),
  // output
  .y0(dct_1D_out0),
  .y1(dct_1D_out1),
  .y2(dct_1D_out2),
  .y3(dct_1D_out3),
  .y4(dct_1D_out4),
  .y5(dct_1D_out5),
  .y6(dct_1D_out6),
  .y7(dct_1D_out7)
);

idct1D #(
  .IN_WIDTH(REG_WIDTH),
  .COEF_WIDTH(COEF_WIDTH),
  .COEF_FP(COEF_FP)
) idct1D(
  .clk(clk),
  .x0(idct_1D0_in0),
  .x1(idct_1D0_in1),
  .x2(idct_1D0_in2),
  .x3(idct_1D0_in3),
  .x4(idct_1D0_in4),
  .x5(idct_1D0_in5),
  .x6(idct_1D0_in6),
  .x7(idct_1D0_in7),
  .y0(idct_1D0_out0),
  .y1(idct_1D0_out1),
  .y2(idct_1D0_out2),
  .y3(idct_1D0_out3),
  .y4(idct_1D0_out4),
  .y5(idct_1D0_out5),
  .y6(idct_1D0_out6),
  .y7(idct_1D0_out7)
);

quan_DCT2D #(
  .IN_WIDTH(IN_WIDTH+4)
) quan_DCT2D (
  .clk(clk),
.rst_n(rst_n),
  .Q_mode(yuv_state2[1]),
  .write_addr(quan_waddr),
  .in0(dct_1D_out0),
  .in1(dct_1D_out1),
  .in2(dct_1D_out2),
  .in3(dct_1D_out3),
  .in4(dct_1D_out4),
  .in5(dct_1D_out5),
  .in6(dct_1D_out6),
  .in7(dct_1D_out7),
  .reg_waddr(reg1_waddr),
  .out(reg1_in)
);

dequan #(
  .IN_WIDTH(REG_WIDTH)
) dequan (
  .clk(clk),
  .Q_mode(mode_out), // 0: Y, 1: U, V
  .read_addr(dequan_raddr),
  .in0(reg0_out0),
  .in1(reg0_out1),
  .in2(reg0_out2),
  .in3(reg0_out3),
  .in4(reg0_out4),
  .in5(reg0_out5),
  .in6(reg0_out6),
  .in7(reg0_out7),
  .out(dequan_out)
);

encoder #(
  .IN_WIDTH(IN_WIDTH)
) encoder (
  .clk(clk),
  .rst_n(rst_n),
  .mode(yuv_state2[1]),
  .dc_en(dc_en),
  .clear(clear),
  .in(reg1_out0[IN_WIDTH-1:0]),
  .ENCO_en(ENCO_en),
  .dc_clear(dc_clear),
  // output
  .out(code_out),
  .bit_valid(bit_valid),
  .stop(stop)
);

decoder #(
  .SRAM_ADDR_R(SRAM_ADDR_W),
  .REG_WIDTH(REG_WIDTH)
) decoder (
  //input
  .clk(clk),
  .rst_n(rst_n),
  .en(decode_en),
  .in(in_code),
  .mode(mode_out),
  .clear(decode_clear),
  //output
  .sram_raddr(sram_raddr_23b),
  .reg_wen(wen_deco),
  .zcnt1(zcnt1),
  .zcnt2(zcnt2),
  .out(decode_out),
  .finish(decoder_finish)
);

//////////////////////////
//       reg_in
//////////////////////////

localparam IDLE = 3'd0, DECO = 3'd1, IDCT1 = 3'd2, IDCT2 = 3'd3, FINI = 3'd4;

always@* begin
  if (in_enco) begin
    reg0_wen   = ctrl0_wen;
    reg0_r_c   = ctrl0_r_c;
    reg0_wmode = ctrl0_wmode;
    reg0_raddr = ctrl0_raddr;
    reg0_waddr = ctrl0_waddr;
    if (CST_en) begin
      reg0_in = {{7*(IN_WIDTH+2+2){1'b0}}, {4{rgb2yuv_o[IN_WIDTH-1]}}, rgb2yuv_o};
    end
    else begin
      reg0_in = {dct_1D_out7, dct_1D_out6, dct_1D_out5, dct_1D_out4, dct_1D_out3, dct_1D_out2, dct_1D_out1, dct_1D_out0};
    end
  end
  else begin
    reg0_r_c   = decode_r_c;
    reg0_wmode = decode_wmode;
    reg0_raddr = decode_raddr;
    reg0_waddr = decode_waddr;
    case(decode_state)
      DECO: begin
        reg0_in = {{7*(OUT_WIDTH+2+2-1){1'b0}}, decode_out};
        reg0_wen = wen_deco;
      end
      IDCT1: begin
        reg0_in = {idct_1D0_out7, idct_1D0_out6, idct_1D0_out5, idct_1D0_out4, idct_1D0_out3, idct_1D0_out2, idct_1D0_out1, idct_1D0_out0};
        reg0_wen = decode_wen;
      end
      IDCT2: begin
        reg0_in = {idct_1D0_out7, idct_1D0_out6, idct_1D0_out5, idct_1D0_out4, idct_1D0_out3, idct_1D0_out2, idct_1D0_out1, idct_1D0_out0};
        reg0_wen = decode_wen;
      end
      default: begin
        reg0_in = 0;
        reg0_wen = 1;
      end
    endcase
  end
end

/////////////////////////////
//       dct_1D_in
/////////////////////////////

always@* begin
  dct_1D_in0 = reg0_out0[IN_WIDTH+2-1:0];
  dct_1D_in1 = reg0_out1[IN_WIDTH+2-1:0];
  dct_1D_in2 = reg0_out2[IN_WIDTH+2-1:0];
  dct_1D_in3 = reg0_out3[IN_WIDTH+2-1:0];
  dct_1D_in4 = reg0_out4[IN_WIDTH+2-1:0];
  dct_1D_in5 = reg0_out5[IN_WIDTH+2-1:0];
  dct_1D_in6 = reg0_out6[IN_WIDTH+2-1:0];
  dct_1D_in7 = reg0_out7[IN_WIDTH+2-1:0];
end

/////////////////////////////
//       idct_1D_in
/////////////////////////////

reg [IN_WIDTH-1:0] wdata_8b_nx, wdata_8b_nx2;

always@(posedge clk) begin
  idct_1D0_in0 <= idct_1D0_in00;
  idct_1D0_in1 <= idct_1D0_in11;
  idct_1D0_in2 <= idct_1D0_in22;
  idct_1D0_in3 <= idct_1D0_in33;
  idct_1D0_in4 <= idct_1D0_in44;
  idct_1D0_in5 <= idct_1D0_in55;
  idct_1D0_in6 <= idct_1D0_in66;
  idct_1D0_in7 <= idct_1D0_in77;
  wdata_8b     <= wdata_8b_nx;
  wdata_8b_nx  <= wdata_8b_nx2;
end

always@* begin
  wdata_8b_nx2 = reg0_out0;
  dequan_raddr = decode_raddr - 1;
  if(decode_state == IDCT1) begin
    idct_1D0_in00 = dequan_out[11:0];
    idct_1D0_in11 = dequan_out[23:12];
    idct_1D0_in22 = dequan_out[35:24];
    idct_1D0_in33 = dequan_out[47:36];
    idct_1D0_in44 = dequan_out[59:48];
    idct_1D0_in55 = dequan_out[71:60];
    idct_1D0_in66 = dequan_out[83:72];
    idct_1D0_in77 = dequan_out[95:84];
  end
  else begin
    idct_1D0_in00 = reg0_out0;
    idct_1D0_in11 = reg0_out1;
    idct_1D0_in22 = reg0_out2;
    idct_1D0_in33 = reg0_out3;
    idct_1D0_in44 = reg0_out4;
    idct_1D0_in55 = reg0_out5;
    idct_1D0_in66 = reg0_out6;
    idct_1D0_in77 = reg0_out7;
  end
end

endmodule
