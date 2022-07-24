module decoder #(
parameter SRAM_ADDR_R = 22,
parameter REG_WIDTH = 12
)
(
input clk,
input rst_n,
input en,
input [23-1:0] in,
input mode,
input clear,
output reg [SRAM_ADDR_R-1:0] sram_raddr,
output reg reg_wen,
output reg [4:0] zcnt1,
output reg [2:0] zcnt2,
output reg [REG_WIDTH-1:0] out,
output reg finish
);

localparam IDLE = 3'd0, DC = 3'd1, AC = 3'd2, WAIT1 = 3'd3, WAIT2 = 3'd4, EMPTY = 3'd5, EMPTY2 = 3'd6, WAIT3 = 3'd7;

reg [3:0] zero_len2, zero_len3, zero_len4, zero_len5, zero_len6, zero_len7, zero_len8, zero_len9, zero_len10, zero_len11, zero_len12, zero_len14, zero_len15, zero_len16;
reg [3:0] size2, size3, size4, size5, size6, size7, size8, size9, size10, size11, size12, size14, size15, size16;
reg [3:0] zero_len, zero_len_d;
reg [3:0] size;
reg [3:0] size_d;
reg signed [8:0] offset;
reg signed [8:0] offset_d;
reg signed [8:0] base;
reg signed [8:0] base_d;
reg signed [8:0] non0_value/*, non0_value_d*/; 

reg [SRAM_ADDR_R-1:0] sram_raddr_nx;
reg reg_wen_nx;
reg [REG_WIDTH-1:0] out_nx;

reg [4:0] zcnt1_nx;
reg [2:0] zcnt2_nx;
reg [3:0] cnt_0, cnt_0_nx;
reg [5:0] cnt, cnt_nx;
reg finish_nx;

reg signed [8:0] pre_dc, n_dc; 

reg [2:0] state, state_nx;

always@(posedge clk) begin
	if(~rst_n) begin
		zcnt1 <= 0;
		zcnt2 <= 0;
		reg_wen <= 1;
		cnt_0 <= 0;
		state <= IDLE;
		sram_raddr <= 0;
		cnt <= 0;
		pre_dc <= 0;
	end
	else begin
		zcnt1 <= zcnt1_nx;
		zcnt2 <= zcnt2_nx;
		reg_wen <= reg_wen_nx;
		cnt_0 <= cnt_0_nx;
		state <= state_nx;
		sram_raddr <= sram_raddr_nx;
		cnt <= cnt_nx;
                pre_dc <= clear ? 0 : n_dc;
	end
  out <= out_nx;
  finish <= finish_nx;
  zero_len_d <= zero_len;
//  non0_value_d <= non0_value; 
 offset_d <= offset;
 base_d <= base;
 size_d <= size;
end

always@* begin
	case(state)
		IDLE: begin
			if(cnt == 63) state_nx = IDLE;
			else state_nx = en ? DC : IDLE;
		end
		DC: begin
			if(cnt_0 == 2) begin
				state_nx = EMPTY2; //AC
			end
			else begin
				state_nx = DC;
			end
		end
		AC: begin
			if(cnt == 63) begin
				state_nx = EMPTY;
			end
			else begin
				if(zero_len_d == 0) begin
					if(non0_value == 0) begin
						if(cnt == 63) state_nx = EMPTY;
						else state_nx = AC;
					end
					else begin
						state_nx = WAIT2;
					end
				end
				else if(zero_len_d == 1) begin
					state_nx = WAIT1;
				end
				else if(zero_len_d == 2) begin
					state_nx = WAIT3;
				end
				else begin
					//if(cnt == 63) state_nx = EMPTY;
					//else state_nx = AC;	
					state_nx = AC;
				end	
			end
		end
		WAIT1: begin
			if(cnt == 63 && cnt_0 == 1) begin
				state_nx = EMPTY;
			end
			else begin
				if(cnt_0 == 1) begin
					state_nx = EMPTY2; //AC
				end
				else begin
					state_nx = WAIT1;
				end
			end
		end
		WAIT2: begin
			if(cnt == 63 && cnt_0 == 1) begin
				state_nx = IDLE;
			end
			else begin
				if(cnt_0 == 1) begin
					state_nx = EMPTY2; //AC
				end
				else begin
					state_nx = WAIT2;
				end
			end
		end
		WAIT3: begin
			if(cnt == 63 && cnt_0 == 2) begin//1
				state_nx = EMPTY;
			end
			else begin
				if(cnt_0 == 2) begin//1
					state_nx = EMPTY2; //AC
				end
				else begin
					state_nx = WAIT3;
				end
			end
		end
		EMPTY: begin
			if(!en) state_nx = IDLE;
			else state_nx = EMPTY;
		end
		EMPTY2: begin
		        state_nx = AC;
		end
		default: state_nx = state;
	endcase
end

