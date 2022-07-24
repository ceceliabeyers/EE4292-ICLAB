module enigma_part2(clk,srstn,load,encrypt,crypt_mode,load_idx,code_in,code_out,code_valid);
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
reg [6-1:0] rotorB_table[0:64-1], rotorB_table_nx[0:64-1], rotorB_inverse[0:64-1], rotorB_inverse_nx[0:64-1];
reg [6-1:0] rotorC_table[0:64-1], rotorC_table_nx1[0:64-1], rotorC_table_nx2[0:64-1], rotorC_inverse[0:64-1], rotorC_inverse_nx[0:64-1];
reg [6-1:0] rotA_o;
reg [6-1:0] rotB_o;
reg [6-1:0] rotC_o;
reg [6-1:0] ref_o;
reg [6-1:0] rotC_inv_o;
reg [6-1:0] rotB_inv_o;
reg [6-1:0] code_out_nx;
reg code_valid_nx;
reg count, count_nx;
reg [6-1:0] permC_determiner;
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

//------------ roterA B C--------------
always@(posedge clk) begin
	for(j = 0; j < 64; j = j + 1) begin
		rotorA_table[j] <= rotorA_table_nx[j];
		rotorA_inverse[j] <= rotorA_inverse_nx[j];
		rotorB_table[j] <= rotorB_table_nx[j];
		rotorB_inverse[j] <= rotorB_inverse_nx[j];
		rotorC_table[j] <= rotorC_table_nx2[j];
		rotorC_inverse[j] <= rotorC_inverse_nx[j];
	end
end

always@(posedge clk) begin
	if(~srstn) count <= 0;
	else count <= count_nx;
end

