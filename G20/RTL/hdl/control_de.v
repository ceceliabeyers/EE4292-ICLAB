module control_de
#(
parameter SRAM_ADDR_W  = 22,
parameter IMG_SIZE     = 11
)
(
input clk,
input rst_n,
input enable,
input encode,
input mode_sample,
input decode_finish,
input [IMG_SIZE-1:0] img_width,
input [IMG_SIZE-1:0] img_height,

output reg [2:0] state,
output reg decode_en,
output reg reg_wen,
output reg reg_r_c,
output reg reg_wmode,
output reg [2:0] reg_raddr,
output reg [2:0] reg_waddr,
output reg wsb_Y,
output reg wsb_U,
output reg wsb_V,
output reg [SRAM_ADDR_W-1:0] waddr,
output reg finish,
output reg mode_out,
output reg clear
);

localparam IDLE = 3'd0, DECO = 3'd1, IDCT1 = 3'd2, IDCT2 = 3'd3, WRITE = 3'd4, FINI = 3'd5, WAIT = 3'd6;

reg [2:0] nstate;
reg nreg_wen;
reg nreg_r_c;
reg nreg_wmode;
reg [2:0] nreg_raddr;
reg [2:0] nreg_waddr;
reg IDCT1_done;
reg IDCT2_done;
reg WRITE_done;
reg nwsb_Y, nnwsb_Y, nnnwsb_Y;
reg nwsb_U, nnwsb_U, nnnwsb_U;
reg nwsb_V, nnwsb_V, nnnwsb_V;
reg [SRAM_ADDR_W-1:0] nwaddr1, nwaddr2;
reg [SRAM_ADDR_W-1:0] nnwaddr1, nnwaddr2, nnwaddr1_o;
reg [SRAM_ADDR_W-1:0] nnnwaddr1, nnnwaddr2;
reg nfinish;
reg ndecode_en;
reg [1:0] mode, nmode;        // 10: Y, 01: U, 00: V
reg [6:0] cnt, ncnt, cnt_d;
reg mode_out_d;
reg [IMG_SIZE-1:0] cnt_block_row, cnt_block_row_nx;
reg [IMG_SIZE-1:0] cnt_block_col, cnt_block_col_nx;
reg clear_nx;

reg [IMG_SIZE-1:0] img_width_1, img_width_1_nx;
reg [IMG_SIZE-1:0] img_width_2, img_width_2_nx;
reg [IMG_SIZE-1:0] img_height_2, img_height_2_nx;

always@(posedge clk) begin
  if(~rst_n) state <= IDLE;
  else state <= nstate;
end

always@(posedge clk) begin
  if(~rst_n) begin
	cnt <= 0;
	wsb_Y <= 1;
	wsb_U <= 1;
	wsb_V <= 1;
	nnwsb_Y <= 1;
	nnwsb_U <= 1;
	nnwsb_V <= 1;
	nnnwsb_Y <= 1;
	nnnwsb_U <= 1;
	nnnwsb_V <= 1;
	finish <= 0;
	decode_en <= 0;
	mode <= 2;
	cnt_block_row <= 0;
	cnt_block_col <= 0;
	cnt_d <= 0;
	clear <= 0;
  end
  else begin
	cnt <= ncnt;
	cnt_d <= cnt;
	wsb_Y <= encode ? 1 : nnnwsb_Y;
	wsb_U <= encode ? 1 : nnnwsb_U;
	wsb_V <= encode ? 1 : nnnwsb_V;
	nnnwsb_Y <= nnwsb_Y;
	nnnwsb_U <= nnwsb_U;
	nnnwsb_V <= nnwsb_V;	
	nnwsb_Y <= nwsb_Y;
	nnwsb_U <= nwsb_U;
	nnwsb_V <= nwsb_V;
	finish <= nfinish; 
	decode_en <= ndecode_en;
        mode <= nmode;
	cnt_block_row <= cnt_block_row_nx;
	cnt_block_col <= cnt_block_col_nx;
	clear <= clear_nx;
  end
  waddr <= nnnwaddr1 + nnnwaddr2;
  nnnwaddr1 <= nnwaddr1_o;
  nnwaddr1 <= nwaddr1;
  nnnwaddr2 <= nnwaddr2;
  nnwaddr2 <= nwaddr2;
  img_width_1 <= img_width_1_nx;
  img_width_2 <= img_width_2_nx;
  img_height_2 <= img_height_2_nx;
  mode_out_d <= mode_out;
