module rgb2yuv
#(
parameter ACT_PER_ADDR = 1,
parameter IN_WIDTH     = 8
)
(
input clk,
input [1:0] mode,  // to choose the output amoung Y, U and V, 2: out = Y, 1: out = U, 0: out = V
input [ACT_PER_ADDR*IN_WIDTH-1:0] R,  // input pixel R, unsigned
input [ACT_PER_ADDR*IN_WIDTH-1:0] G,  // input pixel G, unsigned
input [ACT_PER_ADDR*IN_WIDTH-1:0] B,  // input pixel B, unsigned
input pad_en,

output reg signed [ACT_PER_ADDR*IN_WIDTH-1:0] out  // output pixel, signed
);

// Y =  0.299R + 0.587G + 0.114B
// U = -0.168R - 0.331G + 0.499B
// V =  0.500R - 0.419G - 0.081B
reg signed [ACT_PER_ADDR*IN_WIDTH+9:0] out_tmp, out_tmp0, out_tmp1, out_add, out_addd, out_adddd;
reg signed [ACT_PER_ADDR*IN_WIDTH+8:0] out_tmp00, out_tmp11, out_tmp22;
reg signed [8:0] _r, _g, _b;
reg signed [8:0] f_r, f_g, f_b;
reg signed [ACT_PER_ADDR*IN_WIDTH-1:0] in_R, in_G, in_B;


always @* begin
  case (mode) // synopsys parallel_case
    2'b10: begin  // out = Y
      _r = 9'b001001101;  // 0.299 (0.30078125)
      _g = 9'b010010110;  // 0.587 (0.5859375)
      _b = 9'b000011101;  // 0.114 (0.11328125)
      out_add = -128 * 255;
    end
    2'b01: begin  // out = U
      _r = 9'b111010101;  // -0.168 (-0.16796875)
      _g = 9'b110101011;  // -0.331 (-0.33203125)
      _b = 9'b010000000;  //  0.499 (0.5)
      out_add = 128;
    end 
    2'b00: begin  // out = V
      _r = 9'b010000000;  //  0.500 (0.5)
      _g = 9'b110010101;  // -0.419 (-0.41796875)
      _b = 9'b111101011;  // -0.081 (-0.08203125)
      out_add = 128;
    end 
    default: begin
      _r = 9'b000000000;
      _g = 9'b000000000;
      _b = 9'b000000000;
      out_add = 0;
    end  
  endcase
end

always @* begin
  out_tmp = out_tmp0 + out_tmp1;
end

always @(posedge clk)
begin
  f_r <= _r;
  f_g <= _g;
  f_b <= _b;
  in_R <= ((pad_en) ? 0 : R);
  in_G <= ((pad_en) ? 0 : G);
  in_B <= ((pad_en) ? 0 : B);
  out_addd <= out_add;
  out_adddd <= out_addd;
  out_tmp00 <= f_r * $signed({1'b0, in_R});
  out_tmp11 <= f_g * $signed({1'b0, in_G});
  out_tmp22 <= f_b * $signed({1'b0, in_B});
end

always @(posedge clk) begin
  out_tmp0 <= out_tmp00 + out_tmp11;
  out_tmp1 <= out_tmp22 + out_adddd;
  out      <= out_tmp[ACT_PER_ADDR*IN_WIDTH+7 -: 8];
end

endmodule
