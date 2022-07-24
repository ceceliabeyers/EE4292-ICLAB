module control_en
#(
parameter N=500000,
parameter IMG_SIZE    = 10,
parameter SRAM_ADDR_R = 20
)
(
input clk,
input rst_n,
input enable,
input stop,
input mode_sample,
input [IMG_SIZE-1:0] img_width,
input [IMG_SIZE-1:0] img_height,

// sram read address
output reg [SRAM_ADDR_R-1:0] sram_raddr,

// state signal
output reg CST_en,
output reg DCT1_en,
output reg DCT2_en,
output reg ENCO_en0,

// register 0 control signal
output reg reg0_wen,
output reg reg0_r_c,
output reg reg0_wmode,
output reg [2:0] reg0_raddr,
output reg [2:0] reg0_waddr,

// register 1 control signal
output reg reg1_wen,
output reg reg1_r_c,
output reg reg1_wmode,
output reg [2:0] reg1_raddr,
output reg [2:0] reg1_waddr,

// YUV table control signal, 1: state = Y, 0: state != Y
output reg [1:0] yuv_state1,
output reg [1:0] yuv_state2,

// encoder control signal
output reg pad_en, 
output reg [2:0] en_in_addr,
output reg dc_en,
output reg clear,
output reg dc_clear, // high when YUV mode is changed

// high when one 8x8 block encoding is done
output reg finish
);

/////////////////////////////////////
//   State parameters declaration
/////////////////////////////////////

localparam IDLE = 3'd0,
           Y    = 3'd1,
           U    = 3'd2,
           V    = 3'd3,
           FINI = 3'd4;

reg [2:0] state, nstate;

reg nCST_en;
reg nDCT1_en;
reg nDCT2_en;
reg ENCO_en, nENCO_en;
reg nENCO_en0;

reg CST_done;
reg DCT1_done;
reg DCT2_done;
reg ENCO_done;
reg next_blk;
reg SP_done;
reg state2_en, nstate2_en;
reg pre_clear, npre_clear;
reg nblk_last;  // high when one 8x8 encoding is done
reg [1:0] yuv_nstate1;
reg [1:0] yuv_nstate2;

//////////////////////////////////////
//       Finite state machine
//////////////////////////////////////

always @(posedge clk)
begin
  if (~rst_n) begin
    state      <= IDLE;
    state2_en  <= 0;
    yuv_state1 <= 0;
    yuv_state2 <= 0;
    CST_en     <= 0;
    DCT1_en    <= 0;
    DCT2_en    <= 0;
    ENCO_en    <= 0;
    ENCO_en0   <= 0;
    next_blk   <= 0;
    nblk_last  <= 0;
    pre_clear  <= 0;
  end
  else begin
    state      <= nstate;
    state2_en  <= nstate2_en;
    yuv_state1 <= yuv_nstate1;
    yuv_state2 <= yuv_nstate2;
    CST_en     <= nCST_en;
    DCT1_en    <= nDCT1_en;
    DCT2_en    <= nDCT2_en;
    ENCO_en    <= nENCO_en;
    ENCO_en0   <= nENCO_en0;
    next_blk   <= nblk_last;
    nblk_last  <= ENCO_done;
    pre_clear  <= npre_clear;
  end
end

always @*
begin
	case(state) // synopsys parallel_case
    IDLE: begin
      nstate = enable  ? Y : IDLE;
      yuv_nstate1 = 2'b11;
    end
    Y: begin
      nstate = SP_done ? U : Y;
      yuv_nstate1 = 2'b10;
    end
    U: begin
      nstate = SP_done ? V : U;
      yuv_nstate1 = 2'b01;
    end
		V: begin
      nstate = SP_done ? FINI : V;
      yuv_nstate1 = 2'b00;
    end
    FINI: begin
      nstate = FINI;
      yuv_nstate1 = 2'b11;
    end
		default : begin
      nstate = IDLE;
      yuv_nstate1 = 2'b11;
    end
	endcase
end

always @*
begin
  if (state == FINI && next_blk)
    finish = 1;
  else
    finish = 0;