always@* begin
	case(state)
		IDLE: begin
			sram_raddr_nx = sram_raddr;
			out_nx = non0_value;
			zcnt1_nx = 0;
			zcnt2_nx = 0;
			reg_wen_nx = 1;
			cnt_0_nx = 0;
			cnt_nx = 0;
			n_dc = pre_dc;
		end
		DC: begin
			if(cnt_0 == 0) sram_raddr_nx = sram_raddr + 1;
			else sram_raddr_nx = sram_raddr;
			out_nx = non0_value + pre_dc;
			zcnt1_nx = zcnt1;
			zcnt2_nx = zcnt2;
			if(cnt_0 == 2) reg_wen_nx = 0;
			else reg_wen_nx = 1;
			if(cnt_0 != 2) cnt_0_nx = cnt_0 + 1;
			else cnt_0_nx = 0;
			cnt_nx = 0;
			if(cnt_0 == 2) n_dc = out;
			else n_dc = pre_dc;
		end
		AC: begin
			n_dc = pre_dc;
			case(zero_len_d)
				0: begin
					if(non0_value == 0) begin
						if(cnt == 63) sram_raddr_nx = sram_raddr + 1;
						else sram_raddr_nx = sram_raddr;
                                	end
					else sram_raddr_nx = sram_raddr + 1;
				end
				1: begin
					sram_raddr_nx = sram_raddr + 1;
				end
				2: begin
					sram_raddr_nx = sram_raddr + 1;
				end
				default: begin
					if(non0_value == 0) begin
						if(cnt_0 == zero_len_d - 4) sram_raddr_nx = sram_raddr + 1;
						else sram_raddr_nx = sram_raddr;
					end
					else begin
						if(cnt_0 == zero_len_d - 3 && cnt - cnt_0 + zero_len_d != 62 || cnt == 63) sram_raddr_nx = sram_raddr + 1;
						else sram_raddr_nx = sram_raddr;
					end
				end
			endcase
			if(zero_len_d == 0) begin
				if(non0_value == 0) out_nx = 0;
				else out_nx = non0_value;
			end
			else begin
				if(cnt_0 == zero_len_d) out_nx = non0_value;
				else out_nx = 0;
			end
			if (zcnt2 == 7 && zcnt1 > 6) begin
        			zcnt2_nx = zcnt1 - 6;
      	  			zcnt1_nx = zcnt1 + 1;
     			end
      			else if(zcnt2 == zcnt1[2:0] && zcnt1 <= 6) begin
        			zcnt2_nx = 0;
        			zcnt1_nx = zcnt1 + 1;
      			end
      			else begin
        			zcnt2_nx = zcnt2 + 1;
        			zcnt1_nx = zcnt1;
      			end
			
			if(cnt != 63) reg_wen_nx = 0;
			else reg_wen_nx = 1;

			case(zero_len_d) 
				0: begin
					cnt_0_nx = 0;
				end
				1: begin
					cnt_0_nx = 0;
				end
				2: begin
					cnt_0_nx = 0;
				end
				default: begin
					if(non0_value == 0) begin
						if(cnt_0 == zero_len_d - 1) cnt_0_nx = 0;
						else cnt_0_nx = cnt_0 + 1;
					end
					else begin
						if(cnt_0 == zero_len_d) cnt_0_nx = 0;
						else cnt_0_nx = cnt_0 + 1;
					end
				end
			endcase
			cnt_nx = cnt + 1;
		end
		WAIT1: begin
			n_dc = pre_dc;
			sram_raddr_nx = sram_raddr;
			out_nx = non0_value;
			if(cnt_0 == 0) begin
				if (zcnt2 == 7 && zcnt1 > 6) begin
        				zcnt2_nx = zcnt1 - 6;
      		  			zcnt1_nx = zcnt1 + 1;
    	 			end
      				else if(zcnt2 == zcnt1[2:0] && zcnt1 <= 6) begin
        				zcnt2_nx = 0;
        				zcnt1_nx = zcnt1 + 1;
     	 			end
      				else begin
        				zcnt2_nx = zcnt2 + 1;
        				zcnt1_nx = zcnt1;
      				end
			end
			else begin
				zcnt1_nx = zcnt1;
				zcnt2_nx = zcnt2;
			end

			if(cnt_0 == 0) reg_wen_nx = 0;
			else reg_wen_nx = 1;

			if(cnt_0 != 1) cnt_0_nx = cnt_0 + 1;
			else cnt_0_nx = 0;
			
			if(cnt_0 == 0) cnt_nx = cnt + 1;
			else cnt_nx = cnt;
		end
		WAIT2: begin
			n_dc = pre_dc;
			sram_raddr_nx = sram_raddr;
			out_nx = non0_value;
			zcnt1_nx = zcnt1;
			zcnt2_nx = zcnt2;
			reg_wen_nx = 1;
			if(cnt_0 != 1) cnt_0_nx = cnt_0 + 1;
			else cnt_0_nx = 0;
			cnt_nx = cnt;
		end
		WAIT3: begin
			n_dc = pre_dc;
			sram_raddr_nx = sram_raddr;
			if(cnt_0 == 0) out_nx = 0;
			else out_nx = non0_value;
			if(cnt_0 == 0 || cnt_0 == 1) begin
				if (zcnt2 == 7 && zcnt1 > 6) begin
        				zcnt2_nx = zcnt1 - 6;
      		  			zcnt1_nx = zcnt1 + 1;
    	 			end
      				else if(zcnt2 == zcnt1[2:0] && zcnt1 <= 6) begin
        				zcnt2_nx = 0;
        				zcnt1_nx = zcnt1 + 1;
     	 			end
      				else begin
        				zcnt2_nx = zcnt2 + 1;
        				zcnt1_nx = zcnt1;
      				end
			end
			else begin
				zcnt1_nx = zcnt1;
				zcnt2_nx = zcnt2;
			end

			if(cnt_0 == 0 || cnt_0 == 1) reg_wen_nx = 0;
			else reg_wen_nx = 1;

			if(cnt_0 != 2) cnt_0_nx = cnt_0 + 1;//1
			else cnt_0_nx = 0;
			
			if(cnt_0 == 0 || cnt_0 == 1) cnt_nx = cnt + 1;
			else cnt_nx = cnt;
		end
		EMPTY2: begin
			n_dc = pre_dc;
			sram_raddr_nx = sram_raddr;
			out_nx = non0_value;
			zcnt1_nx = zcnt1;
			zcnt2_nx = zcnt2;
			reg_wen_nx = 1;
			cnt_0_nx = cnt_0;
			cnt_nx = cnt;
		end
		default: begin
			n_dc = pre_dc;
			sram_raddr_nx = sram_raddr;
			out_nx = non0_value;
			zcnt1_nx = 0;
			zcnt2_nx = 0;
			reg_wen_nx = 1;
			cnt_0_nx = 0;
			cnt_nx = cnt;
		end
	endcase
end

always@* begin
	if(cnt == 63) finish_nx = 1;
	else finish_nx = 0;
end

always@* begin
	if(offset_d[size_d-1]) non0_value = offset_d;
	else non0_value = offset_d + base_d;
end

