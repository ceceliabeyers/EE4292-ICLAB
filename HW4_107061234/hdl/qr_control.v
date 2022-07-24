module qr_control(
input clk,
input srstn,
input qr_decode_start,
input pos_find,
input error_valid,
input angle_valid,
input [7:0] length,
output reg [11:0] sram_raddr,
output reg [8:0] cnt_d,
output reg decode_valid,
output reg qr_decode_finish,
output reg [2:0] state_d
);

localparam IDLE = 3'd0, FIND = 3'd1, ANGLE = 3'd2, MASK = 3'd3, FILL = 3'd4, EXTRA = 3'd5, ERROR = 3'd6, DECODE = 3'd7;

reg [2:0] state, n_state;
reg [11:0] pos_all, pos_all_nx, pos_all_d;
reg [5:0] pos_x, pos_y, pos_x_nx, pos_y_nx;
reg decode_valid_nx, decode_valid_nx2, qr_decode_finish_nx, qr_decode_finish_nx2;
reg [8:0] cnt, cnt_nx;
reg [11:0] sram_raddr_nx;
reg [1:0] angle, angle_nx, angle_d;

wire [10:0] addr_0, addr_90;

sram_addr_0 sram_addr_0(.count_addr(cnt), .out_addr(addr_0));
sram_addr_90 sram_addr_90(.count_addr(cnt), .out_addr(addr_90));

always@(posedge clk) begin
	sram_raddr <= sram_raddr_nx;
end
always@(posedge clk) begin
	if(~srstn) begin
		state <= IDLE;
		state_d <= IDLE; //add
		pos_all <= 4095; 
		pos_all_d <= 4095; //add
		angle <= 0; 
		angle_d <= 0; //add
		pos_x <= 0;
		pos_y <= 0;
		decode_valid <= 0;
		decode_valid_nx <= 0;
		qr_decode_finish <= 0;
		qr_decode_finish_nx <= 0;
		cnt <= 0;
		cnt_d <= 0;
	end
	else begin
		state <= n_state;
		state_d <= state; //add
		pos_all <= pos_all_nx;
		pos_all_d <= pos_all; //add
		pos_x <= pos_x_nx;
		pos_y <= pos_y_nx;
		decode_valid <= decode_valid_nx;
		qr_decode_finish <= qr_decode_finish_nx;
		decode_valid_nx <= decode_valid_nx2;
		qr_decode_finish_nx <= qr_decode_finish_nx2;
		cnt <= cnt_nx;
		angle <= angle_nx;
		angle_d <= angle;
		cnt_d <= cnt;
	end
end

always@* begin
	case(state) // synopsys parallel_case
		IDLE: begin
			if(qr_decode_start) begin
				n_state = FIND;
			end
			else begin
				n_state = IDLE;
			end
		end
		FIND: begin
			if(pos_find) begin
				n_state = ANGLE;
			end
			else begin
				n_state = FIND;
			end
		end
		ANGLE: begin
			if(angle_valid) n_state = MASK;
			else n_state = ANGLE;
		end
		MASK: begin
			if(cnt == 2) n_state = FILL;
			else n_state = MASK;
		end
		FILL: begin
			if(cnt == 351) n_state = EXTRA;
			else n_state = FILL;
		end
		EXTRA: begin
			if(error_valid) n_state = DECODE;
			else if(cnt == 3) n_state = ERROR;
			else n_state = EXTRA;		
		end
		ERROR: begin 
			if(error_valid) begin
				n_state = DECODE;
			end
			else begin
				n_state = ERROR;
			end
		end
		DECODE: begin 
			if(qr_decode_finish) n_state = IDLE;
			else n_state = DECODE;
		end
		default: begin
			n_state = IDLE;
		end
	endcase
end

always@* begin
	pos_all_nx = pos_all;
	pos_x_nx = pos_x;
	pos_y_nx = pos_y;
	sram_raddr_nx = 0;
	decode_valid_nx2 = 0;
	qr_decode_finish_nx2  = 0;
	cnt_nx = cnt;
	angle_nx = angle;

	case(state) // synopsys parallel_case
		FIND: begin
			sram_raddr_nx = pos_all;
			if(pos_x == 39) begin
				pos_x_nx = 0;
				pos_y_nx = pos_y + 1; 
				if(pos_find) pos_all_nx = pos_all_d; // all
				else pos_all_nx = pos_all - 25; 
			end
			else begin
				pos_x_nx = pos_x + 1;  
				pos_y_nx = pos_y;
				if(pos_find) pos_all_nx = pos_all_d; //all
				else pos_all_nx = pos_all - 1;
			end
		end 
		ANGLE: begin
			if(angle_valid || cnt == 3) cnt_nx = 0;
			else cnt_nx = cnt + 1;
			case(cnt) // synopsys parallel_case
				0: begin
					sram_raddr_nx = pos_all - 261;
					angle_nx = 1;  //0   //0
				end
				1: begin
					sram_raddr_nx = pos_all - 275;
					angle_nx = 0;  //270  //3
				end
				2: begin
					sram_raddr_nx = pos_all - 1299;
					angle_nx = 3; //180  //2
				end
				3: begin 
					sram_raddr_nx = pos_all - 1285;
					angle_nx = 2; //90  //1
				end
				default: sram_raddr_nx = 0;
			endcase
		end
		MASK: begin
			if(cnt == 2) cnt_nx = 0;
			else cnt_nx = cnt + 1;
			case(cnt)  // synopsys parallel_case
				0: begin
					case(angle_d)   // synopsys parallel_case
						0: sram_raddr_nx = pos_all - 1046;
						3: sram_raddr_nx = pos_all - 1416;
						2: sram_raddr_nx = pos_all - 514;
						1: sram_raddr_nx = pos_all - 144;
						default: sram_raddr_nx = 0;
					endcase
				end
				1: begin
					case(angle_d) // synopsys parallel_case
						0: sram_raddr_nx = pos_all - 1045;
						3: sram_raddr_nx = pos_all - 1352;
						2: sram_raddr_nx = pos_all - 515;
						1: sram_raddr_nx = pos_all - 208;
						default: sram_raddr_nx = 0;
					endcase
				end
				2: begin
					case(angle_d) // synopsys parallel_case
						0: sram_raddr_nx = pos_all - 1044;
						3: sram_raddr_nx = pos_all - 1288;
						2: sram_raddr_nx = pos_all - 516;
						1: sram_raddr_nx = pos_all - 272;
						default: sram_raddr_nx = 0;
					endcase
				end
				default: sram_raddr_nx = 0;
			endcase
		end
		FILL: begin
			if(cnt != 351) cnt_nx = cnt + 1;
			else cnt_nx = 0;
			case(angle_d) // synopsys parallel_case
				0: sram_raddr_nx = pos_all - (1560 - addr_0);
				1: sram_raddr_nx = pos_all - (1560 - addr_90);
				2: sram_raddr_nx = pos_all - addr_0;
				3: sram_raddr_nx = pos_all - addr_90;
				default: sram_raddr_nx = 0;
			endcase
		end
		EXTRA: begin
			if(cnt != 3) cnt_nx = cnt + 1;
			else cnt_nx = 0;
		end
		DECODE: begin
			decode_valid_nx2 = 1;
			if(cnt != {1'b0, length}) cnt_nx = cnt + 1;
			else begin 
				qr_decode_finish_nx2 = 1;
				decode_valid_nx2 = 0;
			end
		end
		default: qr_decode_finish_nx2 = 0;
	endcase
end

endmodule
	