end

always @*
begin
  if (SP_done)
    npre_clear = 1;
  else if (dc_clear)
    npre_clear = 0;
  else
    npre_clear = pre_clear;
end

always @*
begin
  if (next_blk && pre_clear)
    dc_clear = 1;
  else
    dc_clear = 0;
end

always @*
begin
  if (!state2_en)
    yuv_nstate2 = yuv_state2;
  else
    yuv_nstate2 = yuv_state1;
end

always @*
begin
  if (DCT1_done)
    nstate2_en = 1;
  else if (SP_done)
    nstate2_en = 0;
  else
    nstate2_en = state2_en;  
end

always @*
begin
  if ((state == IDLE && enable) || next_blk)
    nCST_en = 1;
  else if (CST_done)
    nCST_en = 0;
  else
    nCST_en = CST_en;
end

always @*
begin
  if (CST_done)
    nDCT1_en = 1;
  else if (DCT1_done)
    nDCT1_en = 0;
  else
    nDCT1_en = DCT1_en;
end

always @*
begin
  if ((state == IDLE && enable) || next_blk)
    nDCT2_en = 1;
  else if (DCT2_done)
    nDCT2_en = 0;
  else
    nDCT2_en = DCT2_en;
end

always @*
begin
  if (DCT2_done)
    nENCO_en = 1;
  else if (ENCO_done)
    nENCO_en = 0;
  else
    nENCO_en = ENCO_en;
end

always @*
begin
  if (state > 1 && DCT2_done)
    nENCO_en0 = 1;
  else if (DCT2_done && state2_en)
    nENCO_en0 = 1;
  else if (ENCO_done)
    nENCO_en0 = 0;
  else
    nENCO_en0 = ENCO_en0;
end

//////////////////////////////////////////////
//              Counter
//////////////////////////////////////////////

reg [IMG_SIZE-1:0] blk_rcnt, blk_rncnt;
reg [IMG_SIZE-1:0] blk_ccnt, blk_cncnt;
reg [6:0] CST_cnt, CST_ncnt;
reg [4:0] DCT1_cnt, DCT1_ncnt;
reg [4:0] DCT2_cnt, DCT2_ncnt;
reg [4:0] ENCO_cnt, ENCO_ncnt;
reg [2:0] ENCO_zcnt, ENCO_zncnt;

always @(posedge clk)
begin
  if (~rst_n) begin
    blk_rcnt  <= 0;
    blk_ccnt  <= 0;
    CST_cnt   <= 0;
    DCT1_cnt  <= 0;
    DCT2_cnt  <= 0;
    ENCO_cnt  <= 0;
    ENCO_zcnt <= 0;
  end  
  else begin
    blk_rcnt  <= (SP_done) ? 0 : blk_rncnt;
    blk_ccnt  <= (SP_done) ? 0 : blk_cncnt;
    CST_cnt   <= CST_ncnt;
    DCT1_cnt  <= DCT1_ncnt;
    DCT2_cnt  <= DCT2_ncnt;
    ENCO_cnt  <= ENCO_ncnt;
    ENCO_zcnt <= ENCO_zncnt;
  end
end

always @*
begin
  if (next_blk) begin
    if (state == Y) begin
      blk_rncnt = (blk_ccnt + 8 >= img_width) ? blk_rcnt + 8 : blk_rcnt;
      blk_cncnt = (blk_ccnt + 8 >= img_width) ? 0 : blk_ccnt + 8;
    end
    else begin
      if (!mode_sample) begin
        blk_rncnt = (blk_ccnt + 32 >= img_width) ? blk_rcnt + 8 : blk_rcnt;
        blk_cncnt = (blk_ccnt + 32 >= img_width) ? 0 : blk_ccnt + 32;
      end
      else begin
        blk_rncnt = (blk_ccnt + 16 >= img_width) ? blk_rcnt + 16 : blk_rcnt;
        blk_cncnt = (blk_ccnt + 16 >= img_width) ? 0 : blk_ccnt + 16;
      end
    end
  end
  else begin
    blk_rncnt = blk_rcnt;
    blk_cncnt = blk_ccnt;
  end 
