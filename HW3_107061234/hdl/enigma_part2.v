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
reg [6-1:0] rotorA_table[0:64-1], rotorA_table_nx[0:64-1];
reg [6-1:0] rotorB_table[0:64-1], rotorB_table_nx[0:64-1];
reg [6-1:0] rotorC_table[0:64-1], rotorC_table_nx1[0:64-1], rotorC_table_nx2[0:64-1];
reg [6-1:0] rotA_o, o_AB;
reg [6-1:0] rotB_o, o_BC;
reg [6-1:0] rotC_o;
reg [6-1:0] ref_o;
reg [6-1:0] o_CRC;
reg [6-1:0] rotC_inv_o, o_CB;
reg [6-1:0] rotB_inv_o, o_BA;
reg [6-1:0] code_out_nx;
reg code_valid_nx2, code_valid_nx3, code_valid_nx4, code_valid_nx5, code_valid_nx6, code_valid_nx7;
reg count, count_nx;
reg [1:0] count_cycle, count_cycle_nx;
reg [1:0] permC_determiner;
reg compute, compute_nx;
// FSM
always@(posedge clk) begin
	if(!srstn) begin
		state <= IDLE;
		compute <= 0;
	end
	else begin
		state <= n_state;
		compute <= compute_nx;
	end
end

always@* begin
	compute_nx = compute;
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
			if(load) begin
				n_state = LOAD;
			end
			else begin
				n_state = READY;
			end
		end
		READY: begin
			n_state = READY;
			if(encrypt) compute_nx = 1;
		end
		default: begin
			n_state = 2'bxx;
		end
	endcase
end

//------------ roterA B C--------------
always@(posedge clk) begin
	for(j = 0; j < 64; j = j + 1) begin
		rotorA_table[j] <= rotorA_table_nx[j];
		rotorB_table[j] <= rotorB_table_nx[j];
		rotorC_table[j] <= rotorC_table_nx2[j];
//		rotorC_table[j] <= rotorC_table[j];
	end
end

always@(posedge clk) begin
	if(~srstn) begin
		count <= 0;
		count_cycle <= 0;
	end
	else begin
		count <= count_nx;
		count_cycle <= count_cycle_nx;
	end
end

