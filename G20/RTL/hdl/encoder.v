module encoder #(
parameter IN_WIDTH = 8
)
(
input clk,
input rst_n,
input dc_en,
input clear,
input mode,
input signed [IN_WIDTH-1:0] in,
input ENCO_en,
input dc_clear,
output reg [23-1:0] out,
output reg [4:0] bit_valid,
output reg stop
);

reg signed [IN_WIDTH-1:0] pre_dc, n_dc;
reg [5:0] ac_cnt, n_ac_cnt;
reg [3:0] ac_cnt_sel;
reg [3:0] ac_cnt_sel_d;
reg signed [IN_WIDTH-1:0] ac_value, ac_value_neg; //(ac_cnt, ac_value)
reg ac_en;
reg ac_valid, nac_valid;
reg ac_en_d, ac_en_d2, dc_en_d, dc_en_d2;
reg signed [IN_WIDTH+1-1:0] dc_diff, dc_diff_neg;
reg [4:0] len1, len1_d;
reg [3:0] len2, len2_d, len2_d2;
reg [15:0] code1, code1_d;
reg [8:0] code2, code2_d, code2_d2;

reg [23-1:0] out_nx;
reg [4:0] bit_valid_nx;

always @(posedge clk) begin
  code1_d <= code1;
  code2_d <= code2;
  code2_d2 <= code2_d;
  len1_d <= len1;
  len2_d <= len2;
  len2_d2 <= len2_d;
  ac_en_d  <= ac_en;
  ac_en_d2 <= ((dc_en) ? 0 : ac_en_d);
  dc_en_d <= dc_en;
  dc_en_d2 <= dc_en_d;
  out <= out_nx;
  ac_cnt_sel_d <= ac_cnt_sel;
end

always @(posedge clk) begin
  if(~rst_n) begin
    pre_dc    <= 0;
    ac_cnt    <= 0;
    bit_valid <= 0;
    ac_valid  <= 0;
  end
  else begin
    pre_dc    <= n_dc;
    ac_cnt    <= (ENCO_en) ? n_ac_cnt : 0;
    bit_valid <= bit_valid_nx;
    ac_valid  <= nac_valid;
  end
end

always @* 
begin
  if (ENCO_en && dc_en)
    nac_valid = 1;
  else if (clear)
    nac_valid = 0;
  else
    nac_valid = ac_valid;
end

always @(*) begin
  if(dc_en) begin
    n_dc = in;
  end 
  else if (dc_clear) begin
    n_dc = 0;
  end
  else begin
    n_dc = pre_dc;
  end
end

always @*
begin
  if (ENCO_en && n_ac_cnt > 15) begin
    stop = 1;
  end
  else begin
    stop = 0;
  end
end

always @*
begin
  if (ac_valid && (in != 0 || clear))
    ac_en = 1;
  else
    ac_en = 0;
end

/*always @*
begin
  if (ENCO_en) begin
    if (!dc_en && (in != 0 || clear)) begin
      ac_en = 1;
    end
    else begin
      ac_en = 0;
    end
  end
  else begin
    ac_en = 0;
  end
end*/

always @(*) begin
  if(clear) begin
    n_ac_cnt = 0;
    ac_value = in;
    if(in == 0) begin
      ac_cnt_sel = 0;
    end
    else begin
      ac_cnt_sel = ac_cnt[3:0];
    end
  end 
  else begin
    if(in == 0) begin
      ac_value = in;
      n_ac_cnt = (dc_en) ? 0 : ac_cnt + 1;
      ac_cnt_sel = ac_cnt[3:0];
    end
    else begin
      if(ac_cnt > 15) begin
        ac_value = 0;
        n_ac_cnt = ac_cnt - 15;
        ac_cnt_sel = 15;
      end
      else begin
        ac_value = in;
        n_ac_cnt = 0;
        ac_cnt_sel = ac_cnt[3:0];
      end
    end
  end
end