end

always @* 
begin
  if (CST_en)
    CST_ncnt = CST_cnt + 1;
  else
    CST_ncnt = 0;
end

always @* 
begin
  if (DCT1_en)
    DCT1_ncnt = DCT1_cnt + 1;
  else
    DCT1_ncnt = 0;
end

always @* 
begin
  if (DCT2_en)
    DCT2_ncnt = DCT2_cnt + 1;
  else
    DCT2_ncnt = 0;
end

always @* 
begin
  if (ENCO_en && stop) begin
    ENCO_ncnt  = ENCO_cnt;
    ENCO_zncnt = ENCO_zcnt;
  end
  else if (ENCO_en) begin
    if (ENCO_cnt > 6 && ENCO_zcnt == 7) begin
      ENCO_ncnt  = ENCO_cnt + 1;
      ENCO_zncnt = ENCO_cnt - 6;
    end
    else if (ENCO_zcnt == ENCO_cnt[2:0] && ENCO_cnt <= 6) begin
      ENCO_ncnt  = ENCO_cnt + 1;
      ENCO_zncnt = 0;
    end
    else begin
      ENCO_ncnt  = ENCO_cnt;
      ENCO_zncnt = ENCO_zcnt + 1;
    end
  end
  else begin
    ENCO_ncnt  = 0;
    ENCO_zncnt = 0;
  end
end

//////////////////////////////////////////////
//           SRAM Address Block
//////////////////////////////////////////////

reg [SRAM_ADDR_R-1:0] nsram_raddr;
reg [IMG_SIZE-1:0] r_addr, r_naddr;
reg [IMG_SIZE-1:0] c_addr, c_naddr;
reg pad_enll, pad_enl, npad_en;

always @(posedge clk)
begin
  sram_raddr <= nsram_raddr;
  r_addr     <= r_naddr;
  c_addr     <= c_naddr;
  pad_enll   <= npad_en;
  pad_enl    <= pad_enll;
  pad_en     <= pad_enl;
end

always @*
begin
  if (state == Y) begin
    r_naddr = blk_rcnt + CST_cnt[5:3];
    c_naddr = blk_ccnt + CST_cnt[2:0];
  end
  else if (mode_sample) begin
    r_naddr = blk_rcnt + CST_cnt[5:3] * 2;
    c_naddr = blk_ccnt + CST_cnt[2:0] * 2;
  end
  else begin
    r_naddr = blk_rcnt + CST_cnt[5:3];
    c_naddr = blk_ccnt + CST_cnt[2:0] * 4;
  end
end

always @*
begin
  if (r_addr >= img_height || c_addr >= img_width) begin
    npad_en = 1;
    nsram_raddr = 0;
  end
  else begin
    npad_en = 0;
    nsram_raddr = img_width * r_addr + c_addr;
  end
end

/*always @*
begin
  if (state == Y)
    nsram_raddr = img_width * (CST_cnt[5:3] + blk_rcnt) + CST_cnt[2:0] + blk_ccnt;
  else if (mode_sample)
    nsram_raddr = img_width * (CST_cnt[5:3] * 2 + blk_rcnt) + CST_cnt[2:0] * 2 + blk_ccnt;
  else
    nsram_raddr = img_width * (CST_cnt[5:3] + blk_rcnt) + CST_cnt[2:0] * 4 + blk_ccnt;
end*/

always @*
begin
  if (state == Y) begin
    SP_done = ((blk_rcnt + 8 >= img_height) && (blk_ccnt + 8 >= img_width) && next_blk) ? 1 : 0;
  end
  else begin
    if (!mode_sample) begin
      SP_done = ((blk_rcnt + 8 >= img_height) && (blk_ccnt + 32 >= img_width) && next_blk) ? 1 : 0;
    end
    else begin
      SP_done = ((blk_rcnt + 16 >= img_height) && (blk_ccnt + 16 >= img_width) && next_blk) ? 1 : 0;
    end
  end
end