// decode
always@* begin
	if(mode) begin
		if(state == DC) begin
	    zero_len = 0;
			if(size2 != 15) begin
				size = size2;
				offset = 0;
				base = 0;
			end
			else if(size3 != 15) begin
				size = size3;
				case(size)
					1: begin
						offset = in[19];
						base = -1;
					end
					2: begin
						offset = in[19:18];
						base = -3;
					end
					3: begin
						offset = in[19:17];
						base = -7;
					end
					4: begin
						offset = in[19:16];
						base = -15;
					end
					5: begin
						offset = in[19:15];
						base = -31;
					end
					default: begin 
						offset = 0;
						base = 0;
					end
				endcase
			end
			else if(size4 != 15) begin
				size = size4;
				case(size)
					6: begin
						offset = in[18:13];
						base = -63;
					end
					default: begin 
						offset = 0;
						base = 0;
					end
				endcase
			end
			else if(size5 != 15) begin
				size = size5;
				case(size)
					7: begin
						offset = in[17:11];
						base = -127;
					end
					default: begin 
						offset = 0;
						base = 0;
					end
				endcase
			end
			else begin
				size = size6;
				case(size)
					8: begin
						offset = in[16:9];
						base = -255;
					end
					default: begin 
						offset = 0;
						base = 0;
					end
				endcase
			end
		end
		else begin
			if(size2 != 15) begin
			  zero_len = zero_len2;
			  size = size2;
			  case(size)
			    1: begin
						offset = in[20];
			      base = -1;
					end
			    2: begin 
						offset = in[20:19];
						base = -3;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size3 != 15) begin
			  zero_len = zero_len3;
			  size = size3;
			  case(size)
			    3: begin
						offset = in[19:17];
			      base = -7;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size4 != 15) begin
			  zero_len = zero_len4;
			  size = size4;
			  case(size)
			    1: begin
						offset = in[18];
			      base = -1;
					end
			    4: begin 
						offset = in[18:15];
						base = -15;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size5 != 15) begin
			  zero_len = zero_len5;
			  size = size5;
			  case(size)
			    1: begin
						offset = in[17];
			      base = -1;
					end
			    2: begin 
						offset = in[17:16];
						base = -3;
					end
			    5: begin 
						offset = in[17:13];
						base = -31;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size6 != 15) begin
			  zero_len = zero_len6;
			  size = size6;
			  case(size)
			    1: begin
						offset = in[16];
			      base = -1;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size7 != 15) begin
			  zero_len = zero_len7;
			  size = size7;
			  case(size)
			    1: begin
						offset = in[15];
			      base = -1;
					end
			    3: begin 
						offset = in[15:13];
						base = -7;
					end
			    6: begin 
						offset = in[15:10];
						base = -63;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size8 != 15) begin
			  zero_len = zero_len8;
			  size = size8;
			  case(size)
			    1: begin
						offset = in[14];
			      base = -1;
					end
			    2: begin 
						offset = in[14:13];
						base = -3;
					end
			    7: begin 
						offset = in[14:8];
						base = -127;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size9 != 15) begin
			  zero_len = zero_len9;
			  size = size9;
			  case(size)
			    1: begin
						offset = in[13];
			      base = -1;
					end
			    2: begin 
						offset = in[13:12];
						base = -3;
					end
			    4: begin 
						offset = in[13:10];
						base = -15;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size10 != 15) begin
			  zero_len = zero_len10;
			  size = size10;
			  case(size)
			    1: begin
						offset = in[12];
			      base = -1;
					end
			    2: begin 
						offset = in[12:11];
						base = -3;
					end
			    3: begin 
						offset = in[12:10];
						base = -7;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size11 != 15) begin
			  zero_len = zero_len11;
			  size = size11;
			  case(size)
			    1: begin
						offset = in[11];
			      base = -1;
					end
			    2: begin 
						offset = in[11:10];
						base = -3;
					end
			    5: begin 
						offset = in[11:7];
						base = -31;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size12 != 15) begin
			  zero_len = zero_len12;
			  size = size12;
			  case(size)
			    2: begin
						offset = in[10:9];
			      base = -3;
					end
			    3: begin 
						offset = in[10:8];
						base = -7;
					end
			    4: begin 
						offset = in[10:7];
						base = -15;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size15 != 15) begin
			  zero_len = zero_len15;
			  size = size15;
			  case(size)
			    2: begin
						offset = in[7:6];
			      base = -3;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else begin
			  zero_len = zero_len16;
			  size = size16;
			  case(size)
			    1: begin
						offset = in[6];
			      base = -1;
					end
			    2: begin
						offset = in[6:5];
			      base = -3;
					end
			    3: begin
						offset = in[6:4];
			      base = -7;
					end
			    4: begin
						offset = in[6:3];
			      base = -15;
					end
			    5: begin
						offset = in[6:2];
			      base = -31;
					end
			    6: begin
						offset = in[6:1];
			      base = -63;
					end
			    7: begin
						offset = in[6:0];
			      base = -127;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
		end
	end
	else begin
		if(state == DC) begin
	    zero_len = 0;
			if(size2 != 15) begin
				size = size2;
				case(size)
					1: begin
						offset = in[20];
						base = -1;
					end
					2: begin
						offset = in[20:19];
						base = -3;
					end
					default: begin 
						offset = 0;
						base = 0;
					end
				endcase
			end
			else if(size3 != 15) begin
				size = size3;
				case(size)
					3: begin
						offset = in[19:17];
						base = -7;
					end
					default: begin 
						offset = 0;
						base = 0;
					end
				endcase
			end
			else if(size4 != 15) begin
				size = size4;
				case(size)
					4: begin
						offset = in[18:15];
						base = -15;
					end
					default: begin 
						offset = 0;
						base = 0;
					end
				endcase
			end
			else if(size5 != 15) begin
				size = size5;
				case(size)
					5: begin
						offset = in[17:13];
						base = -31;
					end
					default: begin 
						offset = 0;
						base = 0;
					end
				endcase
			end
			else if(size6 != 15) begin
				size = size6;
				case(size)
					6: begin
						offset = in[16:11];
						base = -63;
					end
					default: begin 
						offset = 0;
						base = 0;
					end
				endcase
			end
			else if(size7 != 15) begin
				size = size7;
				case(size)
					7: begin
						offset = in[15:9];
						base = -127;
					end
					default: begin 
						offset = 0;
						base = 0;
					end
				endcase
			end
			else begin
				size = size8;
				case(size)
					8: begin
						offset = in[14:7];
						base = -255;
					end
					default: begin 
						offset = 0;
						base = 0;
					end
				endcase
			end
		end
		else begin
			if(size2 != 15) begin
			  zero_len = zero_len2;
			  size = size2;
			  case(size)
			    1: begin
						offset = in[20];
			      base = -1;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size3 != 15) begin
			  zero_len = zero_len3;
			  size = size3;
			  case(size)
			    2: begin
						offset = in[19:18];
			      base = -3;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size4 != 15) begin
			  zero_len = zero_len4;
			  size = size4;
			  case(size)
			    1: begin
						offset = in[18];
			      base = -1;
					end
			    3: begin 
						offset = in[18:16];
						base = -7;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size5 != 15) begin
			  zero_len = zero_len5;
			  size = size5;
			  case(size)
			    1: begin
						offset = in[17];
			      base = -1;
					end
			    4: begin 
						offset = in[17:14];
						base = -15;
					end
			    5: begin 
						offset = in[17:13];
						base = -31;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size6 != 15) begin
			  zero_len = zero_len6;
			  size = size6;
			  case(size)
			    1: begin
						offset = in[16];
			      base = -1;
					end
			    2: begin
						offset = in[16:15];
			      base = -3;
					end
			    6: begin
						offset = in[16:11];
			      base = -63;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size7 != 15) begin
			  zero_len = zero_len7;
			  size = size7;
			  case(size)
			    1: begin
						offset = in[15];
			      base = -1;
					end
			    7: begin 
						offset = in[15:9];
						base = -127;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size8 != 15) begin
			  zero_len = zero_len8;
			  size = size8;
			  case(size)
			    1: begin
						offset = in[14];
			      base = -1;
					end
			    2: begin 
						offset = in[14:13];
						base = -3;
					end
			    3: begin 
						offset = in[14:12];
						base = -7;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size9 != 15) begin
			  zero_len = zero_len9;
			  size = size9;
			  case(size)
			    1: begin
						offset = in[13];
			      base = -1;
					end
			    2: begin 
						offset = in[13:12];
						base = -3;
					end
			    4: begin 
						offset = in[13:10];
						base = -15;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size10 != 15) begin
			  zero_len = zero_len10;
			  size = size10;
			  case(size)
			    2: begin 
						offset = in[12:11];
						base = -3;
					end
			    3: begin 
						offset = in[12:10];
						base = -7;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size11 != 15) begin
			  zero_len = zero_len11;
			  size = size11;
			  case(size)
			    1: begin
						offset = in[11];
			      base = -1;
					end
			    2: begin 
						offset = in[11:10];
						base = -3;
					end
			    5: begin 
						offset = in[11:7];
						base = -31;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size12 != 15) begin
			  zero_len = zero_len12;
			  size = size12;
			  case(size)
			    6: begin
						offset = in[10:5];
			      base = -63;
					end
			    4: begin 
						offset = in[10:7];
						base = -15;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size14 != 15) begin
			  zero_len = zero_len14;
			  size = size14;
			  case(size)
			    1: begin
						offset = in[8];
			      base = -1;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else if(size15 != 15) begin
			  zero_len = zero_len15;
			  size = size15;
			  case(size)
			    1: begin
						offset = in[7];
			      base = -1;
					end
			    5: begin
						offset = in[7:3];
			      base = -31;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
			else begin
			  zero_len = zero_len16;
			  size = size16;
			  case(size)
			    2: begin
						offset = in[6:5];
			      base = -3;
					end
			    3: begin
						offset = in[6:4];
			      base = -7;
					end
			    4: begin
						offset = in[6:3];
			      base = -15;
					end
			    5: begin
						offset = in[6:2];
			      base = -31;
					end
			    6: begin
						offset = in[6:1];
			      base = -63;
					end
			    7: begin
						offset = in[6:0];
			      base = -127;
					end
			    default: begin 
						offset = 0;
						base = 0;
					end
			  endcase
			end
		end
	end
