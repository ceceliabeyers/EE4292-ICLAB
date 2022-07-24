module qr_decode(
input clk,                           //clock input
input srstn,                         //synchronous reset (active low)
input qr_decode_start,               //start decoding for one QR code
                                     //1: start (one-cycle pulse)
input sram_rdata,                    //read data from SRAM
output [11:0] sram_raddr,        //read address to SRAM

output decode_valid,                 //decoded code is valid
output [7:0] decode_jis8_code,       //decoded JIS8 code
output qr_decode_finish              //1: decoding one QR code is finished
);

wire pos_find;
wire error_valid;
wire angle_valid;
/*wire find_en;
wire error_en;
wire fill_en;
wire angle_en;
wire mask_en;*/
wire [7:0] length;
wire [8:0] cnt_d;
wire [7:0] text;
//wire demask_en;
wire [2:0] state_d; //add

qr_control qr_control(
	// I
	.clk(clk),
	.srstn(srstn),
	.qr_decode_start(qr_decode_start),
	.pos_find(pos_find),
	.error_valid(error_valid),
	.angle_valid(angle_valid),
	.length(length),
	// O
	.sram_raddr(sram_raddr),
	.cnt_d(cnt_d),
	/*.find_en(find_en),
	.error_en(error_en),
	.angle_en(angle_en),
	.mask_en(mask_en),
	.fill_en(fill_en),
	.demask_en(demask_en),*/
	.state_d(state_d), //add
	.decode_valid(decode_valid),
	.qr_decode_finish(qr_decode_finish)
);

qr_find qr_find(
	// I
	.clk(clk),
	.srstn(srstn),
	.sram_rdata(sram_rdata),
	.cnt(cnt_d),
	/*.find_en(find_en),
	.angle_en(angle_en),
	.error_en(error_en),
	.demask_en(demask_en),
	.mask_en(mask_en),
	.fill_en(fill_en),*/
	.state_d(state_d), //add
	// O
	.pos_find(pos_find),
	.angle_valid(angle_valid),
	.error_valid(error_valid),
	.length(length),
	.text(decode_jis8_code)
);

endmodule