//////////////////////////////////////////////
//    Register 8x8 Control Signal Block
//////////////////////////////////////////////

reg dc_en_nx;
reg clear_nx;
reg nreg0_wen, nreg1_wen;
reg nreg0_r_c, nreg1_r_c;
reg nreg0_wmode, nreg1_wmode;
reg [2:0] nen_in_addr, en_in_addr_last;
reg [2:0] nreg0_raddr, nreg1_raddr;
reg [2:0] nreg0_waddr, nreg1_waddr;

always @(posedge clk)
begin
  if (~rst_n) begin
    clear    <= 0;
    dc_en    <= 0;
		reg0_wen <= 1;
    reg1_wen <= 1;
  end
  else begin
    clear    <= clear_nx;
    dc_en    <= dc_en_nx;
		reg0_wen <= nreg0_wen;
    reg1_wen <= nreg1_wen;
  end
end

always @(posedge clk)
begin
  //en_in_addr      <= en_in_addr_last;
  en_in_addr      <= nen_in_addr;
  reg0_r_c        <= nreg0_r_c;
  reg0_wmode      <= nreg0_wmode;
  reg0_raddr      <= nreg0_raddr;
  reg0_waddr      <= nreg0_waddr;
  reg1_r_c        <= nreg1_r_c;
  reg1_wmode      <= nreg1_wmode;
  reg1_raddr      <= nreg1_raddr;
  reg1_waddr      <= nreg1_waddr;
end

always @*
begin
  CST_done  = (CST_en  && CST_cnt  == 73) ? 1 : 0;
  DCT1_done = (DCT1_en && DCT1_cnt == 12) ? 1 : 0;
  DCT2_done = (DCT2_en && DCT2_cnt == 15) ? 1 : 0;
  ENCO_done = (ENCO_en && ENCO_cnt == 15 && ENCO_zcnt == 5) ? 1 : 0;
end

always @*
begin
  if (ENCO_zcnt == 7 && ENCO_cnt == 14 && !stop && ENCO_en0) begin
    clear_nx = 1;
  end
  else begin
    clear_nx = 0;
  end
  dc_en_nx = (ENCO_zcnt == 0 && ENCO_cnt == 0 && ENCO_en0) ? 1 : 0;
end

always @*
begin
  nreg0_r_c = (DCT2_en || next_blk) ? 1 : 0;
  nreg0_waddr = DCT1_cnt - 4;
  nreg0_wmode = (DCT1_en) ? 1 : 0;
  if (CST_cnt >= 7 && CST_cnt <= 70) begin
  //if (CST_cnt >= 6 && CST_cnt <= 69) begin
    nreg0_wen = 0;
  end
  else if (DCT1_cnt >= 4 && DCT1_cnt <= 11) begin
    nreg0_wen = 0;
  end
  else begin
    nreg0_wen = 1;
  end
  if (DCT1_en) begin
    nreg0_raddr = DCT1_cnt + 1;
  end
  else if (DCT2_en) begin
    nreg0_raddr = DCT2_cnt + 1;
  end
  else begin
    nreg0_raddr = 0;
  end
end

always @*
begin
  nreg1_r_c = 1;
  nreg1_waddr = DCT2_cnt - 4;
  if (DCT2_cnt >= 7 && DCT2_cnt <= 14) begin
    nreg1_wen = 0;
  end
  else begin
    nreg1_wen = 1;
  end
  if (DCT2_en) begin
    nreg1_raddr = DCT2_cnt + 1;
    nen_in_addr = 0;
    nreg1_wmode = 1;
  end
  else if (ENCO_en) begin
    nreg1_raddr = (ENCO_ncnt[0] == 1) ? ENCO_zncnt : ENCO_ncnt - ENCO_zncnt;
    nen_in_addr = (ENCO_ncnt[0] == 0) ? ENCO_zncnt : ENCO_ncnt - ENCO_zncnt;
    nreg1_wmode = 1;
  end
  else begin
    nreg1_raddr = 0;
    nen_in_addr = 0;
    nreg1_wmode = 0;
  end
end

endmodule