end

always@* begin
	if(mode) begin
		if(state == DC) begin
			zero_len2 = 0; zero_len3 = 0; zero_len4 = 0; zero_len5 = 0; zero_len6 = 0; zero_len7 = 0; zero_len8 = 0; zero_len9 = 0; zero_len10 = 0; zero_len11 = 0; 
	    zero_len12 = 0; zero_len14 = 0; zero_len15 = 0; zero_len16 = 0;
			size7 = 15; size8 = 15; size9 = 15; size10 = 15; size11 = 15; size12 = 15; size14 = 15; size15 = 15; size16 = 15;
			case(in[22:21]) //2
				2'b00: begin
					size2 = 0;
				end
				default: begin
					size2 = 15;
				end
			endcase
			case(in[22:20]) //3
				3'b010: begin
					size3 = 1;
				end
				3'b011: begin
					size3 = 2;
				end
				3'b100: begin
					size3 = 3;
				end
				3'b101: begin
					size3 = 4;
				end
				3'b110: begin
					size3 = 5;
				end
				default: begin
					size3 = 15;
				end
			endcase
			case(in[22:19]) //4
				4'b1110: begin
					size4 = 6;
				end
				default: begin
					size4 = 15;
				end
			endcase
			case(in[22:18]) //5
				5'b11110: begin
					size5 = 7;
				end
				default: begin
					size5 = 15;
				end
			endcase
			case(in[22:17]) //6
				6'b111110: begin
					size6 = 8;
				end
				default: begin
					size6 = 15;
				end
			endcase
		end
		else begin
			zero_len14 = 0; size14 = 15;
			case(in[22:21]) //2
			  2'b00: begin
			    zero_len2 = 0;
			    size2 = 1;
			  end
			  2'b01: begin
			    zero_len2 = 0;
			    size2 = 2;
			  end
			  default: begin
			    zero_len2 = 0;
			    size2 = 15;
			  end
			endcase
			case(in[22:20]) //3
			  3'b100: begin
			    zero_len3 = 0;
			    size3 = 3;
			  end
			  default: begin
			    zero_len3 = 0;
			    size3 = 15;
			  end
			endcase
			case(in[22:19]) //4
			  4'b1010: begin
			    zero_len4 = 0;
			    size4 = 0;
			  end
			  4'b1011: begin
			    zero_len4 = 0;
			    size4 = 4;
			  end
			  4'b1100: begin
			    zero_len4 = 1;
			    size4 = 1;
			  end
			  default: begin
			    zero_len4 = 0;
			    size4 = 15;
			  end
			endcase
			case(in[22:18]) //5
			  5'b11010: begin
			    zero_len5 = 0;
			    size5 = 5;
			  end
			  5'b11011: begin
			    zero_len5 = 1;
			    size5 = 2;
			  end
			  5'b11100: begin
			    zero_len5 = 2;
			    size5 = 1;
			  end
			  default: begin
			    zero_len5 = 0;
			    size5 = 15;
			  end
			endcase
			case(in[22:17]) //6
			  6'b111010: begin
			    zero_len6 = 3;
			    size6 = 1;
			  end
			  6'b111011: begin
			    zero_len6 = 4;
			    size6 = 1;
			  end
			  default: begin
			    zero_len6 = 0;
			    size6 = 15;
			  end
			endcase
			case(in[22:16]) //7
			  7'b1111000: begin
			    zero_len7 = 0;
			    size7 = 6;
			  end
			  7'b1111001: begin
			    zero_len7 = 1;
			    size7 = 3;
			  end
			  7'b1111010: begin
			    zero_len7 = 5;
			    size7 = 1;
			  end
			  7'b1111011: begin
			    zero_len7 = 6;
			    size7 = 1;
			  end
			  default: begin
			    zero_len7 = 0;
			    size7 = 15;
			  end
			endcase
			case(in[22:15]) //8
			  8'b11111000: begin
			    zero_len8 = 0;
			    size8 = 7;
			  end
			  8'b11111001: begin
			    zero_len8 = 2;
			    size8 = 2;
			  end
			  8'b11111010: begin
			    zero_len8 = 7;
			    size8 = 1;
			  end
			  default: begin
			    zero_len8 = 0;
			    size8 = 15;
			  end
			endcase
			case(in[22:14]) //9
			  9'b111110110: begin
			    zero_len9 = 1;
			    size9 = 4;
			  end
			  9'b111110111: begin
			    zero_len9 = 3;
			    size9 = 2;
			  end
			  9'b111111000: begin
			    zero_len9 = 8;
			    size9 = 1;
			  end
			  9'b111111001: begin
			    zero_len9 = 9;
			    size9 = 1;
			  end
			  9'b111111010: begin
			    zero_len9 = 10;
			    size9 = 1;
			  end
			  default: begin
			    zero_len9 = 0;
			    size9 = 15;
			  end
			endcase
			case(in[22:13]) //10
			  10'b1111110111: begin
			    zero_len10 = 2;
			    size10 = 3;
			  end
			  10'b1111111000: begin
			    zero_len10 = 4;
			    size10 = 2;
			  end
			  10'b1111111001: begin
			    zero_len10 = 11;
			    size10 = 1;
			  end
			  10'b1111111010: begin
			    zero_len10 = 12;
			    size10 = 1;
			  end
			  default: begin
			    zero_len10 = 0;
			    size10 = 15;
			  end
			endcase
			case(in[22:12]) //11
			  11'b11111110110: begin
			    zero_len11 = 1;
			    size11 = 5;
			  end
			  11'b11111110111: begin
			    zero_len11 = 5;
			    size11 = 2;
			  end
			  11'b11111111000: begin
			    zero_len11 = 13;
			    size11 = 1;
			  end
			  11'b11111111001: begin
			    zero_len11 = 15;
			    size11 = 0;
			  end
			  default: begin
			    zero_len11 = 0;
			    size11 = 15;
			  end
			endcase
			case(in[22:11]) //12
			  12'b111111110100: begin
			    zero_len12 = 2;
			    size12 = 4;
			  end
			  12'b111111110101: begin
			    zero_len12 = 3;
			    size12 = 3;
			  end
			  12'b111111110110: begin
			    zero_len12 = 6;
			    size12 = 2;
			  end
			  12'b111111110111: begin
			    zero_len12 = 7;
			    size12 = 2;
			  end
			  default: begin
			    zero_len12 = 0;
			    size12 = 15;
			  end
			endcase
			case(in[22:8]) //15
			  15'b111111111000000: begin
			    zero_len15 = 8;
			    size15 = 2;
			  end
			  default: begin
			    zero_len15 = 0;
			    size15 = 15;
			  end
			endcase
			case(in[22:7]) //16
			  16'b1111111110000100: begin
			    zero_len16 = 1;
			    size16 = 6;
			  end
			  16'b1111111110000101: begin
			    zero_len16 = 1;
			    size16 = 7;
			  end
			  16'b1111111110001001: begin
			    zero_len16 = 2;
			    size16 = 5;
			  end
			  16'b1111111110001010: begin
			    zero_len16 = 2;
			    size16 = 6;
			  end
			  16'b1111111110001011: begin
			    zero_len16 = 2;
			    size16 = 7;
			  end
			  16'b1111111110001111: begin
			    zero_len16 = 3;
			    size16 = 4;
			  end
			  16'b1111111110010000: begin
			    zero_len16 = 3;
			    size16 = 5;
			  end
			  16'b1111111110010001: begin
			    zero_len16 = 3;
			    size16 = 6;
			  end
			  16'b1111111110010010: begin
			    zero_len16 = 3;
			    size16 = 7;
			  end
			  16'b1111111110010110: begin
			    zero_len16 = 4;
			    size16 = 3;
			  end
			  16'b1111111110010111: begin
			    zero_len16 = 4;
			    size16 = 4;
			  end
			  16'b1111111110011000: begin
			    zero_len16 = 4;
			    size16 = 5;
			  end
			  16'b1111111110011001: begin
			    zero_len16 = 4;
			    size16 = 6;
			  end
			  16'b1111111110011010: begin
			    zero_len16 = 4;
			    size16 = 7;
			  end
			  16'b1111111110011110: begin
			    zero_len16 = 5;
			    size16 = 3;
			  end
			  16'b1111111110011111: begin
			    zero_len16 = 5;
			    size16 = 4;
			  end
			  16'b1111111110100000: begin
			    zero_len16 = 5;
			    size16 = 5;
			  end
			  16'b1111111110100001: begin
			    zero_len16 = 5;
			    size16 = 6;
			  end
			  16'b1111111110100010: begin
			    zero_len16 = 5;
			    size16 = 7;
			  end
			  16'b1111111110100110: begin
			    zero_len16 = 6;
			    size16 = 3;
			  end
			  16'b1111111110100111: begin
			    zero_len16 = 6;
			    size16 = 4;
			  end
			  16'b1111111110101000: begin
			    zero_len16 = 6;
			    size16 = 5;
			  end
			  16'b1111111110101001: begin
			    zero_len16 = 6;
			    size16 = 6;
			  end
			  16'b1111111110101010: begin
			    zero_len16 = 6;
			    size16 = 7;
			  end
			  16'b1111111110101110: begin
			    zero_len16 = 7;
			    size16 = 3;
			  end
			  16'b1111111110101111: begin
			    zero_len16 = 7;
			    size16 = 4;
			  end
			  16'b1111111110110000: begin
			    zero_len16 = 7;
			    size16 = 5;
			  end
			  16'b1111111110110001: begin
			    zero_len16 = 7;
			    size16 = 6;
			  end
			  16'b1111111110110010: begin
			    zero_len16 = 7;
			    size16 = 7;
			  end
			  16'b1111111110110110: begin
			    zero_len16 = 8;
			    size16 = 3;
			  end
			  16'b1111111110110111: begin
			    zero_len16 = 8;
			    size16 = 4;
			  end
			  16'b1111111110111000: begin
			    zero_len16 = 8;
			    size16 = 5;
			  end
			  16'b1111111110111001: begin
			    zero_len16 = 8;
			    size16 = 6;
			  end
			  16'b1111111110111010: begin
			    zero_len16 = 8;
			    size16 = 7;
			  end
			  16'b1111111110111110: begin
			    zero_len16 = 9;
			    size16 = 2;
			  end
			  16'b1111111110111111: begin
			    zero_len16 = 9;
			    size16 = 3;
			  end
			  16'b1111111111000000: begin
			    zero_len16 = 9;
			    size16 = 4;
			  end
			  16'b1111111111000001: begin
			    zero_len16 = 9;
			    size16 = 5;
			  end
			  16'b1111111111000010: begin
			    zero_len16 = 9;
			    size16 = 6;
			  end
			  16'b1111111111000011: begin
			    zero_len16 = 9;
			    size16 = 7;
			  end
			  16'b1111111111000111: begin
			    zero_len16 = 10;
			    size16 = 2;
			  end
			  16'b1111111111001000: begin
			    zero_len16 = 10;
			    size16 = 3;
			  end
			  16'b1111111111001001: begin
			    zero_len16 = 10;
			    size16 = 4;
			  end
			  16'b1111111111001010: begin
			    zero_len16 = 10;
			    size16 = 5;
			  end
			  16'b1111111111001011: begin
			    zero_len16 = 10;
			    size16 = 6;
			  end
			  16'b1111111111001100: begin
			    zero_len16 = 10;
			    size16 = 7;
			  end
			  16'b1111111111010000: begin
			    zero_len16 = 11;
			    size16 = 2;
			  end
			  16'b1111111111010001: begin
			    zero_len16 = 11;
			    size16 = 3;
			  end
			  16'b1111111111010010: begin
			    zero_len16 = 11;
			    size16 = 4;
			  end
			  16'b1111111111010011: begin
			    zero_len16 = 11;
			    size16 = 5;
			  end
			  16'b1111111111010100: begin
			    zero_len16 = 11;
			    size16 = 6;
			  end
			  16'b1111111111010101: begin
			    zero_len16 = 11;
			    size16 = 7;
			  end
			  16'b1111111111011001: begin
			    zero_len16 = 12;
			    size16 = 2;
			  end
			  16'b1111111111011010: begin
			    zero_len16 = 12;
			    size16 = 3;
			  end
			  16'b1111111111011011: begin
			    zero_len16 = 12;
			    size16 = 4;
			  end
			  16'b1111111111011100: begin
			    zero_len16 = 12;
			    size16 = 5;
			  end
			  16'b1111111111011101: begin
			    zero_len16 = 12;
			    size16 = 6;
			  end
			  16'b1111111111011110: begin
			    zero_len16 = 12;
			    size16 = 7;
			  end
			  16'b1111111111100010: begin
			    zero_len16 = 13;
			    size16 = 2;
			  end
			  16'b1111111111100011: begin
			    zero_len16 = 13;
			    size16 = 3;
			  end
			  16'b1111111111100100: begin
			    zero_len16 = 13;
			    size16 = 4;
			  end
			  16'b1111111111100101: begin
			    zero_len16 = 13;
			    size16 = 5;
			  end
			  16'b1111111111100110: begin
			    zero_len16 = 13;
			    size16 = 6;
			  end
			  16'b1111111111100111: begin
			    zero_len16 = 13;
			    size16 = 7;
			  end
			  16'b1111111111101011: begin
			    zero_len16 = 14;
			    size16 = 1;
			  end
			  16'b1111111111101100: begin
			    zero_len16 = 14;
			    size16 = 2;
			  end
			  16'b1111111111101101: begin
			    zero_len16 = 14;
			    size16 = 3;
			  end
			  16'b1111111111101110: begin
			    zero_len16 = 14;
			    size16 = 4;
			  end
			  16'b1111111111101111: begin
			    zero_len16 = 14;
			    size16 = 5;
			  end
			  16'b1111111111110000: begin
			    zero_len16 = 14;
			    size16 = 6;
			  end
			  16'b1111111111110001: begin
			    zero_len16 = 14;
			    size16 = 7;
			  end
			  16'b1111111111110101: begin
			    zero_len16 = 15;
			    size16 = 1;
			  end
			  16'b1111111111110110: begin
			    zero_len16 = 15;
			    size16 = 2;
			  end
			  16'b1111111111110111: begin
			    zero_len16 = 15;
			    size16 = 3;
			  end
			  16'b1111111111111000: begin
			    zero_len16 = 15;
			    size16 = 4;
			  end
			  16'b1111111111111001: begin
			    zero_len16 = 15;
			    size16 = 5;
			  end
			  16'b1111111111111010: begin
			    zero_len16 = 15;
			    size16 = 6;
			  end
			  16'b1111111111111011: begin
			    zero_len16 = 15;
			    size16 = 7;
			  end
			  default: begin
			    zero_len16 = 0;
			    size16 = 15;
			  end
			endcase
		end
	end
	else begin
		if(state == DC) begin
			zero_len2 = 0; zero_len3 = 0; zero_len4 = 0; zero_len5 = 0; zero_len6 = 0; zero_len7 = 0; zero_len8 = 0; zero_len9 = 0; zero_len10 = 0; zero_len11 = 0; 
	    zero_len12 = 0; zero_len14 = 0; zero_len15 = 0; zero_len16 = 0;
			size14 = 15; size9 = 15; size10 = 15; size11 = 15; size12 = 15; size15 = 15; size16 = 15;
			case(in[22:21]) //2
				2'b00: begin
					size2 = 0;
				end
				2'b01: begin
					size2 = 1;
				end
				2'b10: begin
					size2 = 2;
				end
				default: begin
					size2 = 15;
				end
			endcase
			case(in[22:20]) //3
				3'b110: begin
					size3 = 3;
				end
				default: begin
					size3 = 15;
				end
			endcase
			case(in[22:19]) //4
				4'b1110: begin
					size4 = 4;
				end
				default: begin
					size4 = 15;
				end
			endcase
			case(in[22:18]) //5
				5'b11110: begin
					size5 = 5;
				end
				default: begin
					size5 = 15;
				end
			endcase
			case(in[22:17]) //6
				6'b111110: begin
					size6 = 6;
				end
				default: begin
					size6 = 15;
				end
			endcase
			case(in[22:16]) //7
				7'b1111110: begin
					size7 = 7;
				end
				default: begin
					size7 = 15;
				end
			endcase
			case(in[22:15]) //8
				8'b11111110: begin
					size8 = 8;
				end
				default: begin
					size8 = 15;
				end
			endcase
		end
		else begin
			case(in[22:21]) //2
			  2'b00: begin//v
			    zero_len2 = 0;
			    size2 = 0;
			  end
			  2'b01: begin//v
			    zero_len2 = 0;
			    size2 = 1;
			  end
			  default: begin
			    zero_len2 = 0;
			    size2 = 15;
			  end
			endcase
			case(in[22:20]) //3
			  3'b100: begin//v
			    zero_len3 = 0;
			    size3 = 2;
			  end
			  default: begin
			    zero_len3 = 0;
			    size3 = 15;
			  end
			endcase
			case(in[22:19]) //4
			  4'b1010: begin//v
			    zero_len4 = 0;
			    size4 = 3;
			  end
			  4'b1011: begin//v
			    zero_len4 = 1;
			    size4 = 1;
			  end
			  default: begin
			    zero_len4 = 0;
			    size4 = 15;
			  end
			endcase
			case(in[22:18]) //5
			  5'b11000: begin//v
			    zero_len5 = 0;
			    size5 = 4;
			  end
			  5'b11001: begin//v
			    zero_len5 = 0;
			    size5 = 5;
			  end
			  5'b11010: begin//v
			    zero_len5 = 2;
			    size5 = 1;
			  end
			  5'b11011: begin//v
			    zero_len5 = 3;
			    size5 = 1;
			  end
			  default: begin
			    zero_len5 = 0;
			    size5 = 15;
			  end
			endcase
			case(in[22:17]) //6
			  6'b111000: begin//v
			    zero_len6 = 0;
			    size6 = 6;
			  end
			  6'b111001: begin//v
			    zero_len6 = 1;
			    size6 = 2;
			  end
			  6'b111010: begin
			    zero_len6 = 4;//v
			    size6 = 1;
			  end
			  6'b111011: begin//v
			    zero_len6 = 5;
			    size6 = 1;
			  end
			  default: begin
			    zero_len6 = 0;
			    size6 = 15;
			  end
			endcase
			case(in[22:16]) //7
			  7'b1111000: begin//v
			    zero_len7 = 0;
			    size7 = 7;
			  end
			  7'b1111001: begin//v
			    zero_len7 = 6;
			    size7 = 1;
			  end
			  7'b1111010: begin//v
			    zero_len7 = 7;
			    size7 = 1;
			  end
			  default: begin
			    zero_len7 = 0;
			    size7 = 15;
			  end
			endcase
			case(in[22:15]) //8
			  8'b11110110: begin//v
			    zero_len8 = 1;
			    size8 = 3;
			  end
			  8'b11110111: begin//v
			    zero_len8 = 2;
			    size8 = 2;
			  end
			  8'b11111000: begin//v
			    zero_len8 = 3;
			    size8 = 2;
			  end
			  8'b11111001: begin//v
			    zero_len8 = 8;
			    size8 = 1;
			  end
			  default: begin
			    zero_len8 = 0;
			    size8 = 15;
			  end
			endcase
			case(in[22:14]) //9
			  9'b111110101: begin//v
			    zero_len9 = 1;
			    size9 = 4;
			  end
			  9'b111110110: begin//v
			    zero_len9 = 4;
			    size9 = 2;
			  end
			  9'b111110111: begin//v
			    zero_len9 = 9;
			    size9 = 1;
			  end
			  9'b111111000: begin//v
			    zero_len9 = 10;
			    size9 = 1;
			  end
			  9'b111111001: begin//v
			    zero_len9 = 11;
			    size9 = 1;
			  end
			  9'b111111010: begin//v
			    zero_len9 = 12;
			    size9 = 1;
			  end
			  default: begin
			    zero_len9 = 0;
			    size9 = 15;
			  end
			endcase
			case(in[22:13]) //10
			  10'b1111110111: begin//v
			    zero_len10 = 2;
			    size10 = 3;
			  end
			  10'b1111111000: begin//v
			    zero_len10 = 3;
			    size10 = 3;
			  end
			  10'b1111111001: begin//v
			    zero_len10 = 5;
			    size10 = 2;
			  end
			  10'b1111111010: begin//v
			    zero_len10 = 15;
			    size10 = 0;
			  end
			  default: begin
			    zero_len10 = 0;
			    size10 = 15;
			  end
			endcase
			case(in[22:12]) //11
			  11'b11111110110: begin//v
			    zero_len11 = 1;
			    size11 = 5;
			  end
			  11'b11111110111: begin//v
			    zero_len11 = 6;
			    size11 = 2;
			  end
			  11'b11111111000: begin//v
			    zero_len11 = 7;
			    size11 = 2;
			  end
			  11'b11111111001: begin//v
			    zero_len11 = 13;
			    size11 = 1;
			  end
			  default: begin
			    zero_len11 = 0;
			    size11 = 15;
			  end
			endcase
			case(in[22:11]) //12
			  12'b111111110101: begin//v
			    zero_len12 = 1;
			    size12 = 6;
			  end
			  12'b111111110110: begin//v
			    zero_len12 = 2;
			    size12 = 4;
			  end
			  12'b111111110111: begin//v
			    zero_len12 = 3;
			    size12 = 4;
			  end
			  default: begin
			    zero_len12 = 0;
			    size12 = 15;
			  end
			endcase
			case(in[22:9]) //14
			  14'b11111111100000: begin//v
			    zero_len14 = 14;
			    size14 = 1;
                          end	
			  default: begin
			    zero_len14 = 0;
			    size14 = 15;
                          end
			endcase
			case(in[22:8]) //15
			  15'b111111111000010: begin//v
			    zero_len15 = 2;
			    size15 = 5;
			  end
			  15'b111111111000011: begin//v
			    zero_len15 = 15;
			    size15 = 1;
			  end
			  default: begin
			    zero_len15 = 0;
			    size15 = 15;
			  end
			endcase
			case(in[22:7]) //16
			  16'b1111111110001000: begin//v
			    zero_len16 = 1;
			    size16 = 7;
			  end
			  16'b1111111110001100: begin//v
			    zero_len16 = 2;
			    size16 = 6;
			  end
			  16'b1111111110001101: begin//v
			    zero_len16 = 2;
			    size16 = 7;
			  end
			  16'b1111111110010001: begin//v
			    zero_len16 = 3;
			    size16 = 5;
			  end
			  16'b1111111110010010: begin//v
			    zero_len16 = 3;
			    size16 = 6;
			  end
			  16'b1111111110010011: begin//v
			    zero_len16 = 3;
			    size16 = 7;
			  end
			  16'b1111111110010111: begin//v
			    zero_len16 = 4;
			    size16 = 3;
			  end
			  16'b1111111110011000: begin//v
			    zero_len16 = 4;
			    size16 = 4;
			  end
			  16'b1111111110011001: begin//v
			    zero_len16 = 4;
			    size16 = 5;
			  end
			  16'b1111111110011010: begin//v
			    zero_len16 = 4;
			    size16 = 6;
			  end
			  16'b1111111110011011: begin//v
			    zero_len16 = 4;
			    size16 = 7;
			  end
			  16'b1111111110011111: begin//v
			    zero_len16 = 5;
			    size16 = 3;
			  end
			  16'b1111111110100000: begin//v
			    zero_len16 = 5;
			    size16 = 4;
			  end
			  16'b1111111110100001: begin//v
			    zero_len16 = 5;
			    size16 = 5;
			  end
			  16'b1111111110100010: begin//v
			    zero_len16 = 5;
			    size16 = 6;
			  end
			  16'b1111111110100011: begin//v
			    zero_len16 = 5;
			    size16 = 7;
			  end
			  16'b1111111110100111: begin//v
			    zero_len16 = 6;
			    size16 = 3;
			  end
			  16'b1111111110101000: begin//v
			    zero_len16 = 6;
			    size16 = 4;
			  end
			  16'b1111111110101001: begin//v
			    zero_len16 = 6;
			    size16 = 5;
			  end
			  16'b1111111110101010: begin//v
			    zero_len16 = 6;
			    size16 = 6;
			  end
			  16'b1111111110101011: begin//v
			    zero_len16 = 6;
			    size16 = 7;
			  end
			  16'b1111111110101111: begin//v
			    zero_len16 = 7;
			    size16 = 3;
			  end
			  16'b1111111110110000: begin//v
			    zero_len16 = 7;
			    size16 = 4;
			  end
			  16'b1111111110110001: begin//v
			    zero_len16 = 7;
			    size16 = 5;
			  end
			  16'b1111111110110010: begin//v
			    zero_len16 = 7;
			    size16 = 6;
			  end
			  16'b1111111110110011: begin//v
			    zero_len16 = 7;
			    size16 = 7;
			  end
			  16'b1111111110110111: begin//v
			    zero_len16 = 8;
			    size16 = 2;
			  end
			  16'b1111111110111000: begin//v
			    zero_len16 = 8;
			    size16 = 3;
			  end
			  16'b1111111110111001: begin//v
			    zero_len16 = 8;
			    size16 = 4;
			  end
			  16'b1111111110111010: begin//v
			    zero_len16 = 8;
			    size16 = 5;
			  end
			  16'b1111111110111011: begin//v
			    zero_len16 = 8;
			    size16 = 6;
			  end
			  16'b1111111110111100: begin//v
			    zero_len16 = 8;
			    size16 = 7;
			  end
			  16'b1111111111000000: begin//v
			    zero_len16 = 9;
			    size16 = 2;
			  end
			  16'b1111111111000001: begin//v
			    zero_len16 = 9;
			    size16 = 3;
			  end
			  16'b1111111111000010: begin//v
			    zero_len16 = 9;
			    size16 = 4;
			  end
			  16'b1111111111000011: begin//v
			    zero_len16 = 9;
			    size16 = 5;
			  end
			  16'b1111111111000100: begin//v
			    zero_len16 = 9;
			    size16 = 6;
			  end
			  16'b1111111111000101: begin//v
			    zero_len16 = 9;
			    size16 = 7;
			  end
			  16'b1111111111001001: begin//v
			    zero_len16 = 10;
			    size16 = 2;
			  end
			  16'b1111111111001010: begin//v
			    zero_len16 = 10;
			    size16 = 3;
			  end
			  16'b1111111111001011: begin//v
			    zero_len16 = 10;
			    size16 = 4;
			  end
			  16'b1111111111001100: begin//v
			    zero_len16 = 10;
			    size16 = 5;
			  end
			  16'b1111111111001101: begin//v
			    zero_len16 = 10;
			    size16 = 6;
			  end
			  16'b1111111111001110: begin//v
			    zero_len16 = 10;
			    size16 = 7;
			  end
			  16'b1111111111010010: begin//v
			    zero_len16 = 11;
			    size16 = 2;
			  end
			  16'b1111111111010011: begin//v
			    zero_len16 = 11;
			    size16 = 3;
			  end
			  16'b1111111111010100: begin//v
			    zero_len16 = 11;
			    size16 = 4;
			  end
			  16'b1111111111010101: begin//v
			    zero_len16 = 11;
			    size16 = 5;
			  end
			  16'b1111111111010110: begin//v
			    zero_len16 = 11;
			    size16 = 6;
			  end
			  16'b1111111111010111: begin//v
			    zero_len16 = 11;
			    size16 = 7;
			  end
			  16'b1111111111011011: begin//v
			    zero_len16 = 12;
			    size16 = 2;
			  end
			  16'b1111111111011100: begin//v
			    zero_len16 = 12;
			    size16 = 3;
			  end
			  16'b1111111111011101: begin//v
			    zero_len16 = 12;
			    size16 = 4;
			  end
			  16'b1111111111011110: begin//v
			    zero_len16 = 12;
			    size16 = 5;
			  end
			  16'b1111111111011111: begin//v
			    zero_len16 = 12;
			    size16 = 6;
			  end
			  16'b1111111111100000: begin//v
			    zero_len16 = 12;
			    size16 = 7;
			  end
			  16'b1111111111100100: begin//v
			    zero_len16 = 13;
			    size16 = 2;
			  end
			  16'b1111111111100101: begin//v
			    zero_len16 = 13;
			    size16 = 3;
			  end
			  16'b1111111111100110: begin//v
			    zero_len16 = 13;
			    size16 = 4;
			  end
			  16'b1111111111100111: begin//v
			    zero_len16 = 13;
			    size16 = 5;
			  end
			  16'b1111111111101000: begin//v
			    zero_len16 = 13;
			    size16 = 6;
			  end
			  16'b1111111111101001: begin//v
			    zero_len16 = 13;
			    size16 = 7;
			  end
			  16'b1111111111101101: begin//v
			    zero_len16 = 14;
			    size16 = 2;
			  end
			  16'b1111111111101110: begin//v
			    zero_len16 = 14;
			    size16 = 3;
			  end
			  16'b1111111111101111: begin//v
			    zero_len16 = 14;
			    size16 = 4;
			  end
			  16'b1111111111110000: begin//v
			    zero_len16 = 14;
			    size16 = 5;
			  end
			  16'b1111111111110001: begin//v
			    zero_len16 = 14;
			    size16 = 6;
			  end
			  16'b1111111111110010: begin//v
			    zero_len16 = 14;
			    size16 = 7;
			  end
			  16'b1111111111110110: begin//v
			    zero_len16 = 15;
			    size16 = 2;
			  end
			  16'b1111111111110111: begin//v
			    zero_len16 = 15;
			    size16 = 3;
			  end
			  16'b1111111111111000: begin//v
			    zero_len16 = 15;
			    size16 = 4;
			  end
			  16'b1111111111111001: begin//v
			    zero_len16 = 15;
			    size16 = 5;
			  end
			  16'b1111111111111010: begin//v
			    zero_len16 = 15;
			    size16 = 6;
			  end
			  16'b1111111111111011: begin//v
			    zero_len16 = 15;
			    size16 = 7;
			  end
			  default: begin
			    zero_len16 = 0;
			    size16 = 15;
			  end
			endcase
		end
	end
end

endmodule