always @(*) begin
  dc_diff = in - pre_dc;
  dc_diff_neg = -dc_diff;
  ac_value_neg = -ac_value;

  if(dc_en) begin
    if(dc_diff[8]) begin
      if(dc_diff_neg[7]) begin
        len2 = 8;
        code2 = 255 - dc_diff_neg;
      end
      else if(dc_diff_neg[6]) begin
        len2 = 7;
        code2 = 127 - dc_diff_neg;
      end
      else if(dc_diff_neg[5]) begin 
        len2 = 6;
        code2 = 63 - dc_diff_neg;
      end
      else if(dc_diff_neg[4]) begin
        len2 = 5;
        code2 = 31 - dc_diff_neg;
      end
      else if(dc_diff_neg[3]) begin 
        len2 = 4;
        code2 = 15 - dc_diff_neg;
      end
      else if(dc_diff_neg[2]) begin 
        len2 = 3;
        code2 = 7 - dc_diff_neg;
      end
      else if(dc_diff_neg[1]) begin 
        len2 = 2;
        code2 = 3 - dc_diff_neg;
      end
      else if(dc_diff_neg[0]) begin
        len2 = 1;
        code2 = 1 - dc_diff_neg;
      end
      else begin
        len2 = 0;
        code2 = 0;
      end
    end
    else begin
      code2 = dc_diff;
      if(dc_diff[7]) len2 = 8;
      else if(dc_diff[6]) len2 = 7;
      else if(dc_diff[5]) len2 = 6;
      else if(dc_diff[4]) len2 = 5;
      else if(dc_diff[3]) len2 = 4;
      else if(dc_diff[2]) len2 = 3;
      else if(dc_diff[1]) len2 = 2;
      else if(dc_diff[0]) len2 = 1;
      else len2 = 0;
    end
  end
  else if(ac_en) begin
    if(ac_value[IN_WIDTH-1]) begin
      if(ac_value_neg[6]) begin
        len2 = 7;
        code2 = 127 - ac_value_neg;
      end
      else if(ac_value_neg[5]) begin 
        len2 = 6;
        code2 = 63 - ac_value_neg;
      end
      else if(ac_value_neg[4]) begin
        len2 = 5;
        code2 = 31 - ac_value_neg;
      end
      else if(ac_value_neg[3]) begin 
        len2 = 4;
        code2 = 15 - ac_value_neg;
      end
      else if(ac_value_neg[2]) begin 
        len2 = 3;
        code2 = 7 - ac_value_neg;
      end
      else if(ac_value_neg[1]) begin 
        len2 = 2;
        code2 = 3 - ac_value_neg;
      end
      else if(ac_value_neg[0]) begin
        len2 = 1;
        code2 = 1 - ac_value_neg;
      end
      else begin
        len2 = 0;
        code2 = 0;
      end
    end
    else begin
      code2 = ac_value;
      if(ac_value[6]) len2 = 7;
      else if(ac_value[5]) len2 = 6;
      else if(ac_value[4]) len2 = 5;
      else if(ac_value[3]) len2 = 4;
      else if(ac_value[2]) len2 = 3;
      else if(ac_value[1]) len2 = 2;
      else if(ac_value[0]) len2 = 1;
      else len2 = 0;
    end
  end
  else begin
    code2 = 0;
    len2 = 0;
  end

  if(mode) begin
    if(dc_en_d) begin
      case(len2_d)  // synopsys parallel_case
        4'd0: begin
          len1 = 2;
          code1 = 15'b000000000000000;
        end
        4'd1: begin
          len1 = 3;
          code1 = 15'b000000000000010;
        end
        4'd2: begin
          len1 = 3;
          code1 = 15'b000000000000011;
        end
        4'd3: begin
          len1 = 3;
          code1 = 15'b000000000000100;
        end
        4'd4: begin
          len1 = 3;
          code1 = 15'b000000000000101;
        end
        4'd5: begin
          len1 = 3;
          code1 = 15'b000000000000110;
        end
        4'd6: begin
          len1 = 4;
          code1 = 15'b000000000001110;
        end
        4'd7: begin
          len1 = 5;
          code1 = 15'b000000000011110;
        end
        4'd8: begin
          len1 = 6;
          code1 = 15'b000000000111110;
        end
        default: begin
          len1 = 0;
          code1 = 15'b000000000111111;
        end
      endcase
    end
    else if(ac_en_d) begin
      case(ac_cnt_sel_d)  // synopsys parallel_case
        0 : begin
          case(len2_d)
            0: begin
              len1 = 4;
              code1 = 16'b0000_0000_0000_1010;
            end
            1: begin
              len1 = 2;
              code1 = 16'b0000_0000_0000_0000;
            end
            2: begin
              len1 = 2;
              code1 = 16'b0000_0000_0000_0001;
            end
            3: begin
              len1 = 3;
              code1 = 16'b0000_0000_0000_0100;
            end
            4: begin
              len1 = 4;
              code1 = 16'b0000_0000_0000_1011;
            end
            5: begin
              len1 = 5;
              code1 = 16'b0000_0000_0001_1010;
            end
            6: begin
              len1 = 7;
              code1 = 16'b0000_0000_0111_1000;
            end
            7: begin
              len1 = 8;
              code1 = 16'b0000_0000_1111_1000;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        1 : begin
          case(len2_d)
            1: begin
              len1 = 4;
              code1 = 16'b0000_0000_0000_1100;
            end
            2: begin
              len1 = 5;
              code1 = 16'b0000_0000_0001_1011;
            end
            3: begin
              len1 = 7;
              code1 = 16'b0000_0000_0111_1001;
            end
            4: begin
              len1 = 9;
              code1 = 16'b0000_0001_1111_0110;
            end
            5: begin
              len1 = 11;
              code1 = 16'b0000_0111_1111_0110;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1000_0100;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1000_0101;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        2 : begin
          case(len2_d)
            1: begin
              len1 = 5;
              code1 = 16'b0000_0000_0001_1100;
            end
            2: begin
              len1 = 8;
              code1 = 16'b0000_0000_1111_1001;
            end
            3: begin
              len1 = 10;
              code1 = 16'b0000_0011_1111_0111;
            end
            4: begin
              len1 = 12;
              code1 = 16'b0000_1111_1111_0100;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1000_1001;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1000_1010;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1000_1011;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        3 : begin
          case(len2_d)
            1: begin
              len1 = 6;
              code1 = 16'b0000_0000_0011_1010;
            end
            2: begin
              len1 = 9;
              code1 = 16'b0000_0001_1111_0111;
            end
            3: begin
              len1 = 12;
              code1 = 16'b0000_1111_1111_0101;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1000_1111;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_0000;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_0001;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_0010;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        4 : begin
          case(len2_d)
            1: begin
              len1 = 6;
              code1 = 16'b0000_0000_0011_1011;
            end
            2: begin
              len1 = 10;
              code1 = 16'b0000_0011_1111_1000;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_0110;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_0111;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_1000;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_1001;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_1010;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        5 : begin
          case(len2_d)
            1: begin
              len1 = 7;
              code1 = 16'b0000_0000_0111_1010;
            end
            2: begin
              len1 = 11;
              code1 = 16'b0000_0111_1111_0111;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_1110;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_1111;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_0000;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_0001;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_0010;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        6 : begin
          case(len2_d)
            1: begin
              len1 = 7;
              code1 = 16'b0000_0000_0111_1011;
            end
            2: begin
              len1 = 12;
              code1 = 16'b0000_1111_1111_0110;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_0110;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_0111;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_1000;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_1001;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_1010;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        7 : begin
          case(len2_d)
            1: begin
              len1 = 8;
              code1 = 16'b0000_0000_1111_1010;
            end
            2: begin
              len1 = 12;
              code1 = 16'b0000_1111_1111_0111;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_1110;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_1111;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_0000;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_0001;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_0010;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        8 : begin
          case(len2_d)
            1: begin
              len1 = 9;
              code1 = 16'b0000_0001_1111_1000;
            end
            2: begin
              len1 = 15;
              code1 = 16'b0111_1111_1100_0000;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_0110;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_0111;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_1000;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_1001;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_1010;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        9 : begin
          case(len2_d)
            1: begin
              len1 = 9;
              code1 = 16'b0000_0001_1111_1001;
            end
            2: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_1110;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_1111;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_0000;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_0001;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_0010;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_0011;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        10: begin
          case(len2_d)
            1: begin
              len1 = 9;
              code1 = 16'b0000_0001_1111_1010;
            end
            2: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_0111;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_1000;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_1001;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_1010;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_1011;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_1100;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        11: begin
          case(len2_d)
            1: begin
              len1 = 10;
              code1 = 16'b0000_0011_1111_1001;
            end
            2: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_0000;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_0001;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_0010;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_0011;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_0100;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_0101;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        12: begin
          case(len2_d)
            1: begin
              len1 = 10;
              code1 = 16'b0000_0011_1111_1010;
            end
            2: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_1001;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_1010;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_1011;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_1100;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_1101;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_1110;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        13: begin
          case(len2_d)
            1: begin
              len1 = 11;
              code1 = 16'b0000_0111_1111_1000;
            end
            2: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_0010;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_0011;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_0100;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_0101;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_0110;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_0111;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        14: begin
          case(len2_d)
            1: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_1011;
            end
            2: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_1100;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_1101;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_1110;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_1111;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_0000;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_0001;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        15: begin
          case(len2_d)
            0: begin
              len1 = 11; 
              code1 = 16'b0000_0111_1111_1001;
            end
            1: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_0101;
            end
            2: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_0110;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_0111;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_1000;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_1001;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_1010;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_1011;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        default: begin
          len1 = 0;
          code1 = 0;
        end
      endcase
    end
    else begin
      len1 = 0;
      code1 = 0;
    end
  end
  else begin
    if(dc_en_d) begin
      case(len2_d)  // synopsys parallel_case
        4'd0: begin
          len1 = 2;
          code1 = 15'b000000000000000;
        end
        4'd1: begin
          len1 = 2;
          code1 = 15'b000000000000001;
        end
        4'd2: begin
          len1 = 2;
          code1 = 15'b000000000000010;
        end
        4'd3: begin
          len1 = 3;
          code1 = 15'b000000000000110;
        end
        4'd4: begin
          len1 = 4;
          code1 = 15'b000000000001110;
        end
        4'd5: begin
          len1 = 5;
          code1 = 15'b000000000011110;
        end
        4'd6: begin
          len1 = 6;
          code1 = 15'b000000000111110;
        end
        4'd7: begin
          len1 = 7;
          code1 = 15'b000000001111110;
        end
        4'd8: begin
          len1 = 8;
          code1 = 15'b000000011111110;
        end
        default: begin
          len1 = 0;
          code1 = 15'b000000011111111;
        end
      endcase
    end
    else if(ac_en_d) begin
      case(ac_cnt_sel_d)  // synopsys parallel_case
        0 : begin
          case(len2_d)
            0: begin
              len1 = 2;
              code1 = 16'b0000_0000_0000_0000;
            end
            1: begin
              len1 = 2;
              code1 = 16'b0000_0000_0000_0001;
            end
            2: begin
              len1 = 3;
              code1 = 16'b0000_0000_0000_0100;
            end
            3: begin
              len1 = 4;
              code1 = 16'b0000_0000_0000_1010;
            end
            4: begin
              len1 = 5;
              code1 = 16'b0000_0000_0001_1000;
            end
            5: begin
              len1 = 5;
              code1 = 16'b0000_0000_0001_1001;
            end
            6: begin
              len1 = 6;
              code1 = 16'b0000_0000_0011_1000;
            end
            7: begin
              len1 = 7;
              code1 = 16'b0000_0000_0111_1000;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        1 : begin
          case(len2_d)
            1: begin
              len1 = 4;
              code1 = 16'b0000_0000_0000_1011;
            end
            2: begin
              len1 = 6;
              code1 = 16'b0000_0000_0011_1001;
            end
            3: begin
              len1 = 8;
              code1 = 16'b0000_0000_1111_0110;
            end
            4: begin
              len1 = 9;
              code1 = 16'b0000_0001_1111_0101;
            end
            5: begin
              len1 = 11;
              code1 = 16'b0000_0111_1111_0110;
            end
            6: begin
              len1 = 12;
              code1 = 16'b0000_1111_1111_0101;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1000_1000;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        2 : begin
          case(len2_d)
            1: begin
              len1 = 5;
              code1 = 16'b0000_0000_0001_1010;
            end
            2: begin
              len1 = 8;
              code1 = 16'b0000_0000_1111_0111;
            end
            3: begin
              len1 = 10;
              code1 = 16'b0000_0011_1111_0111;
            end
            4: begin
              len1 = 12;
              code1 = 16'b0000_1111_1111_0110;
            end
            5: begin
              len1 = 15;
              code1 = 16'b0111_1111_1000_0010;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1000_1100;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1000_1101;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        3 : begin
          case(len2_d)
            1: begin
              len1 = 5;
              code1 = 16'b0000_0000_0001_1011;
            end
            2: begin
              len1 = 8;
              code1 = 16'b0000_0000_1111_1000;
            end
            3: begin
              len1 = 10;
              code1 = 16'b0000_0011_1111_1000;
            end
            4: begin
              len1 = 12;
              code1 = 16'b0000_1111_1111_0111;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_0001;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_0010;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_0011;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        4 : begin
          case(len2_d)
            1: begin
              len1 = 6;
              code1 = 16'b0000_0000_0011_1010;
            end
            2: begin
              len1 = 9;
              code1 = 16'b0000_0001_1111_0110;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_0111;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_1000;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_1001;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_1010;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_1011;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        5 : begin
          case(len2_d)
            1: begin
              len1 = 6;
              code1 = 16'b0000_0000_0011_1011;
            end
            2: begin
              len1 = 10;
              code1 = 16'b0000_0011_1111_1001;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1001_1111;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_0000;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_0001;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_0010;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_0011;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        6 : begin
          case(len2_d)
            1: begin
              len1 = 7;
              code1 = 16'b0000_0000_0111_1001;
            end
            2: begin
              len1 = 11;
              code1 = 16'b0000_0111_1111_1011;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_0111;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_1000;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_1001;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_1010;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_1011;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        7 : begin
          case(len2_d)
            1: begin
              len1 = 7;
              code1 = 16'b0000_0000_0111_1010;
            end
            2: begin
              len1 = 11;
              code1 = 16'b0000_0111_1111_1000;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1010_1111;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_0000;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_0001;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_0010;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_0011;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        8 : begin
          case(len2_d)
            1: begin
              len1 = 8;
              code1 = 16'b0000_0000_1111_1001;
            end
            2: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_0111;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_1000;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_1001;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_1010;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_1011;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1011_1100;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        9 : begin
          case(len2_d)
            1: begin
              len1 = 9;
              code1 = 16'b0000_0001_1111_0111;
            end
            2: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_0000;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_0001;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_0010;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_0011;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_0100;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_0101;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        10: begin
          case(len2_d)
            1: begin
              len1 = 9;
              code1 = 16'b0000_0001_1111_1000;
            end
            2: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_1001;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_1010;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_1011;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_1100;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_1101;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1100_1110;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        11: begin
          case(len2_d)
            1: begin
              len1 = 9;
              code1 = 16'b0000_0001_1111_1001;
            end
            2: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_0010;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_0011;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_0100;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_0101;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_0110;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_0111;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        12: begin
          case(len2_d)
            1: begin
              len1 = 9;
              code1 = 16'b0000_0001_1111_1010;
            end
            2: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_1011;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_1100;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_1101;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_1110;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1101_1111;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_0000;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        13: begin
          case(len2_d)
            1: begin
              len1 = 11;
              code1 = 16'b0000_0111_1111_1001;
            end
            2: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_0100;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_0101;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_0110;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_0111;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_1000;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_1001;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        14: begin
          case(len2_d)
            1: begin
              len1 = 14;
              code1 = 16'b0011_1111_1110_0000;
            end
            2: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_1101;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_1110;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1110_1111;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_0000;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_0001;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_0010;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        15: begin
          case(len2_d)
            0: begin
              len1 = 10; 
              code1 = 16'b0000_0011_1111_1010;
            end
            1: begin
              len1 = 15;
              code1 = 16'b0111_1111_1100_0011;
            end
            2: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_0110;
            end
            3: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_0111;
            end
            4: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_1000;
            end
            5: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_1001;
            end
            6: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_1010;
            end
            7: begin
              len1 = 16;
              code1 = 16'b1111_1111_1111_1011;
            end
            default: begin
              len1 = 0;
              code1 = 0;
            end
          endcase
        end
        default: begin
          len1 = 0;
          code1 = 0;
        end
      endcase
    end
    else begin
      len1 = 0;
      code1 = 0;
    end
  end

  out_nx = (code1_d <<< len2_d2) + code2_d2;
  if (ENCO_en && (dc_en_d2 || ac_en_d2)) bit_valid_nx = len1_d + len2_d2;
  else bit_valid_nx = 0;
end
endmodule