always@* begin
	// Default
	for(j = 0; j < 64; j = j + 1) begin
		rotorA_table_nx[j] = rotorA_table[j];
		rotorB_table_nx[j] = rotorB_table[j];
		rotorC_table_nx1[j] = rotorC_table[j];
		rotorC_table_nx2[j] = rotorC_table_nx1[j];
	end
	count_nx = count;
	if(!crypt_mode) permC_determiner = rotC_o[1:0];
	else permC_determiner = ref_o[1:0];

	// For LOAD
	if(state == LOAD) begin
		if(load_idx[7:6]==2'b00) begin
			rotorA_table_nx[load_idx[5:0]] = code_in;
		end
		if(load_idx[7:6]==2'b01) begin                       // elif
			rotorB_table_nx[load_idx[5:0]] = code_in;
		end
		if(load_idx[7:6]==2'b10) begin                       // elif
			rotorC_table_nx2[load_idx[5:0]] = code_in;
		end
	end
	// For READY
	else if(state == READY) begin
		if(count_cycle_nx != 0) begin
			if(count_cycle != 0) count_nx = count + 1;
			// A
			for (j = 62; j >= 0; j = j - 1) begin
				rotorA_table_nx[j + 1] = rotorA_table[j];
			end
			rotorA_table_nx[0]= rotorA_table[63];
			// B
			if(count_cycle != 0 && count) begin
				for(j = 62; j >= 0; j = j - 1) begin
					rotorB_table_nx[j + 1] = rotorB_table[j];
				end
				rotorB_table_nx[0]= rotorB_table[63];
			end
			// C
		//	if(!crypt_mode) permC_determiner = rotC_o[1:0];
		//	else permC_determiner = ref_o[1:0];
			if(count_cycle > 2'd1) begin 
				case(permC_determiner)
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
			end
		end
	end		
end

// encrypt/decrypt
always@(posedge clk) begin
	code_out <= code_out_nx;
//	code_valid_nx2 <= code_valid_nx1;
	code_valid_nx3 <= code_valid_nx2;
	code_valid_nx4 <= code_valid_nx3;
	code_valid_nx5 <= code_valid_nx4;
	code_valid_nx6 <= code_valid_nx5;
	code_valid <= code_valid_nx6;
	o_AB <= rotA_o;
	o_BC <= rotB_o;
//	o_CRC <= ref_o;
	o_CB <= rotC_inv_o;
	o_BA <= rotB_inv_o;
end
	 
always@* begin
	rotA_o = 0;
	rotB_o = 0;
	rotC_o = 0;
	ref_o = 0;
	rotC_inv_o = 0;
	rotB_inv_o = 0;
	code_out_nx = 0;
	code_valid_nx2 = 0;
	count_cycle_nx = count_cycle;
	if(state == READY) begin
		if(compute_nx) begin
			rotA_o = rotorA_table[code_in];
			rotB_o = rotorB_table[o_AB];
			rotC_o = rotorC_table[o_BC];
			ref_o = 6'd63 - rotC_o;
			case(ref_o) //synopsys parallel_case
					rotorC_table[0]: rotC_inv_o = 0;
					rotorC_table[1]: rotC_inv_o = 1;
					rotorC_table[2]: rotC_inv_o = 2;
					rotorC_table[3]: rotC_inv_o = 3;
					rotorC_table[4]: rotC_inv_o = 4;
					rotorC_table[5]: rotC_inv_o = 5;
					rotorC_table[6]: rotC_inv_o = 6;
					rotorC_table[7]: rotC_inv_o = 7;
					rotorC_table[8]: rotC_inv_o = 8;
					rotorC_table[9]: rotC_inv_o = 9;
					rotorC_table[10]: rotC_inv_o = 10;
					rotorC_table[11]: rotC_inv_o = 11;
					rotorC_table[12]: rotC_inv_o = 12;
					rotorC_table[13]: rotC_inv_o = 13;
					rotorC_table[14]: rotC_inv_o = 14;
					rotorC_table[15]: rotC_inv_o = 15;
					rotorC_table[16]: rotC_inv_o = 16;
					rotorC_table[17]: rotC_inv_o = 17;
					rotorC_table[18]: rotC_inv_o = 18;
					rotorC_table[19]: rotC_inv_o = 19;
					rotorC_table[20]: rotC_inv_o = 20;
					rotorC_table[21]: rotC_inv_o = 21;
					rotorC_table[22]: rotC_inv_o = 22;
					rotorC_table[23]: rotC_inv_o = 23;
					rotorC_table[24]: rotC_inv_o = 24;
					rotorC_table[25]: rotC_inv_o = 25;
					rotorC_table[26]: rotC_inv_o = 26;
					rotorC_table[27]: rotC_inv_o = 27;
					rotorC_table[28]: rotC_inv_o = 28;
					rotorC_table[29]: rotC_inv_o = 29;
					rotorC_table[30]: rotC_inv_o = 30;
					rotorC_table[31]: rotC_inv_o = 31;
					rotorC_table[32]: rotC_inv_o = 32;
					rotorC_table[33]: rotC_inv_o = 33;
					rotorC_table[34]: rotC_inv_o = 34;
					rotorC_table[35]: rotC_inv_o = 35;
					rotorC_table[36]: rotC_inv_o = 36;
					rotorC_table[37]: rotC_inv_o = 37;
					rotorC_table[38]: rotC_inv_o = 38;
					rotorC_table[39]: rotC_inv_o = 39;
					rotorC_table[40]: rotC_inv_o = 40;
					rotorC_table[41]: rotC_inv_o = 41;
					rotorC_table[42]: rotC_inv_o = 42;
					rotorC_table[43]: rotC_inv_o = 43;
					rotorC_table[44]: rotC_inv_o = 44;
					rotorC_table[45]: rotC_inv_o = 45;
					rotorC_table[46]: rotC_inv_o = 46;
					rotorC_table[47]: rotC_inv_o = 47;
					rotorC_table[48]: rotC_inv_o = 48;
					rotorC_table[49]: rotC_inv_o = 49;
					rotorC_table[50]: rotC_inv_o = 50;
					rotorC_table[51]: rotC_inv_o = 51;
					rotorC_table[52]: rotC_inv_o = 52;
					rotorC_table[53]: rotC_inv_o = 53;
					rotorC_table[54]: rotC_inv_o = 54;
					rotorC_table[55]: rotC_inv_o = 55;
					rotorC_table[56]: rotC_inv_o = 56;
					rotorC_table[57]: rotC_inv_o = 57;
					rotorC_table[58]: rotC_inv_o = 58;
					rotorC_table[59]: rotC_inv_o = 59;
					rotorC_table[60]: rotC_inv_o = 60;
					rotorC_table[61]: rotC_inv_o = 61;
					rotorC_table[62]: rotC_inv_o = 62;
					rotorC_table[63]: rotC_inv_o = 63;
					default: rotC_inv_o = 0;
				endcase
			case(o_CB) //synopsys parallel_case
						rotorB_table[0]: rotB_inv_o = 63;
						rotorB_table[1]: rotB_inv_o = 0;
						rotorB_table[2]: rotB_inv_o = 1;
						rotorB_table[3]: rotB_inv_o = 2;
						rotorB_table[4]: rotB_inv_o = 3;
						rotorB_table[5]: rotB_inv_o = 4;
						rotorB_table[6]: rotB_inv_o = 5;
						rotorB_table[7]: rotB_inv_o = 6;
						rotorB_table[8]: rotB_inv_o = 7;
						rotorB_table[9]: rotB_inv_o = 8;
						rotorB_table[10]: rotB_inv_o = 9;
						rotorB_table[11]: rotB_inv_o = 10;
						rotorB_table[12]: rotB_inv_o = 11;
						rotorB_table[13]: rotB_inv_o = 12;
						rotorB_table[14]: rotB_inv_o = 13;
						rotorB_table[15]: rotB_inv_o = 14;
						rotorB_table[16]: rotB_inv_o = 15;
						rotorB_table[17]: rotB_inv_o = 16;
						rotorB_table[18]: rotB_inv_o = 17;
						rotorB_table[19]: rotB_inv_o = 18;
						rotorB_table[20]: rotB_inv_o = 19;
						rotorB_table[21]: rotB_inv_o = 20;
						rotorB_table[22]: rotB_inv_o = 21;
						rotorB_table[23]: rotB_inv_o = 22;
						rotorB_table[24]: rotB_inv_o = 23;
						rotorB_table[25]: rotB_inv_o = 24;
						rotorB_table[26]: rotB_inv_o = 25;
						rotorB_table[27]: rotB_inv_o = 26;
						rotorB_table[28]: rotB_inv_o = 27;
						rotorB_table[29]: rotB_inv_o = 28;
						rotorB_table[30]: rotB_inv_o = 29;
						rotorB_table[31]: rotB_inv_o = 30;
						rotorB_table[32]: rotB_inv_o = 31;
						rotorB_table[33]: rotB_inv_o = 32;
						rotorB_table[34]: rotB_inv_o = 33;
						rotorB_table[35]: rotB_inv_o = 34;
						rotorB_table[36]: rotB_inv_o = 35;
						rotorB_table[37]: rotB_inv_o = 36;
						rotorB_table[38]: rotB_inv_o = 37;
						rotorB_table[39]: rotB_inv_o = 38;
						rotorB_table[40]: rotB_inv_o = 39;
						rotorB_table[41]: rotB_inv_o = 40;
						rotorB_table[42]: rotB_inv_o = 41;
						rotorB_table[43]: rotB_inv_o = 42;
						rotorB_table[44]: rotB_inv_o = 43;
						rotorB_table[45]: rotB_inv_o = 44;
						rotorB_table[46]: rotB_inv_o = 45;
						rotorB_table[47]: rotB_inv_o = 46;
						rotorB_table[48]: rotB_inv_o = 47;
						rotorB_table[49]: rotB_inv_o = 48;
						rotorB_table[50]: rotB_inv_o = 49;
						rotorB_table[51]: rotB_inv_o = 50;
						rotorB_table[52]: rotB_inv_o = 51;
						rotorB_table[53]: rotB_inv_o = 52;
						rotorB_table[54]: rotB_inv_o = 53;
						rotorB_table[55]: rotB_inv_o = 54;
						rotorB_table[56]: rotB_inv_o = 55;
						rotorB_table[57]: rotB_inv_o = 56;
						rotorB_table[58]: rotB_inv_o = 57;
						rotorB_table[59]: rotB_inv_o = 58;
						rotorB_table[60]: rotB_inv_o = 59;
						rotorB_table[61]: rotB_inv_o = 60;
						rotorB_table[62]: rotB_inv_o = 61;
						rotorB_table[63]: rotB_inv_o = 62;
						default: rotB_inv_o = 0;
					endcase
			case(o_BA) //synopsys parallel_case
					rotorA_table[0]: code_out_nx = 60;
					rotorA_table[1]: code_out_nx = 61;
					rotorA_table[2]: code_out_nx = 62;
					rotorA_table[3]: code_out_nx = 63;
					rotorA_table[4]: code_out_nx = 0;
					rotorA_table[5]: code_out_nx = 1;
					rotorA_table[6]: code_out_nx = 2;
					rotorA_table[7]: code_out_nx = 3;
					rotorA_table[8]: code_out_nx = 4;
					rotorA_table[9]: code_out_nx = 5;
					rotorA_table[10]: code_out_nx = 6;
					rotorA_table[11]: code_out_nx = 7;
					rotorA_table[12]: code_out_nx = 8;
					rotorA_table[13]: code_out_nx = 9;
					rotorA_table[14]: code_out_nx = 10;
					rotorA_table[15]: code_out_nx = 11;
					rotorA_table[16]: code_out_nx = 12;
					rotorA_table[17]: code_out_nx = 13;
					rotorA_table[18]: code_out_nx = 14;
					rotorA_table[19]: code_out_nx = 15;
					rotorA_table[20]: code_out_nx = 16;
					rotorA_table[21]: code_out_nx = 17;
					rotorA_table[22]: code_out_nx = 18;
					rotorA_table[23]: code_out_nx = 19;
					rotorA_table[24]: code_out_nx = 20;
					rotorA_table[25]: code_out_nx = 21;
					rotorA_table[26]: code_out_nx = 22;
					rotorA_table[27]: code_out_nx = 23;
					rotorA_table[28]: code_out_nx = 24;
					rotorA_table[29]: code_out_nx = 25;
					rotorA_table[30]: code_out_nx = 26;
					rotorA_table[31]: code_out_nx = 27;
					rotorA_table[32]: code_out_nx = 28;
					rotorA_table[33]: code_out_nx = 29;
					rotorA_table[34]: code_out_nx = 30;
					rotorA_table[35]: code_out_nx = 31;
					rotorA_table[36]: code_out_nx = 32;
					rotorA_table[37]: code_out_nx = 33;
					rotorA_table[38]: code_out_nx = 34;
					rotorA_table[39]: code_out_nx = 35;
					rotorA_table[40]: code_out_nx = 36;
					rotorA_table[41]: code_out_nx = 37;
					rotorA_table[42]: code_out_nx = 38;
					rotorA_table[43]: code_out_nx = 39;
					rotorA_table[44]: code_out_nx = 40;
					rotorA_table[45]: code_out_nx = 41;
					rotorA_table[46]: code_out_nx = 42;
					rotorA_table[47]: code_out_nx = 43;
					rotorA_table[48]: code_out_nx = 44;
					rotorA_table[49]: code_out_nx = 45;
					rotorA_table[50]: code_out_nx = 46;
					rotorA_table[51]: code_out_nx = 47;
					rotorA_table[52]: code_out_nx = 48;
					rotorA_table[53]: code_out_nx = 49;
					rotorA_table[54]: code_out_nx = 50;
					rotorA_table[55]: code_out_nx = 51;
					rotorA_table[56]: code_out_nx = 52;
					rotorA_table[57]: code_out_nx = 53;
					rotorA_table[58]: code_out_nx = 54;
					rotorA_table[59]: code_out_nx = 55;
					rotorA_table[60]: code_out_nx = 56;
					rotorA_table[61]: code_out_nx = 57;
					rotorA_table[62]: code_out_nx = 58;
					rotorA_table[63]: code_out_nx = 59;
					default: code_out_nx = 0;
				endcase
			if(count_cycle != 2'd3) count_cycle_nx = count_cycle + 1;
			if(encrypt) begin
				code_valid_nx2 = 1;
			end	 
		end
	end
end

endmodule 
