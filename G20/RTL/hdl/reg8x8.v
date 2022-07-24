module reg8x8
#(
parameter IN_WIDTH = 8
)
(
input clk,
input rst_n,
input wen,    // 0: write
input r_c,    // 0: write one col,   1: write one row
input wmode,  // 0: write one entry, 1: wirte whole row/column
input stop,   // from encoder
input encode, // 1: encode, 0: decode
input [2:0] state,        // decoder
input [2:0] write_addr,
input [2:0] read_addr,
input [8*(IN_WIDTH+2+2)-1:0] in,
input [4:0] ctrl_cnt,     // decoder
input [2:0] ctrl_zcnt,    // decoder
input [2:0] sel_in_addr,
input ENCO_en,

output reg ctrl_stop,
output reg [2:0] en_in_addr,
output reg [IN_WIDTH+2+2-1:0] out0,
output reg [IN_WIDTH+2+2-1:0] out1,
output reg [IN_WIDTH+2+2-1:0] out2,
output reg [IN_WIDTH+2+2-1:0] out3,
output reg [IN_WIDTH+2+2-1:0] out4,
output reg [IN_WIDTH+2+2-1:0] out5,
output reg [IN_WIDTH+2+2-1:0] out6,
output reg [IN_WIDTH+2+2-1:0] out7
);

reg [IN_WIDTH+2+2-1:0] ENCO_in;
reg [IN_WIDTH+2+2-1:0] out00;
reg [IN_WIDTH+2+2-1:0] out11;
reg [IN_WIDTH+2+2-1:0] out22;
reg [IN_WIDTH+2+2-1:0] out33;
reg [IN_WIDTH+2+2-1:0] out44;
reg [IN_WIDTH+2+2-1:0] out55;
reg [IN_WIDTH+2+2-1:0] out66;
reg [IN_WIDTH+2+2-1:0] out77;
//////////////////////////////
//       8x8 register
//////////////////////////////
reg [IN_WIDTH+2+2-1:0] register [0:7][0:7];
reg [IN_WIDTH+2+2-1:0] register_nx [0:7][0:7];

integer i, j;

always@(posedge clk) begin
  for(i = 0; i < 8; i = i + 1) begin
    for(j = 0; j < 8; j = j + 1) begin
      register[i][j] <= register_nx[i][j];
    end
  end
  en_in_addr <= sel_in_addr;
  out0 <= (((ENCO_en && encode) || (state == 4 && !encode)) ? ENCO_in : out00);
  out1 <= out11;
  out2 <= out22;
  out3 <= out33;
  out4 <= out44;
  out5 <= out55;
  out6 <= out66;
  out7 <= out77;
end

////////////////////////////
//       write data
////////////////////////////

reg [5:0] cnt, ncnt;

always @*
begin
  if (encode) begin
    if (~wen && ~wmode)
      ncnt = cnt + 1;
    else
      ncnt = cnt;
  end
  else begin
    if (wen && ~wmode && state == 4)
      ncnt = cnt + 1;
    else
      ncnt = cnt;
  end
end

always @(posedge clk) begin
  if (~rst_n) 
    cnt <= 0;
  else
    cnt <= ncnt;
end

always@* begin
  if(!wen) begin
    if(wmode) begin
      if(r_c) begin
        for(i = 0; i < 8; i = i + 1) begin
          for(j = 0; j < 8; j = j + 1) begin
              register_nx[i][j] = (i == write_addr) ? in[j*(IN_WIDTH+2+2) +: IN_WIDTH+2+2] : register[i][j];
          end
        end
      end
      else begin
        for(i = 0; i < 8; i = i + 1) begin
          for(j = 0; j < 8; j = j + 1) begin
              register_nx[i][j] = (j == write_addr) ? in[i*(IN_WIDTH+2+2) +: IN_WIDTH+2+2] : register[i][j];
          end
        end
      end
    end
    else begin
      for(i = 0; i < 8; i = i + 1) begin
        for(j = 0; j < 8; j = j + 1) begin
          if (encode) begin
            register_nx[i][j] = (i == cnt[5:3] && j == cnt[2:0]) ? in[0 +: IN_WIDTH+2+2] : register[i][j];
          end
          else begin
            if(ctrl_cnt[0]) begin
              register_nx[i][j] = (i == ctrl_zcnt && j == ctrl_cnt-ctrl_zcnt) ? in : register[i][j];
            end
            else begin
              register_nx[i][j] = (i == ctrl_cnt-ctrl_zcnt && j == ctrl_zcnt) ? in : register[i][j];
            end
          end
        end
      end
    end
  end
  else begin
    for(i = 0; i < 8; i = i + 1) begin
      for(j = 0; j < 8; j = j + 1) begin
        register_nx[i][j] = register[i][j];
      end
    end
  end
end

////////////////////////////
//       read data
////////////////////////////

always @*
begin
  if (encode)
    ENCO_in = register[read_addr][sel_in_addr];
  else
    ENCO_in = register[cnt[5:3]][cnt[2:0]];

  if (stop && ENCO_in != 0) begin
    ctrl_stop = 1;
  end
  else begin
    ctrl_stop = 0;
  end
end

always@* begin    
  if(r_c) begin
    out00 = register[read_addr][0];
    out11 = register[read_addr][1];
    out22 = register[read_addr][2];
    out33 = register[read_addr][3];
    out44 = register[read_addr][4];
    out55 = register[read_addr][5];
    out66 = register[read_addr][6];
    out77 = register[read_addr][7];
  end
  else begin
    out00 = register[0][read_addr];
    out11 = register[1][read_addr];
    out22 = register[2][read_addr];
    out33 = register[3][read_addr];
    out44 = register[4][read_addr];
    out55 = register[5][read_addr];
    out66 = register[6][read_addr];
    out77 = register[7][read_addr];
  end
end

endmodule