always@* begin
	// Default
	for(j = 0; j < 64; j = j + 1) begin
		rotorA_table_nx[j] = rotorA_table[j];
		rotorA_inverse_nx[j] = rotorA_inverse[j];
		rotorB_table_nx[j] = rotorB_table[j];
		rotorB_inverse_nx[j] = rotorB_inverse[j];
		rotorC_table_nx1[j] = rotorC_table[j];
		rotorC_table_nx2[j] = rotorC_table_nx1[j];
		rotorC_inverse_nx[j] = rotorC_inverse[j];
	end
	count_nx = count;
	// For LOAD
	if(state == LOAD) begin
		if(load_idx[7:6]==2'b00) begin
			rotorA_table_nx[load_idx[5:0]] = code_in;
			rotorA_inverse_nx[code_in] = load_idx[5:0];
		end
		else if(load_idx[7:6]==2'b01) begin
			rotorB_table_nx[load_idx[5:0]] = code_in;
			rotorB_inverse_nx[code_in] = load_idx[5:0];
		end
		else if(load_idx[7:6]==2'b10) begin
			rotorC_table_nx2[load_idx[5:0]] = code_in;
			rotorC_inverse_nx[code_in] = load_idx[5:0];
		end
	end
	// For READY
	else if(state == READY) begin
		//count_nx = count + 1;
		if(code_valid_nx) begin
			count_nx = count + 1;
			// A
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
			// B
			if(count) begin
				for(j = 62; j >= 0; j = j - 1) begin
					rotorB_table_nx[j + 1] = rotorB_table[j];
				end
				rotorB_table_nx[0]= rotorB_table[63];
				for(j = 0; j < 64; j = j + 1) begin
					if(rotorB_inverse[j] == 6'd63) begin
						rotorB_inverse_nx[j] = 0;
					end
					else begin
						rotorB_inverse_nx[j] = rotorB_inverse[j] + 1;
					end
				end
			end
			// C
			if(!crypt_mode) permC_determiner = rotC_o;
			else permC_determiner = ref_o;
			case(permC_determiner[1:0])
				2'b01: begin
					for(j = 0; j < 16; j = j + 1) begin
						rotorC_table_nx1[4*j] = rotorC_table[4*j+1];
						rotorC_table_nx1[4*j+1] = rotorC_table[4*j];
						rotorC_table_nx1[4*j+2] = rotorC_table[4*j+3];
						rotorC_table_nx1[4*j+3] = rotorC_table[4*j+2];
					end
				end
				2'b10: begin
					for(j = 0; j < 16; j = j + 1) begin
						rotorC_table_nx1[4*j] = rotorC_table[4*j+2];
						rotorC_table_nx1[4*j+1] = rotorC_table[4*j+3];
						rotorC_table_nx1[4*j+2] = rotorC_table[4*j];
						rotorC_table_nx1[4*j+3] = rotorC_table[4*j+1];
					end
				end
				2'b11: begin
					for(j = 0; j < 16; j = j + 1) begin
						rotorC_table_nx1[4*j] = rotorC_table[4*j+3];
						rotorC_table_nx1[4*j+1] = rotorC_table[4*j+2];
						rotorC_table_nx1[4*j+2] = rotorC_table[4*j+1];
						rotorC_table_nx1[4*j+3] = rotorC_table[4*j];
					end
				end
				default: begin
					for(j = 0; j < 64; j = j + 1) begin
						rotorC_table_nx1[j] = rotorC_table[j];
					end
				end
			endcase
			rotorC_table_nx2[0] = rotorC_table_nx1[41];
			rotorC_table_nx2[1] = rotorC_table_nx1[56];
			rotorC_table_nx2[2] = rotorC_table_nx1[61];
			rotorC_table_nx2[3] = rotorC_table_nx1[29];
			rotorC_table_nx2[4] = rotorC_table_nx1[0];
			rotorC_table_nx2[5] = rotorC_table_nx1[26];
			rotorC_table_nx2[6] = rotorC_table_nx1[28];
			rotorC_table_nx2[7] = rotorC_table_nx1[63];
			rotorC_table_nx2[8] = rotorC_table_nx1[34];
			rotorC_table_nx2[9] = rotorC_table_nx1[19];
			rotorC_table_nx2[10] = rotorC_table_nx1[36];
			rotorC_table_nx2[11] = rotorC_table_nx1[46];
			rotorC_table_nx2[12] = rotorC_table_nx1[23];
			rotorC_table_nx2[13] = rotorC_table_nx1[54];
			rotorC_table_nx2[14] = rotorC_table_nx1[44];
			rotorC_table_nx2[15] = rotorC_table_nx1[7];
			rotorC_table_nx2[16] = rotorC_table_nx1[43];
			rotorC_table_nx2[17] = rotorC_table_nx1[1];
			rotorC_table_nx2[18] = rotorC_table_nx1[42];
			rotorC_table_nx2[19] = rotorC_table_nx1[5];
			rotorC_table_nx2[20] = rotorC_table_nx1[40];
			rotorC_table_nx2[21] = rotorC_table_nx1[22];
			rotorC_table_nx2[22] = rotorC_table_nx1[6];
			rotorC_table_nx2[23] = rotorC_table_nx1[33];
			rotorC_table_nx2[24] = rotorC_table_nx1[21];
			rotorC_table_nx2[25] = rotorC_table_nx1[58];
			rotorC_table_nx2[26] = rotorC_table_nx1[13];
			rotorC_table_nx2[27] = rotorC_table_nx1[51];
			rotorC_table_nx2[28] = rotorC_table_nx1[53];
			rotorC_table_nx2[29] = rotorC_table_nx1[24];
			rotorC_table_nx2[30] = rotorC_table_nx1[37];
			rotorC_table_nx2[31] = rotorC_table_nx1[32];
			rotorC_table_nx2[32] = rotorC_table_nx1[31];
			rotorC_table_nx2[33] = rotorC_table_nx1[11];
			rotorC_table_nx2[34] = rotorC_table_nx1[47];
			rotorC_table_nx2[35] = rotorC_table_nx1[25];
			rotorC_table_nx2[36] = rotorC_table_nx1[48];
			rotorC_table_nx2[37] = rotorC_table_nx1[2];
			rotorC_table_nx2[38] = rotorC_table_nx1[10];
			rotorC_table_nx2[39] = rotorC_table_nx1[9];
			rotorC_table_nx2[40] = rotorC_table_nx1[4];
			rotorC_table_nx2[41] = rotorC_table_nx1[52];
			rotorC_table_nx2[42] = rotorC_table_nx1[55];
			rotorC_table_nx2[43] = rotorC_table_nx1[17];
			rotorC_table_nx2[44] = rotorC_table_nx1[8];
			rotorC_table_nx2[45] = rotorC_table_nx1[62];
			rotorC_table_nx2[46] = rotorC_table_nx1[16];
			rotorC_table_nx2[47] = rotorC_table_nx1[50];
			rotorC_table_nx2[48] = rotorC_table_nx1[38];
			rotorC_table_nx2[49] = rotorC_table_nx1[14];
			rotorC_table_nx2[50] = rotorC_table_nx1[30];
			rotorC_table_nx2[51] = rotorC_table_nx1[27];
			rotorC_table_nx2[52] = rotorC_table_nx1[57];
			rotorC_table_nx2[53] = rotorC_table_nx1[18];
			rotorC_table_nx2[54] = rotorC_table_nx1[60];
			rotorC_table_nx2[55] = rotorC_table_nx1[15];
			rotorC_table_nx2[56] = rotorC_table_nx1[49];
			rotorC_table_nx2[57] = rotorC_table_nx1[59];
			rotorC_table_nx2[58] = rotorC_table_nx1[20];
			rotorC_table_nx2[59] = rotorC_table_nx1[12];
			rotorC_table_nx2[60] = rotorC_table_nx1[39];
			rotorC_table_nx2[61] = rotorC_table_nx1[3];
			rotorC_table_nx2[62] = rotorC_table_nx1[35];
			rotorC_table_nx2[63] = rotorC_table_nx1[45];
			for(j = 0; j < 64; j = j + 1) begin
				rotorC_inverse_nx[rotorC_table_nx2[rotorC_inverse[j]]] = rotorC_inverse[j];
			end
		end
	end		
end

// encrypt/decrypt
always@(posedge clk) begin
	code_out <= code_out_nx;
	code_valid <= code_valid_nx;
end

always@* begin
	rotA_o = 0;
	rotB_o = 0;
	rotC_o = 0;
	ref_o = 0;
	rotC_inv_o = 0;
	rotB_inv_o = 0;
	code_out_nx = 0;
	code_valid_nx = 0;
	if(state == READY) begin
		if(encrypt) begin
			rotA_o = rotorA_table[code_in];
			rotB_o = rotorB_table[rotA_o];
			rotC_o = rotorC_table[rotB_o];
			ref_o = 6'd63 - rotC_o;
			rotC_inv_o = rotorC_inverse[ref_o];
			rotB_inv_o = rotorB_inverse[rotC_inv_o];
			code_out_nx = rotorA_inverse[rotB_inv_o];
			code_valid_nx = 1;
		end
	end
end

endmodule 
