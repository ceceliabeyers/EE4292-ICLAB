module enigma_part1(clk,srstn,load,encrypt,crypt_mode,load_idx,code_in,code_out,code_valid);
input clk;               //clock input
input srstn;             //synchronous reset (active low)
input load;              //load control signal (level sensitive). 0/1: inactive/active
                         //effective in IDLE and LOAD states
input encrypt;           //encrypt control signal (level sensitive). 0/1: inactive/active
                         //effective in READY state
input crypt_mode;        //0: encrypt; 1:decrypt
input [8-1:0] load_idx;		//index of rotor table to be loaded; A:0~63; B:64~127; C:128~191;
input [6-1:0] code_in;		//When load is active, 
                        //rotorA[load_idx[5:0]] <= code_in if load_idx[7:6]==2'b00
                        //rotorB[load_idx[5:0]] <= code_in if load_idx[7:6]==2'b01
						//rotorC[load_idx[5:0]] <= code_in if load_idx[7:6]==2'b10
output reg [6-1:0] code_out;   //encrypted code word (register output)
output reg code_valid;         //0: non-valid code_out; 1: valid code_out (register output)

parameter IDLE = 2'd0, LOAD = 2'd1, READY = 2'd2;
integer j;

reg [1:0] state, n_state;
reg [6-1:0] rotorA_table[0:64-1], rotorA_table_nx[0:64-1], rotorA_inverse[0:64-1], rotorA_inverse_nx[0:64-1];
reg [6-1:0] rotA_o;
reg [6-1:0] ref_o;
reg [6-1:0] code_out_nx;
reg code_valid_nx;

// FSM
always@(posedge clk) begin
	if(!srstn) begin
		state <= IDLE;
	end
	else begin
		state <= n_state;
	end
end

always@* begin
	case(state)
		IDLE: begin
			if(load) begin
				n_state = LOAD;
			end
			else begin
				n_state = IDLE;
			end
		end
		LOAD: begin
			if(!load) begin
				n_state = READY;
			end
			else begin
				n_state = LOAD;
			end
		end
		READY: begin
			n_state = READY;
		end
		default: begin
			n_state = IDLE;
		end
	endcase
end

// roterA
always@(posedge clk) begin
	for(j = 0; j < 64; j = j + 1) begin
		rotorA_table[j] <= rotorA_table_nx[j];
		rotorA_inverse[j] <= rotorA_inverse_nx[j];
	end
end

always@* begin
	for(j = 0; j < 64; j = j + 1) begin
		rotorA_table_nx[j] = rotorA_table[j];
		rotorA_inverse_nx[j] = rotorA_inverse[j];
	end
	if(state == LOAD) begin
		if(load_idx[7:6]==2'b00) begin
			rotorA_table_nx[load_idx[5:0]] = code_in;
			rotorA_inverse_nx[code_in] = load_idx[5:0];
		end
	end
	else if(state == READY) begin
		if(code_valid_nx) begin
			for (j = 62; j >= 0; j = j - 1) begin
				rotorA_table_nx[j + 1] = rotorA_table[j];
			end
			rotorA_table_nx[0]= rotorA_table[63];
			for(j = 0; j < 64; j = j + 1) begin
				if(rotorA_inverse[j] == 6'd63) begin
					rotorA_inverse_nx[j] = 0;
				end
				else begin
					rotorA_inverse_nx[j] = rotorA_inverse[j] + 1;
				end
			end
		end
	end		
end

// encrypt
always@(posedge clk) begin
	code_out <= code_out_nx;
	code_valid <= code_valid_nx;
end

always@* begin
	rotA_o = 0;
	ref_o = 0;
	code_out_nx = 0;
	code_valid_nx = 0;
	if(state == READY) begin
		if(encrypt) begin
			rotA_o = rotorA_table[code_in];
			ref_o = 6'd63 - rotA_o;
			code_out_nx = rotorA_inverse[ref_o];
			code_valid_nx = 1;
		end
	end
end

endmodule 