end

always @(posedge clk)
begin
	if(~rst_n) begin
		reg_wen <= 1;
	end
	else begin
  		reg_wen <= nreg_wen;
	end
  		reg_r_c <= nreg_r_c;
  		reg_wmode <= nreg_wmode;
  		reg_raddr <= nreg_raddr;
  		reg_waddr <= nreg_waddr;
end

always@* begin
  case(state) 
    IDLE:  nstate = enable ? DECO : IDLE;
    DECO:  nstate = decode_finish ? IDCT1 : DECO;
    IDCT1: nstate = IDCT1_done ? IDCT2 : IDCT1;
    IDCT2: nstate = IDCT2_done ? WRITE : IDCT2;
    WRITE: nstate = WRITE_done ? WAIT  : WRITE;
    WAIT:  nstate = (cnt == 1) ? DECO  : WAIT;
    FINI:  nstate = FINI;
    default: nstate = IDLE;
  endcase
end

always@* begin
	img_width_1_nx = img_width + 3;
	img_width_2_nx = img_width + 1;
	img_height_2_nx = img_height + 1;
end

// counter
always@* begin
  ncnt = cnt;
  cnt_block_row_nx = cnt_block_row;
  cnt_block_col_nx = cnt_block_col;
  nmode = mode;
  nfinish = 0;
  clear_nx = 0;
  case(state)
    DECO: begin
      ncnt = 0;
      cnt_block_row_nx = cnt_block_row;
      cnt_block_col_nx = cnt_block_col;
      nmode = mode;
      nfinish = 0;
      clear_nx = 0;
    end
    IDCT1: begin
      if (cnt == 15) begin  
        ncnt = 0;
      end
      else begin
        ncnt = cnt + 1;
      end
      cnt_block_row_nx = cnt_block_row;
      cnt_block_col_nx = cnt_block_col;
      nmode = mode;
      nfinish = 0;
      clear_nx = 0;
    end
    IDCT2: begin
      if (cnt == 13) begin  
        ncnt = 0;
      end
      else begin
        ncnt = cnt + 1;
      end
      cnt_block_row_nx = cnt_block_row;
      cnt_block_col_nx = cnt_block_col;
      nmode = mode;
      nfinish = 0;
      clear_nx = 0;
    end
    WRITE: begin
      nfinish = 0;
      if (cnt == 64) begin
        ncnt = 0;
        if(!mode_sample) begin //411
          if(mode_out) begin   //Y
            if(cnt_block_col + 8 >= img_width) begin
              if(cnt_block_row + 8 >= img_height) begin
                cnt_block_row_nx = 0;
                cnt_block_col_nx = 0;
                nmode = mode - 1;
                clear_nx = 1;
              end
              else begin
                cnt_block_row_nx = cnt_block_row + 8;
                cnt_block_col_nx = 0;
                nmode = mode;
                clear_nx = 0;
              end
            end
            else begin
              cnt_block_row_nx = cnt_block_row;
              cnt_block_col_nx = cnt_block_col + 8;
              nmode = mode;
              clear_nx = 0;
            end
          end
          else begin              // UV
            if(cnt_block_col + 8 >= img_width_1[IMG_SIZE-1:2]) begin
              if(cnt_block_row + 8 >= img_height) begin
                cnt_block_row_nx = 0;
                cnt_block_col_nx = 0;
                nmode = mode - 1;
                clear_nx = 1;
              end
              else begin
                cnt_block_row_nx = cnt_block_row + 8;
                cnt_block_col_nx = 0;
                nmode = mode;
                clear_nx = 0;
              end
            end
            else begin
              cnt_block_row_nx = cnt_block_row;
              cnt_block_col_nx = cnt_block_col + 8;
              nmode = mode;
              clear_nx = 0;
            end
          end
	end
	else begin            // 420
          if(mode_out) begin   //Y
            if(cnt_block_col + 8 >= img_width) begin
              if(cnt_block_row + 8 >= img_height) begin
                cnt_block_row_nx = 0;
                cnt_block_col_nx = 0;
                nmode = mode - 1;
                clear_nx = 1;
              end
              else begin
                cnt_block_row_nx = cnt_block_row + 8;
                cnt_block_col_nx = 0;
                nmode = mode;
                clear_nx = 0;
              end
            end
            else begin
              cnt_block_row_nx = cnt_block_row;
              cnt_block_col_nx = cnt_block_col + 8;
              nmode = mode;
              clear_nx = 0;
            end
          end
          else begin              // UV
            if(cnt_block_col + 8 >= img_width_2[IMG_SIZE-1:1]) begin
              if(cnt_block_row + 8 >= img_height_2[IMG_SIZE-1:1]) begin
                cnt_block_row_nx = 0;
                cnt_block_col_nx = 0;
                nmode = mode - 1;
                clear_nx = 1;
              end
              else begin
                cnt_block_row_nx = cnt_block_row + 8;
                cnt_block_col_nx = 0;
                nmode = mode;
                clear_nx = 0;
              end
            end
            else begin
              cnt_block_row_nx = cnt_block_row;
              cnt_block_col_nx = cnt_block_col + 8;
              nmode = mode;
              clear_nx = 0;
            end
          end
	end
      end
      else begin
        ncnt = cnt + 1;
        cnt_block_row_nx = cnt_block_row;
        cnt_block_col_nx = cnt_block_col;
        nmode = mode;
        clear_nx = 0;
      end
    end
    WAIT: begin
      if (cnt == 1) begin
        ncnt = 0;
      end
      else begin
        ncnt = cnt + 1;
      end
      cnt_block_row_nx = cnt_block_row;
      cnt_block_col_nx = cnt_block_col;
      nmode = mode;

      if(cnt == 1 && mode == 3) nfinish = 1;
      else nfinish = 0;
      clear_nx = 0;
    end
    default: begin
      ncnt = cnt;
      cnt_block_row_nx = cnt_block_row;
      cnt_block_col_nx = cnt_block_col;
      nmode = mode;
      nfinish = 0;
      clear_nx = 0;
    end
  endcase
