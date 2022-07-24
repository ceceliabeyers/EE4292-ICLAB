module control(
input clk,
input rst_n,
input enable,
input valid_un,
input valid_conv1,
input valid_conv2,
input valid_conv3,
output reg unshuffle_en,
output reg conv1_en,
output reg conv2_en,
output reg conv3_en,
//output reg conv_en,
output reg valid
);

localparam IDLE = 3'd0, UNSHUFFLE = 3'd1, CONV1 = 3'd2, CONV2 = 3'd3, CONV3 = 3'd4, FINISH = 3'd5;
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
			if(valid_conv1) n_state = CONV2;
			else n_state = CONV1;
		end
		CONV2: begin
			if(valid_conv2) n_state = CONV3;
			else n_state = CONV2;
		end
		CONV3: begin
			if(valid_conv3) n_state = FINISH;
			else n_state = CONV3;
		end
		FINISH: begin
			n_state = FINISH;
		end
		default: n_state = IDLE; 
	endcase
end

always@* begin
	unshuffle_en = 0;
	conv1_en = 0;
	conv2_en = 0;
	conv3_en = 0;
	//conv_en = 0;
	valid_nx = 0;
	case(state)
		IDLE: begin
			unshuffle_en = 0;
			conv1_en = 0;
			conv2_en = 0;
			conv3_en = 0;
			//conv_en = 0;
			valid_nx = 0;
		end
		UNSHUFFLE: begin 
			unshuffle_en = 1;
			conv1_en = 0;
			conv2_en = 0;
			conv3_en = 0;
			//conv_en = 0;
			valid_nx = 0;
		end
		CONV1: begin
			unshuffle_en = 0;
			conv1_en = 1;
			conv2_en = 0;
			conv3_en = 0;
			//conv_en = 1;
			valid_nx = 0;
		end
		CONV2: begin
			unshuffle_en = 0;
			conv1_en = 0;
			conv2_en = 1;
			conv3_en = 0;
			//conv_en = 1;
			valid_nx = 0;
		end
		CONV3: begin
			unshuffle_en = 0;
			conv1_en = 0;
			conv2_en = 0;
			conv3_en = 1;
			//conv_en = 1;  
			valid_nx = 0;
		end
		FINISH: begin
			unshuffle_en = 0;
			conv1_en = 0;
			conv2_en = 0;
			conv3_en = 0;
			//conv_en = 0;  
			valid_nx = 1;
		end
		default: begin
			unshuffle_en = 0;
			conv1_en = 0;
			conv2_en = 0;
			conv3_en = 0;
			//conv_en = 0;
			valid_nx = 0;
		end
	endcase
end

endmodule
