module control(
input clk,
input rst_n,
input enable,
//input busy,
input valid_un,
output reg unshuffle_en,
output reg valid
);

localparam IDLE = 3'd0, UNSHUFFLE = 3'd1, CONV1 = 3'd2;
reg [2:0] state, n_state;
reg valid_nx;

always@(posedge clk) begin
	if(~rst_n) begin
		state <= IDLE;
		valid <= 0;
	end
	else begin
	 	state <= n_state;
		valid <= valid_nx;
	end
end

always@* begin
	case(state)
		IDLE: begin
			if(enable) n_state = UNSHUFFLE;
			else n_state = IDLE;
		end
		UNSHUFFLE: begin
			if(valid_un) n_state = CONV1;
			else n_state = UNSHUFFLE;
		end
		CONV1: begin
			n_state = CONV1;
		end
		default: n_state = IDLE; 
	endcase
end

always@* begin
	unshuffle_en = 0;
	valid_nx = 0;
	case(state)
		IDLE: begin
			unshuffle_en = 0;
			valid_nx = 0;
		end
		UNSHUFFLE: begin 
			unshuffle_en = 1;
			valid_nx = 0;
		end
		CONV1: begin
			unshuffle_en = 0;
			valid_nx = 1;
		end
		default: begin
			unshuffle_en = 0;
			valid_nx = 0;
		end
	endcase
end

endmodule