end
// control signal
always@* begin
  ndecode_en = 0;
  nreg_wen = 1;
  nreg_r_c = 1;
  nreg_wmode = 1;
  nreg_raddr = 0;
  nreg_waddr = 0;
  IDCT1_done = 0;
  IDCT2_done = 0;
  WRITE_done = 0;
  mode_out = mode[1];
  case(state)
    DECO: begin
      ndecode_en = 1;
      nreg_wen = 1;
      nreg_r_c = 1;
      nreg_wmode = 0;
      nreg_raddr = 0;
      nreg_waddr = 0;
      IDCT1_done = 0;
      IDCT2_done = 0;
      WRITE_done = 0;
    end
    IDCT1: begin
      ndecode_en = 0;
      nreg_wmode = 1;
      IDCT2_done = 0;
      WRITE_done = 0;

      nreg_waddr = cnt - 7;
      if(cnt >= 7 && cnt <= 14) begin  
        nreg_wen = 0;
      end
      else begin
        nreg_wen = 1;
      end
      IDCT1_done = (cnt == 15) ? 1 : 0;
      nreg_raddr = (cnt == 15) ? 0 : (cnt + 1);
      nreg_r_c = (cnt == 15) ? 0 : 1;
    end
    IDCT2: begin
      ndecode_en = 0;
      nreg_r_c = 0;
      nreg_wmode = 1;
      IDCT1_done = 0;
      WRITE_done = 0;

      nreg_raddr = cnt + 1;
      nreg_waddr = cnt - 5;
      if(cnt >= 5 && cnt <= 12) begin  
        nreg_wen = 0;
      end
      else begin
        nreg_wen = 1;
      end
      IDCT2_done = (cnt == 13) ? 1 : 0;
    end
    WRITE: begin
      ndecode_en = 0;
      nreg_wen = 1;
      nreg_r_c = 1;
      nreg_wmode = 0;
      nreg_raddr = 0;
      nreg_waddr = 0;
      IDCT1_done = 0;
      IDCT2_done = 0;
      WRITE_done = (cnt == 64) ? 1 : 0;
    end
    default: begin
      ndecode_en = 0;
      nreg_wen = 1;
      nreg_r_c = 1;
      nreg_wmode = 1;
      nreg_raddr = 0;
      nreg_waddr = 0;
      IDCT1_done = 0;
      IDCT2_done = 0;
      WRITE_done = 0;
    end
  endcase
