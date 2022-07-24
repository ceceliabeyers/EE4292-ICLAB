module qr_demask(
input [5:0] cnt,
input [2:0] mask_pat,
output reg [7:0] out
);

always@* begin
    case(cnt)
        0: begin
            case(mask_pat)
                3'b000: out = 8'b10011001;
                3'b001: out = 8'b11001100;
                3'b010: out = 8'b10101010;
                3'b011: out = 8'b10000110;
                3'b100: out = 8'b10010110;
                3'b101: out = 8'b11101010;
                3'b110: out = 8'b11111110;
                3'b111: out = 8'b10001001;
                default: out = 8'b0;
            endcase
	end
        1: begin
            case(mask_pat)
                3'b000: out = 8'b10011001;
                3'b001: out = 8'b11001100;
                3'b010: out = 8'b10101010;
                3'b011: out = 8'b00011000;
                3'b100: out = 8'b10010110;
                3'b101: out = 8'b10101110;
                3'b110: out = 8'b10101111;
                3'b111: out = 8'b11011000;
                default: out = 8'b0;
            endcase
	end
        2: begin
            case(mask_pat)
                3'b000: out = 8'b10011001;
                3'b001: out = 8'b11001100;
                3'b010: out = 8'b10101010;
                3'b011: out = 8'b01100001;
                3'b100: out = 8'b10010110;
                3'b101: out = 8'b10101010;
                3'b110: out = 8'b11101010;
                3'b111: out = 8'b10011101;
                default: out = 8'b0;
            endcase
	end
        3: begin
            case(mask_pat)
                3'b000: out = 8'b10011001;
                3'b001: out = 8'b11001100;
                3'b010: out = 8'b10101010;
                3'b011: out = 8'b10000110;
                3'b100: out = 8'b10010110;
                3'b101: out = 8'b11101010;
                3'b110: out = 8'b11111110;
                3'b111: out = 8'b10001001;
                default: out = 8'b0;
            endcase
	end
        4: begin
            case(mask_pat)
                3'b000: out = 8'b01100110;
                3'b001: out = 8'b00110011;
                3'b010: out = 8'b01010101;
                3'b011: out = 8'b01001001;
                3'b100: out = 8'b00111100;
                3'b101: out = 8'b10010011;
                3'b110: out = 8'b10011011;
                3'b111: out = 8'b01000110;
                default: out = 8'b0;
            endcase
	end
        5: begin
            case(mask_pat)
                3'b000: out = 8'b01100110;
                3'b001: out = 8'b00110011;
                3'b010: out = 8'b01010101;
                3'b011: out = 8'b00100100;
                3'b100: out = 8'b00111100;
                3'b101: out = 8'b00011001;
                3'b110: out = 8'b00111001;
                3'b111: out = 8'b11100100;
                default: out = 8'b0;
            endcase
	end
        6: begin
            case(mask_pat)
                3'b000: out = 8'b01100110;
                3'b001: out = 8'b00110011;
                3'b010: out = 8'b01010101;
                3'b011: out = 8'b10010010;
                3'b100: out = 8'b00111100;
                3'b101: out = 8'b00110001;
                3'b110: out = 8'b10110011;
                3'b111: out = 8'b01101110;
                default: out = 8'b0;
            endcase
	end
        7: begin
            case(mask_pat)
                3'b000: out = 8'b01100110;
                3'b001: out = 8'b00110011;
                3'b010: out = 8'b01010101;
                3'b011: out = 8'b01001001;
                3'b100: out = 8'b00111100;
                3'b101: out = 8'b10010011;
                3'b110: out = 8'b10011011;
                3'b111: out = 8'b01000110;
                default: out = 8'b0;
            endcase
	end
        8: begin
            case(mask_pat)
                3'b000: out = 8'b10011001;
                3'b001: out = 8'b11001100;
                3'b010: out = 8'b00000000;
                3'b011: out = 8'b00011000;
                3'b100: out = 8'b11000011;
                3'b101: out = 8'b11000010;
                3'b110: out = 8'b11001010;
                3'b111: out = 8'b10111101;
                default: out = 8'b0;
            endcase
	end
        9: begin
            case(mask_pat)
                3'b000: out = 8'b01100110;
                3'b001: out = 8'b00110011;
                3'b010: out = 8'b00000000;
                3'b011: out = 8'b00011000;
                3'b100: out = 8'b00001111;
                3'b101: out = 8'b10000011;
                3'b110: out = 8'b10011111;
                3'b111: out = 8'b01000010;
                default: out = 8'b0;
            endcase
	end
        10: begin
            case(mask_pat)
                3'b000: out = 8'b01100101;
                3'b001: out = 8'b00110000;
                3'b010: out = 8'b00000010;
                3'b011: out = 8'b01100010;
                3'b100: out = 8'b00001110;
                3'b101: out = 8'b00001010;
                3'b110: out = 8'b00101010;
                3'b111: out = 8'b11110101;
                default: out = 8'b0;
            endcase
	end
        11: begin
            case(mask_pat)
                3'b000: out = 8'b10011001;
                3'b001: out = 8'b11001100;
                3'b010: out = 8'b10101010;
                3'b011: out = 8'b01001001;
                3'b100: out = 8'b01011010;
                3'b101: out = 8'b10101110;
                3'b110: out = 8'b11111110;
                3'b111: out = 8'b10001001;
                default: out = 8'b0;
            endcase
	end
        12: begin
            case(mask_pat)
                3'b000: out = 8'b10010110;
                3'b001: out = 8'b11000011;
                3'b010: out = 8'b10101010;
                3'b011: out = 8'b00101001;
                3'b100: out = 8'b01011001;
                3'b101: out = 8'b10101010;
                3'b110: out = 8'b10101011;
                3'b111: out = 8'b11010110;
                default: out = 8'b0;
            endcase
	end
        13: begin
            case(mask_pat)
                3'b000: out = 8'b01101001;
                3'b001: out = 8'b00111100;
                3'b010: out = 8'b10100101;
                3'b011: out = 8'b00100110;
                3'b100: out = 8'b01100011;
                3'b101: out = 8'b10111100;
                3'b110: out = 8'b11111110;
                3'b111: out = 8'b00101001;
                default: out = 8'b0;
            endcase
	end
        14: begin
            case(mask_pat)
                3'b000: out = 8'b10010101;
                3'b001: out = 8'b11001010;
                3'b010: out = 8'b01011111;
                3'b011: out = 8'b00010010;
                3'b100: out = 8'b11000110;
                3'b101: out = 8'b01101010;
                3'b110: out = 8'b01101010;
                3'b111: out = 8'b00010101;
                default: out = 8'b0;
            endcase
	end
        15: begin
            case(mask_pat)
                3'b000: out = 8'b00110011;
                3'b001: out = 8'b10011001;
                3'b010: out = 8'b10101010;
                3'b011: out = 8'b00110000;
                3'b100: out = 8'b01111000;
                3'b101: out = 8'b11001001;
                3'b110: out = 8'b11011001;
                3'b111: out = 8'b00110111;
                default: out = 8'b0;
            endcase
	end
        16: begin
            case(mask_pat)
                3'b000: out = 8'b00110011;
                3'b001: out = 8'b10011001;
                3'b010: out = 8'b10101010;
                3'b011: out = 8'b11000011;
                3'b100: out = 8'b01111000;
                3'b101: out = 8'b10001100;
                3'b110: out = 8'b11001101;
                3'b111: out = 8'b00100011;
                default: out = 8'b0;
            endcase
	end
        17: begin
            case(mask_pat)
                3'b000: out = 8'b00101100;
                3'b001: out = 8'b10000110;
                3'b010: out = 8'b10101010;
                3'b011: out = 8'b00010000;
                3'b100: out = 8'b01100001;
                3'b101: out = 8'b10000011;
                3'b110: out = 8'b10010011;
                3'b111: out = 8'b01101000;
                default: out = 8'b0;
            endcase
	end
        18: begin
            case(mask_pat)
                3'b000: out = 8'b11001101;
                3'b001: out = 8'b01100111;
                3'b010: out = 8'b10101010;
                3'b011: out = 8'b11000010;
                3'b100: out = 8'b11100001;
                3'b101: out = 8'b00100111;
                3'b110: out = 8'b01100111;
                3'b111: out = 8'b11011101;
                default: out = 8'b0;
            endcase
	end
        19: begin
            case(mask_pat)
                3'b000: out = 8'b00110011;
                3'b001: out = 8'b10011001;
                3'b010: out = 8'b00000000;
                3'b011: out = 8'b01001001;
                3'b100: out = 8'b11100001;
                3'b101: out = 8'b10000100;
                3'b110: out = 8'b11101101;
                3'b111: out = 8'b00000011;
                default: out = 8'b0;
            endcase
	end
        20: begin
            case(mask_pat)
                3'b000: out = 8'b00101100;
                3'b001: out = 8'b10000110;
                3'b010: out = 8'b00000000;
                3'b011: out = 8'b00110010;
                3'b100: out = 8'b11100111;
                3'b101: out = 8'b00000001;
                3'b110: out = 8'b00011011;
                3'b111: out = 8'b11100000;
                default: out = 8'b0;
            endcase
	end
        21: begin
            case(mask_pat)
                3'b000: out = 8'b11001100;
                3'b001: out = 8'b01100110;
                3'b010: out = 8'b00000000;
                3'b011: out = 8'b01001001;
                3'b100: out = 8'b10000111;
                3'b101: out = 8'b00000110;
                3'b110: out = 8'b01000111;
                3'b111: out = 8'b11111100;
                default: out = 8'b0;
            endcase
	end
        22: begin
            case(mask_pat)
                3'b000: out = 8'b11001100;
                3'b001: out = 8'b01100110;
                3'b010: out = 8'b00000000;
                3'b011: out = 8'b00100100;
                3'b100: out = 8'b10000111;
                3'b101: out = 8'b00010000;
                3'b110: out = 8'b10110100;
                3'b111: out = 8'b00001111;
                default: out = 8'b0;
            endcase
	end
        23: begin
            case(mask_pat)
                3'b000: out = 8'b11001100;
                3'b001: out = 8'b01100110;
                3'b010: out = 8'b00000000;
                3'b011: out = 8'b10010010;
                3'b100: out = 8'b10000111;
                3'b101: out = 8'b01100001;
                3'b110: out = 8'b01111011;
                3'b111: out = 8'b11000000;
                default: out = 8'b0;
            endcase
	end
        24: begin
            case(mask_pat)
                3'b000: out = 8'b11001101;
                3'b001: out = 8'b01100111;
                3'b010: out = 8'b00000001;
                3'b011: out = 8'b01001001;
                3'b100: out = 8'b10000111;
                3'b101: out = 8'b00000111;
                3'b110: out = 8'b01000111;
                3'b111: out = 8'b11111101;
                default: out = 8'b0;
            endcase
	end
        25: begin
            case(mask_pat)
                3'b000: out = 8'b00110011;
                3'b001: out = 8'b10011001;
                3'b010: out = 8'b01010101;
                3'b011: out = 8'b00001100;
                3'b100: out = 8'b00101101;
                3'b101: out = 8'b11010101;
                3'b110: out = 8'b11111101;
                3'b111: out = 8'b00010011;
                default: out = 8'b0;
            endcase
	end
        26: begin
            case(mask_pat)
                3'b000: out = 8'b00110011;
                3'b001: out = 8'b10011001;
                3'b010: out = 8'b01010101;
                3'b011: out = 8'b00110000;
                3'b100: out = 8'b00101101;
                3'b101: out = 8'b01011101;
                3'b110: out = 8'b01011111;
                3'b111: out = 8'b10110001;
                default: out = 8'b0;
            endcase
	end
        27: begin
            case(mask_pat)
                3'b000: out = 8'b00110011;
                3'b001: out = 8'b10011001;
                3'b010: out = 8'b01010101;
                3'b011: out = 8'b11000011;
                3'b100: out = 8'b00101101;
                3'b101: out = 8'b01010101;
                3'b110: out = 8'b11010101;
                3'b111: out = 8'b00111011;
                default: out = 8'b0;
            endcase
	end
        28: begin
            case(mask_pat)
                3'b000: out = 8'b00110011;
                3'b001: out = 8'b10011001;
                3'b010: out = 8'b01010101;
                3'b011: out = 8'b00001100;
                3'b100: out = 8'b00101101;
                3'b101: out = 8'b11010101;
                3'b110: out = 8'b11111101;
                3'b111: out = 8'b00010011;
                default: out = 8'b0;
            endcase
	end
        29: begin
            case(mask_pat)
                3'b000: out = 8'b00101100;
                3'b001: out = 8'b10000110;
                3'b010: out = 8'b01010101;
                3'b011: out = 8'b00100011;
                3'b100: out = 8'b00110100;
                3'b101: out = 8'b01010101;
                3'b110: out = 8'b01011111;
                3'b111: out = 8'b10100100;
                default: out = 8'b0;
            endcase
	end
        30: begin
            case(mask_pat)
                3'b000: out = 8'b11001101;
                3'b001: out = 8'b01100111;
                3'b010: out = 8'b01010100;
                3'b011: out = 8'b00001100;
                3'b100: out = 8'b10110100;
                3'b101: out = 8'b01010111;
                3'b110: out = 8'b01010111;
                3'b111: out = 8'b11101101;
                default: out = 8'b0;
            endcase
	end
        31: begin
            case(mask_pat)
                3'b000: out = 8'b00110011;
                3'b001: out = 8'b10011001;
                3'b010: out = 8'b10101010;
                3'b011: out = 8'b10010010;
                3'b100: out = 8'b00011110;
                3'b101: out = 8'b10001100;
                3'b110: out = 8'b10011100;
                3'b111: out = 8'b01110010;
                default: out = 8'b0;
            endcase
	end
        32: begin
            case(mask_pat)
                3'b000: out = 8'b00101100;
                3'b001: out = 8'b10000110;
                3'b010: out = 8'b10101010;
                3'b011: out = 8'b01000100;
                3'b100: out = 8'b00011000;
                3'b101: out = 8'b10000011;
                3'b110: out = 8'b11000111;
                3'b111: out = 8'b00111100;
                default: out = 8'b0;
            endcase
	end
        33: begin
            case(mask_pat)
                3'b000: out = 8'b11001100;
                3'b001: out = 8'b01100110;
                3'b010: out = 8'b10101010;
                3'b011: out = 8'b10010010;
                3'b100: out = 8'b01111000;
                3'b101: out = 8'b00100110;
                3'b110: out = 8'b00110110;
                3'b111: out = 8'b10001101;
                default: out = 8'b0;
            endcase
	end
        34: begin
            case(mask_pat)
                3'b000: out = 8'b11001100;
                3'b001: out = 8'b01100110;
                3'b010: out = 8'b10101010;
                3'b011: out = 8'b01001001;
                3'b100: out = 8'b01111000;
                3'b101: out = 8'b00110010;
                3'b110: out = 8'b01110011;
                3'b111: out = 8'b11001000;
                default: out = 8'b0;
            endcase
	end
        35: begin
            case(mask_pat)
                3'b000: out = 8'b11001100;
                3'b001: out = 8'b01100110;
                3'b010: out = 8'b10101010;
                3'b011: out = 8'b00100100;
                3'b100: out = 8'b01111000;
                3'b101: out = 8'b01100011;
                3'b110: out = 8'b01100111;
                3'b111: out = 8'b11011100;
                default: out = 8'b0;
            endcase
	end
        36: begin
            case(mask_pat)
                3'b000: out = 8'b11001101;
                3'b001: out = 8'b01100111;
                3'b010: out = 8'b10101010;
                3'b011: out = 8'b10010011;
                3'b100: out = 8'b01111001;
                3'b101: out = 8'b00100110;
                3'b110: out = 8'b00110111;
                3'b111: out = 8'b10001101;
                default: out = 8'b0;
            endcase
	end
        37: begin
            case(mask_pat)
                3'b000: out = 8'b00110011;
                3'b001: out = 8'b10011001;
                3'b010: out = 8'b00000000;
                3'b011: out = 8'b00001100;
                3'b100: out = 8'b10000111;
                3'b101: out = 8'b01000001;
                3'b110: out = 8'b01001111;
                3'b111: out = 8'b10100001;
                default: out = 8'b0;
            endcase
	end
        38: begin
            case(mask_pat)
                3'b000: out = 8'b00110011;
                3'b001: out = 8'b10011000;
                3'b010: out = 8'b00000000;
                3'b011: out = 8'b00110000;
                3'b100: out = 8'b10000110;
                3'b101: out = 8'b10000100;
                3'b110: out = 8'b10010100;
                3'b111: out = 8'b01111011;
                default: out = 8'b0;
            endcase
	end
        39: begin
            case(mask_pat)
                3'b000: out = 8'b00110011;
                3'b001: out = 8'b01100110;
                3'b010: out = 8'b00000000;
                3'b011: out = 8'b01001001;
                3'b100: out = 8'b01111000;
                3'b101: out = 8'b10000110;
                3'b110: out = 8'b11011110;
                3'b111: out = 8'b00000011;
                default: out = 8'b0;
            endcase
	end
        40: begin
            case(mask_pat)
                3'b000: out = 8'b00110010;
                3'b001: out = 8'b01100111;
                3'b010: out = 8'b00000001;
                3'b011: out = 8'b00100100;
                3'b100: out = 8'b01111000;
                3'b101: out = 8'b00001001;
                3'b110: out = 8'b00101101;
                3'b111: out = 8'b11110000;
                default: out = 8'b0;
            endcase
	end
        41: begin
            case(mask_pat)
                3'b000: out = 8'b11001100;
                3'b001: out = 8'b10011001;
                3'b010: out = 8'b01010101;
                3'b011: out = 8'b11000011;
                3'b100: out = 8'b11010010;
                3'b101: out = 8'b00110001;
                3'b110: out = 8'b10110011;
                3'b111: out = 8'b11000100;
                default: out = 8'b0;
            endcase
	end
        42: begin
            case(mask_pat)
                3'b000: out = 8'b11001101;
                3'b001: out = 8'b10011000;
                3'b010: out = 8'b01010100;
                3'b011: out = 8'b00001100;
                3'b100: out = 8'b11010011;
                3'b101: out = 8'b10010010;
                3'b110: out = 8'b10011010;
                3'b111: out = 8'b11101101;
                default: out = 8'b0;
            endcase
	end
        43: begin
            case(mask_pat)
                3'b000: out = 8'b00110011;
                3'b001: out = 8'b01100110;
                3'b010: out = 8'b10101010;
                3'b011: out = 8'b10010010;
                3'b100: out = 8'b10000111;
                3'b101: out = 8'b10101110;
                3'b110: out = 8'b10101111;
                3'b111: out = 8'b01110010;
                default: out = 8'b0;
            endcase
	end
	default: out = 8'b0;
    endcase
end
endmodule