end

always@* begin
	nwsb_Y = 1;
        nwsb_U = 1;
        nwsb_V = 1;
        nwaddr1 = 0;
	nwaddr2 = 0;
        nnwaddr1_o = 0;
	case(state)
		WRITE: begin
			nwsb_Y = (cnt != 0 && mode == 2 && (cnt_d[2:0] + cnt_block_col < img_width) && (cnt_d[5:3] + cnt_block_row < img_height)) ? 0 : 1;
			if(!mode_sample) begin
				nwsb_U = (cnt != 0 && mode == 1 && (cnt_d[2:0] + cnt_block_col < {2'b0, img_width_1[IMG_SIZE-1:2]}) && (cnt_d[5:3] + cnt_block_row < img_height)) ? 0 : 1;
				nwsb_V = (cnt != 0 && mode == 0 && (cnt_d[2:0] + cnt_block_col < {2'b0, img_width_1[IMG_SIZE-1:2]}) && (cnt_d[5:3] + cnt_block_row < img_height)) ? 0 : 1;
			end
			else begin
				nwsb_U = (cnt != 0 && mode == 1 && (cnt_d[2:0] + cnt_block_col < {1'b0, img_width_2[IMG_SIZE-1:1]}) && (cnt_d[5:3] + cnt_block_row < {1'b0, img_height_2[IMG_SIZE-1:1]})) ? 0 : 1;
				nwsb_V = (cnt != 0 && mode == 0 && (cnt_d[2:0] + cnt_block_col < {1'b0, img_width_2[IMG_SIZE-1:1]}) && (cnt_d[5:3] + cnt_block_row < {1'b0, img_height_2[IMG_SIZE-1:1]})) ? 0 : 1;
			end
			nwaddr1 = (cnt_block_row + cnt_d[5:3]);
			nwaddr2 = (cnt_block_col + cnt_d[2:0]);
		end
		default: begin
			nwsb_Y = 1;
        		nwsb_U = 1;
        		nwsb_V = 1;
        		nwaddr1 = 0;
			nwaddr2 = 0;
		end
	endcase
	if(!mode_sample) begin
		if(mode_out_d) begin
                	nnwaddr1_o = nnwaddr1 * img_width;
		end
		else begin
			nnwaddr1_o = nnwaddr1 * img_width_1[IMG_SIZE-1:2];
		end
	end
	else begin
		if(mode_out_d) begin
			nnwaddr1_o = nnwaddr1 * img_width;
		end
		else begin
			nnwaddr1_o = nnwaddr1 * img_width_2[IMG_SIZE-1:1];
		end
	end
end





endmodule
