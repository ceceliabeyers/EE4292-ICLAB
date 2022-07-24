module qr_find(
input clk,
input srstn,
input sram_rdata,
input [8:0] cnt,
input [2:0] state_d, //add
output reg pos_find,
output reg error_valid,
output reg angle_valid,
output reg [7:0] length,
output reg [7:0] text
);

localparam IDLE = 3'd0, SYNDROME = 3'd1, SIGMA = 3'd2, EXTRA = 3'd3, LOC = 3'd4, CORRECT = 3'd5, FINAL = 3'd6;

reg error_exist;
reg error1_exist;
reg error1_valid;
reg [352-1:0] message, message_nx;
reg [7:0] text_nx;
reg [2:0] state, n_state;
reg [2:0] mask;
reg [3:0] length1, length2, text1, text2;
reg [6:0] cnt_S, cnt_S_nx;
reg [7:0] in_n0, in_n1, in_n2, in_n3;
reg [7:0] in_a0, in_a1, in_a2, in_a3;
reg [8:0] in_a0_tmp, in_a1_tmp, in_a2_tmp;
reg [9:0] in_a3_tmp;

reg [7:0] in_n01, in_n11, in_n21, in_n31;
reg [7:0] in_a01, in_a11, in_a21, in_a31;
reg [8:0] in_a01_tmp, in_a11_tmp, in_a21_tmp;
reg [9:0] in_a31_tmp;
reg [7:0] loc_use;
wire [7:0] out_n0, out_n1, out_n2, out_n3;
wire [7:0] out_a0, out_a1, out_a2, out_a3;
reg [7:0] synd [0:7];
reg [7:0] synd_nx [0:7];
reg [7:0] synd1_nx [0:7];
reg [7:0] synd_a [0:7];
reg [7:0] synd_a_nx [0:7];
reg [7:0] synd1_a_nx [0:7];
reg [7:0] eq1_n [2:0];
reg [7:0] eq1_n_nx [2:0];
reg [7:0] eq2_n [2:0];
reg [7:0] eq2_n_nx [2:0];
reg [7:0] eq3_n [2:0];
reg [7:0] eq3_n_nx [2:0];
reg [7:0] eq4_n [2:0];
reg [7:0] eq4_n_nx [2:0];
reg [7:0] eq5 [3:0];
reg [7:0] eq5_nx [3:0];
reg [7:0] eq5_n [3:0];
reg [7:0] eq5_n_nx [3:0];
reg [7:0] eq6 [3:0];
reg [7:0] eq6_nx [3:0];
reg [7:0] eq6_n [3:0];
reg [7:0] eq6_n_nx [3:0];
reg [7:0] eq7 [3:0];
reg [7:0] eq7_nx [3:0];
reg [7:0] eq7_n [3:0];
reg [7:0] eq7_n_nx [3:0];
reg [7:0] eq8 [2:0];
reg [7:0] eq8_nx [2:0];
reg [7:0] eq8_n [2:0];
reg [7:0] eq8_n_nx [2:0];
reg [7:0] eq9 [2:0];
reg [7:0] eq9_nx [2:0];
reg [7:0] eq9_n [2:0];
reg [7:0] eq9_n_nx [2:0];
//reg [7:0] eq10 [1:0];
//reg [7:0] eq10_nx [1:0];
reg [7:0] sig1, sig2, sig3, sig4, sig1_nx, sig2_nx, sig3_nx, sig4_nx;
reg [5:0] loc1, loc2, loc3, loc4, loc1_nx, loc2_nx, loc3_nx, loc4_nx;
reg [7:0] a4_cnt, a3_cnt, a2_cnt, a4_cnt_nx, a3_cnt_nx, a2_cnt_nx; 
reg [2:0] cnt_loc, cnt_loc_nx;
reg [7:0] xor_a, xor_a_nx;
reg [2:0] mask_nx;
reg [2:0] mask_pat;
wire [7:0] mask_out;
reg [5:0] cnt_43;
integer i, j;

galois U0(.in_a(in_a0), .clk(clk), .out_n(out_n0));
galois U1(.in_a(in_a1), .clk(clk), .out_n(out_n1));
galois U2(.in_a(in_a2), .clk(clk), .out_n(out_n2));
galois U3(.in_a(in_a3), .clk(clk), .out_n(out_n3));
galois2 Ua(.in_n(in_n0), .out_a(out_a0));
galois2 Ub(.in_n(in_n1), .out_a(out_a1));
galois2 Uc(.in_n(in_n2), .out_a(out_a2));
galois2 Ud(.in_n(in_n3), .out_a(out_a3));
qr_demask de(.cnt(cnt_43), .mask_pat(mask_pat), .out(mask_out));

always@(posedge clk) begin
	if(~srstn) begin
		cnt_S <= 0;
		for(i = 0; i < 8; i = i + 1) begin
			synd[i] <= 0;
			synd_a[i] <= 0;
		end
		state <= IDLE;
		loc1 <= 0;
		loc2 <= 0;
		loc3 <= 0;
		loc4 <= 0;
		a4_cnt <= 0;
		a3_cnt <= 0;
		a2_cnt <= 0;
		cnt_loc <= 0;
	end
	else begin
		cnt_S <= cnt_S_nx;
		for(i = 0; i < 8; i = i + 1) begin
			synd[i] <= synd_nx[i];
			synd_a[i] <= synd_a_nx[i];
		end
		state <= n_state;
		loc1 <= loc1_nx;
		loc2 <= loc2_nx;
		loc3 <= loc3_nx;
		loc4 <= loc4_nx;
		a4_cnt <= a4_cnt_nx;
		a3_cnt <= a3_cnt_nx;
		a2_cnt <= a2_cnt_nx;
		cnt_loc <= cnt_loc_nx;
		mask <= mask_nx;
	end
end

always@(posedge clk) begin
	message <= message_nx;
	text <= text_nx;
	for(i = 0; i < 4; i = i +1) begin
		eq5[i] <= eq5_nx[i];
		eq6[i] <= eq6_nx[i];
		eq5_n[i] <= eq5_n_nx[i];
		eq6_n[i] <= eq6_n_nx[i];
		eq7[i] <= eq7_nx[i];
		eq7_n[i] <= eq7_n_nx[i];
	end
	for(i = 0; i < 3; i = i +1) begin
		eq1_n[i] <= eq1_n_nx[i];
		eq2_n[i] <= eq2_n_nx[i];
		eq3_n[i] <= eq3_n_nx[i];
		eq4_n[i] <= eq4_n_nx[i];
		eq8[i] <= eq8_nx[i];
		eq9[i] <= eq9_nx[i];
		eq8_n[i] <= eq8_n_nx[i];
		eq9_n[i] <= eq9_n_nx[i];
	end
	//for(i = 0; i < 2; i = i +1) begin
	//	eq10[i] <= eq10_nx[i];
	//end
	sig1 <= sig1_nx;
	sig2 <= sig2_nx;
	sig3 <= sig3_nx;
	sig4 <= sig4_nx;
	xor_a <= xor_a_nx;
end

always@* begin
	pos_find = 0;
	angle_valid = 0;
	mask_nx = mask;
	message_nx = message;
	mask_pat = mask ^ 3'b101;
	cnt_43 = cnt[8:3];
	error1_exist = 0;
	error1_valid = 0;
	xor_a_nx = xor_a;
	in_n01 = 0; in_n11 = 0; in_n21 = 0; in_n31 = 0;
	for(i = 0; i < 8; i = i + 1) begin
		synd1_nx[i] = synd[i];	
		synd1_a_nx[i] = synd_a[i];
	end
	in_a01_tmp = 0; in_a11_tmp = 0; in_a21_tmp = 0;in_a31_tmp = 0;
	
	case(state_d)
	1: begin
		if(sram_rdata) pos_find = 1;
	end
	2: begin
		if(sram_rdata) angle_valid = 1;
	end
	3: begin
		mask_nx[2-cnt] = sram_rdata;
	end
	4: begin
		if(cnt[2:0] == 7) message_nx[351-cnt_43*8-:8] = {message[351-cnt_43*8-:7], sram_rdata} ^ mask_out;
		else message_nx[351-cnt] = sram_rdata;
		if(cnt_43 != 0) begin
			case(cnt[2:0])
				0: begin
					in_n01 = message[(351-cnt_43*8+8)-:8];
					xor_a_nx = out_a0;
				end
				1: begin
				in_a01_tmp = xor_a;
				in_a11_tmp = xor_a + (43 - cnt_43+1);
				in_a21_tmp = xor_a + (43 - cnt_43+1)*2;
				in_a31_tmp = xor_a + (43 - cnt_43+1)*3;
				end
				2: begin
					in_n01 = synd1_nx[0]; in_n11 = synd1_nx[1]; in_n21 = synd1_nx[2]; in_n31 = synd1_nx[3];
					synd1_nx[0] = out_n0 ^ synd[0]; synd1_nx[1] = out_n1 ^ synd[1]; synd1_nx[2] = out_n2 ^ synd[2]; synd1_nx[3] = out_n3 ^ synd[3];
				synd1_nx[4] = synd[4]; synd1_nx[5] = synd[5]; synd1_nx[6] = synd[6]; synd1_nx[7] = synd[7];
				synd1_a_nx[0] = out_a0; synd1_a_nx[1] = out_a1; synd1_a_nx[2] = out_a2; synd1_a_nx[3] = out_a3;
				synd1_a_nx[4] = synd_a[4]; synd1_a_nx[5] = synd_a[5]; synd1_a_nx[6] = synd_a[6]; synd1_a_nx[7] = synd_a[7]; 
				in_a01_tmp = xor_a + (43 - cnt_43+1)*4;
				in_a11_tmp = xor_a + (43 - cnt_43+1)*5;
				in_a21_tmp = xor_a + (43 - cnt_43+1)*6;
				in_a31_tmp = xor_a + (43 - cnt_43+1)*7;
				end
				3: begin
					in_n01 = synd_nx[4]; in_n11 = synd_nx[5]; in_n21 = synd_nx[6]; in_n31 = synd_nx[7];
					synd1_nx[0] = synd[0]; synd1_nx[1] = synd[1]; synd1_nx[2] = synd[2]; synd1_nx[3] = synd[3];
				synd1_nx[4] = out_n0 ^ synd[4]; synd1_nx[5] = out_n1 ^ synd[5]; synd1_nx[6] = out_n2 ^ synd[6]; synd1_nx[7] = out_n3 ^ synd[7];
				synd1_a_nx[0] = synd_a[0]; synd1_a_nx[1] = synd_a[1]; synd1_a_nx[2] = synd_a[2]; synd1_a_nx[3] = synd_a[3];
				synd1_a_nx[4] = out_a0; synd1_a_nx[5] = out_a1; synd1_a_nx[6] = out_a2; synd1_a_nx[7] = out_a3; 
				in_a01_tmp = xor_a + (43 - cnt_43+1)*4;
				in_a11_tmp = xor_a + (43 - cnt_43+1)*5;
				in_a21_tmp = xor_a + (43 - cnt_43+1)*6;
				in_a31_tmp = xor_a + (43 - cnt_43+1)*7;
				end
				default: begin
					for(i = 0; i < 8; i = i + 1) begin
						synd1_nx[i] = synd[i];	
						synd1_a_nx[i] = synd_a[i];
					end
				end
			endcase
		end
	end
	5: begin
		case(cnt[2:0])
			0: begin 
				in_n01 = message[7:0];
				xor_a_nx = out_a0;
			end
			1: begin 
				in_a01_tmp = xor_a;
				in_a11_tmp = xor_a;
				in_a21_tmp = xor_a;
				in_a31_tmp = xor_a;
			end
			2: begin 
				in_n01 = synd_nx[0]; in_n11 = synd_nx[1]; in_n21 = synd_nx[2]; in_n31 = synd_nx[3];
				synd1_nx[0] = out_n0 ^ synd[0]; synd1_nx[1] = out_n1 ^ synd[1]; synd1_nx[2] = out_n2 ^ synd[2]; synd1_nx[3] = out_n3 ^ synd[3];
				synd1_nx[4] = synd[4]; synd1_nx[5] = synd[5]; synd1_nx[6] = synd[6]; synd1_nx[7] = synd[7];
				synd1_a_nx[0] = out_a0; synd1_a_nx[1] = out_a1; synd1_a_nx[2] = out_a2; synd1_a_nx[3] = out_a3;
				synd1_a_nx[4] = synd_a[4]; synd1_a_nx[5] = synd_a[5]; synd1_a_nx[6] = synd_a[6]; synd1_a_nx[7] = synd_a[7]; 
				in_a01_tmp = xor_a;
				in_a11_tmp = xor_a;
				in_a21_tmp = xor_a;
				in_a31_tmp = xor_a;
			end
			3: begin
				in_n01 = synd_nx[4]; in_n11 = synd_nx[5]; in_n21 = synd_nx[6]; in_n31 = synd_nx[7];
				synd1_nx[0] = synd[0]; synd1_nx[1] = synd[1]; synd1_nx[2] = synd[2]; synd1_nx[3] = synd[3];
				synd1_nx[4] = out_n0 ^ synd[4]; synd1_nx[5] = out_n1 ^ synd[5]; synd1_nx[6] = out_n2 ^ synd[6]; synd1_nx[7] = out_n3 ^ synd[7];
				synd1_a_nx[0] = synd_a[0]; synd1_a_nx[1] = synd_a[1]; synd1_a_nx[2] = synd_a[2]; synd1_a_nx[3] = synd_a[3];
				synd1_a_nx[4] = out_a0; synd1_a_nx[5] = out_a1; synd1_a_nx[6] = out_a2; synd1_a_nx[7] = out_a3; 	
				if((synd1_nx[0] == 0) && (synd1_nx[1] == 0) && (synd1_nx[2] == 0) && (synd1_nx[3] == 0) && 
				   (synd1_nx[4] == 0) && (synd1_nx[5] == 0) && (synd1_nx[6] == 0) && (synd1_nx[7] == 0)) error1_valid = 1;
				else error1_exist = 1;
			end
			default: begin
				for(i = 0; i < 8; i = i + 1) begin
					synd1_nx[i] = synd[i];	
					synd1_a_nx[i] = synd_a[i];
				end
			end
		endcase
	end
	default: begin
		for(i = 0; i < 8; i = i + 1) begin
			synd1_nx[i] = synd[i];	
			synd1_a_nx[i] = synd_a[i];
		end
	end
	endcase
end

always@* begin
	length = {message[347], message[346], message[345], message[344], message[343], message[342], message[341], message[340]};
	if(loc4 == 42 - cnt) begin
		text1 = message[(339-cnt*8)-:4] ^ sig4[3:0];
		if(loc3 == 41 - cnt) text2 = message[(339-cnt*8-4)-:4] ^ sig3[7:4];
		else text2 = message[(339-cnt*8-4)-:4];
	end
	else if(loc4 == 41 - cnt) begin
		text1 = message[(339-cnt*8)-:4];
		text2 = message[(339-cnt*8-4)-:4] ^ sig4[7:4];
	end
	else if(loc3 == 42 - cnt) begin
		text1 = message[(339-cnt*8)-:4] ^ sig3[3:0];
		if(loc2 == 41 - cnt) text2 = message[(339-cnt*8-4)-:4] ^ sig2[7:4];
		else text2 = message[(339-cnt*8-4)-:4];
	end
	else if(loc3 == 41 - cnt) begin
		text1 = message[(339-cnt*8)-:4];
		text2 = message[(339-cnt*8-4)-:4] ^ sig3[7:4];
	end
	else if(loc2 == 42 - cnt) begin
		text1 = message[(339-cnt*8)-:4] ^ sig2[3:0];
		if(loc1 == 41 - cnt) text2 = message[(339-cnt*8-4)-:4] ^ sig1[7:4];
		else text2 = message[(339-cnt*8-4)-:4];
	end
	else if(loc2 == 41 - cnt) begin
		text1 = message[(339-cnt*8)-:4];
		text2 = message[(339-cnt*8-4)-:4] ^ sig2[7:4];
	end
	else if(loc1 == 42 - cnt) begin
		text1 = message[(339-cnt*8)-:4] ^ sig1[3:0];
		text2 = message[(339-cnt*8-4)-:4];
	end
	else if(loc1 == 41 - cnt) begin
		text1 = message[(339-cnt*8)-:4];
		text2 = message[(339-cnt*8-4)-:4] ^ sig1[7:4];
	end
	else begin
		text1 = message[(339-cnt*8)-:4];
		text2 = message[(339-cnt*8-4)-:4];
	end
	text_nx = {text1, text2};
end

always@* begin
	case(state) // synopsys parallel_case
		IDLE: begin
			if(state_d == 3 && cnt == 2) n_state = SYNDROME;
			else n_state = state;
		end
		SYNDROME: begin
			if(error_valid) n_state = IDLE;
			else if(error_exist) n_state = SIGMA;
			else n_state = state;
		end
		SIGMA: begin
			if(error_exist) n_state = EXTRA;
			else n_state = state;
		end
		EXTRA: begin
			if(error_exist) n_state = LOC;
			else n_state = state;
		end
		LOC: begin
			if(error_exist) n_state = CORRECT;
			else n_state = state;
		end
		CORRECT: begin
			if(error_exist) n_state = FINAL;
			else n_state = state;
		end
		FINAL: begin
			if(error_valid) n_state = IDLE;
			else n_state = state;
		end
		default: n_state = IDLE;
	endcase
end

always@* begin
	error_valid = 0;
	error_exist = 0;
	in_n0 = 0; in_n1 = 0; in_n2 = 0; in_n3 = 0; 
	in_a0_tmp = 0; in_a1_tmp = 0; in_a2_tmp = 0; in_a3_tmp = 0; 
	cnt_S_nx = cnt_S; 	
	sig1_nx = sig1; sig2_nx = sig2; sig3_nx = sig3; sig4_nx = sig4;
	loc1_nx = loc1; loc2_nx = loc2; loc3_nx = loc3; loc4_nx = loc4;
	a4_cnt_nx = a4_cnt; a3_cnt_nx = a3_cnt; a2_cnt_nx = a2_cnt;
	cnt_loc_nx = cnt_loc;

	case(state) // synopsys parallel_case
		SYNDROME: begin	
				for(i = 0; i < 8; i = i + 1) begin
					synd_nx[i] = synd1_nx[i];	
					synd_a_nx[i] = synd1_a_nx[i];
				end
				in_n1 = in_n11; in_n2 = in_n21; in_n3 = in_n31;
				in_n0 = in_n01;
				in_a0_tmp = in_a01_tmp;
				in_a1_tmp = in_a11_tmp;
				in_a2_tmp = in_a21_tmp;
				in_a3_tmp = in_a31_tmp;	
				error_valid = error1_valid;
				error_exist = error1_exist;
		end
		SIGMA: begin
			cnt_S_nx = cnt_S + 1;
			for(i = 0; i < 8; i = i + 1) begin
				synd_nx[i] = synd[i];	
				synd_a_nx[i] = synd_a[i];
			end
		
			case(cnt_S) // synopsys parallel_case
				0: begin // 5-1
					if(synd_a[1] > synd_a[0]) begin 
						in_a0_tmp = synd_a[1] - synd_a[0] + synd_a[1]; // Eq5 s3
						in_a1_tmp = synd_a[1] - synd_a[0] + synd_a[2]; // Eq5 s2
						in_a2_tmp = synd_a[1] - synd_a[0] + synd_a[3]; // Eq5 s1
						in_a3_tmp = synd_a[1] - synd_a[0] + synd_a[4]; // Eq5 s0
					//	in_n0 = out_n0 ^ synd[2]; in_n1 = out_n1 ^ synd[3]; in_n2 = out_n2 ^ synd[4]; in_n3 = out_n3 ^ synd[5];
					end
					else begin
						in_a0_tmp = synd_a[0] - synd_a[1] + synd_a[2]; // Eq5 s3
						in_a1_tmp = synd_a[0] - synd_a[1] + synd_a[3]; // Eq5 s2
						in_a2_tmp = synd_a[0] - synd_a[1] + synd_a[4]; // Eq5 s1
						in_a3_tmp = synd_a[0] - synd_a[1] + synd_a[5]; // Eq5 s0
					//	in_n0 = out_n0 ^ synd[1]; in_n1 = out_n1 ^ synd[2]; in_n2 = out_n2 ^ synd[3]; in_n3 = out_n3 ^ synd[4];
					end
				end // 5-2 6-1
				1: begin
					if(synd_a[2] > synd_a[1]) begin
						in_a0_tmp = synd_a[2] - synd_a[1] + synd_a[2]; // Eq6 s3
						in_a1_tmp = synd_a[2] - synd_a[1] + synd_a[3]; // Eq6 s2
						in_a2_tmp = synd_a[2] - synd_a[1] + synd_a[4]; // Eq6 s1
						in_a3_tmp = synd_a[2] - synd_a[1] + synd_a[5]; // Eq6 s0
					//	in_n0 = out_n0 ^ synd[3]; in_n1 = out_n1 ^ synd[4]; in_n2 = out_n2 ^ synd[5]; in_n3 = out_n3 ^ synd[6];
					end
					else begin
						in_a0_tmp = synd_a[1] - synd_a[2] + synd_a[3]; // Eq6 s3
						in_a1_tmp = synd_a[1] - synd_a[2] + synd_a[4]; // Eq6 s2
						in_a2_tmp = synd_a[1] - synd_a[2] + synd_a[5]; // Eq6 s1
						in_a3_tmp = synd_a[1] - synd_a[2] + synd_a[6]; // Eq6 s0
					//	in_n0 = out_n0 ^ synd[2]; in_n1 = out_n1 ^ synd[3]; in_n2 = out_n2 ^ synd[4]; in_n3 = out_n3 ^ synd[5];
					end
					if(synd_a[1] > synd_a[0]) begin 
						in_n0 = out_n0 ^ synd[2]; in_n1 = out_n1 ^ synd[3]; in_n2 = out_n2 ^ synd[4]; in_n3 = out_n3 ^ synd[5];
					end
					else begin
						in_n0 = out_n0 ^ synd[1]; in_n1 = out_n1 ^ synd[2]; in_n2 = out_n2 ^ synd[3]; in_n3 = out_n3 ^ synd[4];
					end
				end // 6-2 7-1  5aok
				2: begin
					if(synd_a[3] > synd_a[2]) begin
						in_a0_tmp = synd_a[3] - synd_a[2] + synd_a[3]; // Eq7 s3
						in_a1_tmp = synd_a[3] - synd_a[2] + synd_a[4]; // Eq7 s2
						in_a2_tmp = synd_a[3] - synd_a[2] + synd_a[5]; // Eq7 s1
						in_a3_tmp = synd_a[3] - synd_a[2] + synd_a[6]; // Eq7 s0
					//	in_n0 = out_n0 ^ synd[4]; in_n1 = out_n1 ^ synd[5]; in_n2 = out_n2 ^ synd[6]; in_n3 = out_n3 ^ synd[7];
					end
					else begin
						in_a0_tmp = synd_a[2] - synd_a[3] + synd_a[4]; // Eq7 s3
						in_a1_tmp = synd_a[2] - synd_a[3] + synd_a[5]; // Eq7 s2
						in_a2_tmp = synd_a[2] - synd_a[3] + synd_a[6]; // Eq7 s1
						in_a3_tmp = synd_a[2] - synd_a[3] + synd_a[7]; // Eq7 s0
					//	in_n0 = out_n0 ^ synd[3]; in_n1 = out_n1 ^ synd[4]; in_n2 = out_n2 ^ synd[5]; in_n3 = out_n3 ^ synd[6];
					end
					if(synd_a[2] > synd_a[1]) begin
						in_n0 = out_n0 ^ synd[3]; in_n1 = out_n1 ^ synd[4]; in_n2 = out_n2 ^ synd[5]; in_n3 = out_n3 ^ synd[6];
					end
					else begin
						in_n0 = out_n0 ^ synd[2]; in_n1 = out_n1 ^ synd[3]; in_n2 = out_n2 ^ synd[4]; in_n3 = out_n3 ^ synd[5];
					end
				end 
				3: begin // 7-2 8-1  6aok
					if(eq5[3] > eq6[3]) begin
						in_a0_tmp = eq5[3] - eq6[3] + eq6[2]; // Eq8 s2
						in_a1_tmp = eq5[3] - eq6[3] + eq6[1]; // Eq8 s1
						in_a2_tmp = eq5[3] - eq6[3] + eq6[0]; // Eq8 s0
					//	in_n0 = out_n0 ^ eq5_n[2]; in_n1 = out_n1 ^ eq5_n[1]; in_n2 = out_n2 ^ eq5_n[0]; 
					end
					else begin
						in_a0_tmp = eq6[3] - eq5[3] + eq5[2]; // Eq8 s2
						in_a1_tmp = eq6[3] - eq5[3] + eq5[1]; // Eq8 s1
						in_a2_tmp = eq6[3] - eq5[3] + eq5[0]; // Eq8 s0
					//	in_n0 = out_n0 ^ eq6_n[2]; in_n1 = out_n1 ^ eq6_n[1]; in_n2 = out_n2 ^ eq6_n[0]; 
					end
					if(synd_a[3] > synd_a[2]) begin
						in_n0 = out_n0 ^ synd[4]; in_n1 = out_n1 ^ synd[5]; in_n2 = out_n2 ^ synd[6]; in_n3 = out_n3 ^ synd[7];
					end
					else begin
						in_n0 = out_n0 ^ synd[3]; in_n1 = out_n1 ^ synd[4]; in_n2 = out_n2 ^ synd[5]; in_n3 = out_n3 ^ synd[6];
					end
				end
				4: begin //8-2 9-1 7aok
					if(eq6[3] > eq7[3]) begin
						in_a0_tmp = eq6[3] - eq7[3] + eq7[2]; // Eq9 s2
						in_a1_tmp = eq6[3] - eq7[3] + eq7[1]; // Eq9 s1
						in_a2_tmp = eq6[3] - eq7[3] + eq7[0]; // Eq9 s0
					//	in_n0 = out_n0 ^ eq6_n[2]; in_n1 = out_n1 ^ eq6_n[1]; in_n2 = out_n2 ^ eq6_n[0]; 
					end
					else begin
						in_a0_tmp = eq7[3] - eq6[3] + eq6[2]; // Eq9 s2
						in_a1_tmp = eq7[3] - eq6[3] + eq6[1]; // Eq9 s1
						in_a2_tmp = eq7[3] - eq6[3] + eq6[0]; // Eq9 s0 
					//	in_n0 = out_n0 ^ eq7_n[2]; in_n1 = out_n1 ^ eq7_n[1]; in_n2 = out_n2 ^ eq7_n[0]; 
					end
					if(eq5[3] > eq6[3]) begin
						in_n0 = out_n0 ^ eq5_n[2]; in_n1 = out_n1 ^ eq5_n[1]; in_n2 = out_n2 ^ eq5_n[0]; 
					end
					else begin
						in_n0 = out_n0 ^ eq6_n[2]; in_n1 = out_n1 ^ eq6_n[1]; in_n2 = out_n2 ^ eq6_n[0];
					end
				end
				5: begin // 9-2 
					if(eq6[3] > eq7[3]) begin
						in_n0 = out_n0 ^ eq6_n[2]; in_n1 = out_n1 ^ eq6_n[1]; in_n2 = out_n2 ^ eq6_n[0]; 
					end
					else begin
						in_n0 = out_n0 ^ eq7_n[2]; in_n1 = out_n1 ^ eq7_n[1]; in_n2 = out_n2 ^ eq7_n[0]; 
					end
					/*
					if(eq8[2] > eq9[2]) begin
						in_a0_tmp = eq8[2] - eq9[2] + eq9[1]; // Eq10 s1
						in_a1_tmp = eq8[2] - eq9[2] + eq9[0]; // Eq10 s0
						in_n0 = out_n0 ^ eq8_n[1]; in_n1 = out_n1 ^ eq8_n[0]; 
					end
					else begin
						in_a0_tmp = eq9[2] - eq8[2] + eq8[1]; // Eq10 s1
						in_a1_tmp = eq9[2] - eq8[2] + eq8[0]; // Eq10 s0
						in_n0 = out_n0 ^ eq9_n[1]; in_n1 = out_n1 ^ eq9_n[0]; 
					end
					if(out_a1 > out_a0) sig1_nx = out_a1 - out_a0;
					else sig1_nx = {1'b1, (out_a1 - 1'b1)} - out_a0;
					*/
				end
				6: begin //add  10-1
					if(eq8[2] > eq9[2]) begin
						in_a0_tmp = eq8[2] - eq9[2] + eq9[1]; // Eq10 s1
						in_a1_tmp = eq8[2] - eq9[2] + eq9[0]; // Eq10 s0
					//	in_n0 = out_n0 ^ eq8_n[1]; in_n1 = out_n1 ^ eq8_n[0]; 
					end
					else begin
						in_a0_tmp = eq9[2] - eq8[2] + eq8[1]; // Eq10 s1
						in_a1_tmp = eq9[2] - eq8[2] + eq8[0]; // Eq10 s0
					//	in_n0 = out_n0 ^ eq9_n[1]; in_n1 = out_n1 ^ eq9_n[0]; 
					end
					//if(out_a1 > out_a0) sig1_nx = out_a1 - out_a0;
					//else sig1_nx = {1'b1, (out_a1 - 1'b1)} - out_a0;
				end
				/*
				6: begin // 
					in_a0_tmp = sig1 + eq8[1];
					in_a1_tmp = eq8[0];
					in_n0 = out_n0 ^ out_n1;
					if(out_a0 > eq8[2]) sig2_nx = out_a0 - eq8[2];
					else sig2_nx = {1'b1, (out_a0 - 1'b1)} - eq8[2];
				end*/
				7: begin // add 10-2 sigma1
					if(eq8[2] > eq9[2]) begin
						in_n0 = out_n0 ^ eq8_n[1]; in_n1 = out_n1 ^ eq8_n[0]; 
					end
					else begin
						in_n0 = out_n0 ^ eq9_n[1]; in_n1 = out_n1 ^ eq9_n[0]; 
					end
					if(out_a1 > out_a0) sig1_nx = out_a1 - out_a0;
					else sig1_nx = {1'b1, (out_a1 - 1'b1)} - out_a0;
				end
				/*
				7: begin
					in_a0_tmp = sig2 + eq5[2];
					in_a1_tmp = sig1 + eq5[1];
					in_a2_tmp = eq5[0];
					in_n0 = out_n0 ^ out_n1 ^ out_n2;
					if(out_a0 > eq5[3]) sig3_nx = out_a0 - eq5[3];
					else sig3_nx = {1'b1, (out_a0 - 1'b1)} - eq5[3];
				end*/
				8: begin //add sigma2-1
					in_a0_tmp = sig1 + eq8[1];
					in_a1_tmp = eq8[0];
				end
				/*
				8: begin
					in_a0_tmp = sig3 + synd_a[1];
					in_a1_tmp = sig2 + synd_a[2];
					in_a2_tmp = sig1 + synd_a[3];
					in_a3_tmp = synd_a[4];
					in_n0 = out_n0 ^ out_n1 ^ out_n2 ^ out_n3;
					if(out_a0 > synd_a[0]) sig4_nx = out_a0 - synd_a[0];
					else sig4_nx = {1'b1, (out_a0 - 1'b1)} - synd_a[0];
					error_exist = 1;
					cnt_S_nx = 0;
				end
				*/
				9: begin //add sigma2-2 
					in_n0 = out_n0 ^ out_n1;
					if(out_a0 > eq8[2]) sig2_nx = out_a0 - eq8[2];
					else sig2_nx = {1'b1, (out_a0 - 1'b1)} - eq8[2];
				end
				10: begin //add sigma3-1
					in_a0_tmp = sig2 + eq5[2];
					in_a1_tmp = sig1 + eq5[1];
					in_a2_tmp = eq5[0];
				end
				11: begin //add sigma3-2
					in_n0 = out_n0 ^ out_n1 ^ out_n2;
					if(out_a0 > eq5[3]) sig3_nx = out_a0 - eq5[3];
					else sig3_nx = {1'b1, (out_a0 - 1'b1)} - eq5[3];
				end
				12: begin //add sigma4-1
					in_a0_tmp = sig3 + synd_a[1];
					in_a1_tmp = sig2 + synd_a[2];
					in_a2_tmp = sig1 + synd_a[3];
					in_a3_tmp = synd_a[4];
				end
				13: begin
					in_n0 = out_n0 ^ out_n1 ^ out_n2 ^ out_n3;
					if(out_a0 > synd_a[0]) sig4_nx = out_a0 - synd_a[0];
					else sig4_nx = {1'b1, (out_a0 - 1'b1)} - synd_a[0];
					error_exist = 1;
					cnt_S_nx = 0;
				end
				default: in_n0 = 0;
			endcase								
		end
		EXTRA: begin
			if(cnt_S == 0) cnt_S_nx = cnt_S + 1;
			else cnt_S_nx = 0;
			for(i = 0; i < 7; i = i + 1) begin // 7
				synd_nx[i] = synd[i];	
				synd_a_nx[i] = synd_a[i];
			end
			in_a0_tmp = sig4;
			if(cnt_S == 1) begin
				synd_nx[7] = out_n0;
				error_exist = 1;
			end
			else synd_nx[7] = synd[7];
			synd_a_nx[7] = synd_a[7];
		end
		LOC: begin
			a4_cnt_nx = a4_cnt + 4; a3_cnt_nx = a3_cnt + 3; a2_cnt_nx = a2_cnt + 2; 
			for(i = 0; i < 8; i = i + 1) begin 
				synd_nx[i] = synd[i];	
				synd_a_nx[i] = synd_a[i];
			end
			in_a0_tmp = sig3 + cnt_S;	
			in_a1_tmp = sig2 + a2_cnt;
			in_a2_tmp = sig1 + a3_cnt;
			in_a3_tmp = a4_cnt;
			
			loc_use = synd[7] ^ out_n0 ^ out_n1 ^ out_n2 ^ out_n3;
		//	if(cnt_S != 0) begin
			if(loc_use  == 0) begin
				if(cnt_loc == 3) begin
					error_exist = 1;
					cnt_S_nx = 0;
				end
				else cnt_S_nx = cnt_S + 1;
			end
			else if(cnt_S == 44) begin
				cnt_S_nx = 0;
				error_exist = 1;
			end
			else begin
				error_exist = 0;
				cnt_S_nx = cnt_S + 1;
			end
		//	end
		//	else cnt_S_nx = cnt_S + 1;
			if(loc_use == 0) begin
				cnt_loc_nx = cnt_loc + 1;
				case(cnt_loc) // synopsys parallel_case
					0: loc1_nx = cnt_S - 1;
					1: loc2_nx = cnt_S - 1;
					2: loc3_nx = cnt_S - 1;
					3: loc4_nx = cnt_S - 1;
					default: loc1_nx = cnt_S - 1;
				endcase
			end
			else if(cnt_S == 44) begin
				if(loc4 == 0) begin
					loc1_nx = loc4;
					loc2_nx = loc1;
					loc3_nx = loc2;
					loc4_nx = loc3;
				end
			end
		end
		CORRECT: begin
			cnt_S_nx = cnt_S + 1;
			for(i = 0; i < 8; i = i + 1) begin
				synd_nx[i] = synd[i];	
				synd_a_nx[i] = synd_a[i];
			end
			case(cnt_S) // synopsys parallel_case
				0: begin
					in_a0_tmp = loc1;
					in_a1_tmp = /*loc1*2;*/{2'b0,loc1}<<1;	
					in_a2_tmp = /*loc1*3;*/({2'b0,loc1}<<1) + loc1;
					in_a3_tmp = /*loc1*4;*/{2'b0,loc1}<<2;
				end
				1: begin
					in_a0_tmp = loc2;
					in_a1_tmp = /*loc2*2;*/{2'b0,loc2}<<1;	
					in_a2_tmp = /*loc2*3;*/({2'b0,loc2}<<1) + loc2;
					in_a3_tmp = /*loc2*4;*/{2'b0,loc2}<<2;
				end
				2: begin
					in_a0_tmp = loc3;
					in_a1_tmp = /*loc3*2;*/{2'b0,loc3}<<1;	
					in_a2_tmp = /*loc3*3;*/({2'b0,loc3}<<1) + loc3;
					in_a3_tmp = /*loc3*4;*/{2'b0,loc3}<<2;
				end
				3: begin
					in_a0_tmp = loc4;
					in_a1_tmp = /*loc4*2;*/{2'b0,loc4}<<1;	
					in_a2_tmp = /*loc4*3;*/({2'b0,loc4}<<1) + loc4;
					in_a3_tmp = /*loc4*4;*/{2'b0,loc4}<<2;
				end
				4: begin //5-1
					in_a0_tmp = loc1 + loc2; // Eq5 s3
					in_a1_tmp = loc1 + loc3; // Eq5 s2
					in_a2_tmp = loc1 + loc4; // Eq5 s1
					in_a3_tmp = loc1 + synd_a[0]; // Eq5 s0
				//	in_n0 = out_n0 ^ eq2_n[2]; in_n1 = out_n1 ^ eq2_n[1]; in_n2 = out_n2 ^ eq2_n[0]; in_n3 = out_n3 ^ synd[1];
				end
				5: begin //5-2 6-1
					in_a0_tmp = loc1 + (loc2<<1); // Eq5 s3
					in_a1_tmp = loc1 + (loc3<<1); // Eq5 s2
					in_a2_tmp = loc1 + (loc4<<1); // Eq5 s1
					in_a3_tmp = loc1 + synd_a[1]; // Eq5 s0
					in_n0 = out_n0 ^ eq2_n[2]; in_n1 = out_n1 ^ eq2_n[1]; in_n2 = out_n2 ^ eq2_n[0]; in_n3 = out_n3 ^ synd[1];
				//	in_n0 = out_n0 ^ eq3_n[2]; in_n1 = out_n1 ^ eq3_n[1]; in_n2 = out_n2 ^ eq3_n[0]; in_n3 = out_n3 ^ synd[2];
				end
				6: begin //6-2 7-1 5aok
					in_a0_tmp = loc1 + (loc2<<1) + loc2; // Eq5 s3
					in_a1_tmp = loc1 + (loc3<<1) + loc3; // Eq5 s2
					in_a2_tmp = loc1 + (loc4<<1) + loc4; // Eq5 s1
					in_a3_tmp = loc1 + synd_a[2]; // Eq5 s0
					in_n0 = out_n0 ^ eq3_n[2]; in_n1 = out_n1 ^ eq3_n[1]; in_n2 = out_n2 ^ eq3_n[0]; in_n3 = out_n3 ^ synd[2];
				//	in_n0 = out_n0 ^ eq4_n[2]; in_n1 = out_n1 ^ eq4_n[1]; in_n2 = out_n2 ^ eq4_n[0]; in_n3 = out_n3 ^ synd[3];
				end
				7: begin //7-2 8-1 6aok
					if(eq5[3] > eq6[3]) begin
						in_a0_tmp = eq5[3] - eq6[3] + eq6[2]; // Eq8 s2
						in_a1_tmp = eq5[3] - eq6[3] + eq6[1]; // Eq8 s1
						in_a2_tmp = eq5[3] - eq6[3] + eq6[0]; // Eq8 s0
					//	in_n0 = out_n0 ^ eq5_n[2]; in_n1 = out_n1 ^ eq5_n[1]; in_n2 = out_n2 ^ eq5_n[0]; 
					end
					else begin
						in_a0_tmp = eq6[3] - eq5[3] + eq5[2]; // Eq8 s2
						in_a1_tmp = eq6[3] - eq5[3] + eq5[1]; // Eq8 s1
						in_a2_tmp = eq6[3] - eq5[3] + eq5[0]; // Eq8 s0
					//	in_n0 = out_n0 ^ eq6_n[2]; in_n1 = out_n1 ^ eq6_n[1]; in_n2 = out_n2 ^ eq6_n[0]; 
					end
					in_n0 = out_n0 ^ eq4_n[2]; in_n1 = out_n1 ^ eq4_n[1]; in_n2 = out_n2 ^ eq4_n[0]; in_n3 = out_n3 ^ synd[3];
				end
				8: begin //8-2 9-1 7aok
					if(eq6[3] > eq7[3]) begin
						in_a0_tmp = eq6[3] - eq7[3] + eq7[2]; // Eq9 s2
						in_a1_tmp = eq6[3] - eq7[3] + eq7[1]; // Eq9 s1
						in_a2_tmp = eq6[3] - eq7[3] + eq7[0]; // Eq9 s0
					//	in_n0 = out_n0 ^ eq6_n[2]; in_n1 = out_n1 ^ eq6_n[1]; in_n2 = out_n2 ^ eq6_n[0]; 
					end
					else begin
						in_a0_tmp = eq7[3] - eq6[3] + eq6[2]; // Eq9 s2
						in_a1_tmp = eq7[3] - eq6[3] + eq6[1]; // Eq9 s1
						in_a2_tmp = eq7[3] - eq6[3] + eq6[0]; // Eq9 s0
					//	in_n0 = out_n0 ^ eq7_n[2]; in_n1 = out_n1 ^ eq7_n[1]; in_n2 = out_n2 ^ eq7_n[0]; 
					end
					if(eq5[3] > eq6[3]) begin
						in_n0 = out_n0 ^ eq5_n[2]; in_n1 = out_n1 ^ eq5_n[1]; in_n2 = out_n2 ^ eq5_n[0]; 
					end
					else begin
						in_n0 = out_n0 ^ eq6_n[2]; in_n1 = out_n1 ^ eq6_n[1]; in_n2 = out_n2 ^ eq6_n[0]; 
					end
				end
				9: begin //9-2
					if(eq6[3] > eq7[3]) begin
						in_n0 = out_n0 ^ eq6_n[2]; in_n1 = out_n1 ^ eq6_n[1]; in_n2 = out_n2 ^ eq6_n[0]; 
					end
					else begin
						in_n0 = out_n0 ^ eq7_n[2]; in_n1 = out_n1 ^ eq7_n[1]; in_n2 = out_n2 ^ eq7_n[0]; 
					end
				end
				/*
				9: begin 
					if(eq8[2] > eq9[2]) begin
						in_a0_tmp = eq8[2] - eq9[2] + eq9[1]; // Eq10 s1
						in_a1_tmp = eq8[2] - eq9[2] + eq9[0]; // Eq10 s0
						in_n0 = out_n0 ^ eq8_n[1]; in_n1 = out_n1 ^ eq8_n[0]; 
					end
					else begin
						in_a0_tmp = eq9[2] - eq8[2] + eq8[1]; // Eq10 s1
						in_a1_tmp = eq9[2] - eq8[2] + eq8[0]; // Eq10 s0
						in_n0 = out_n0 ^ eq9_n[1]; in_n1 = out_n1 ^ eq9_n[0]; 
					end
					if(out_a1 > out_a0) sig1_nx = out_a1 - out_a0;
					else sig1_nx = {1'b1, (out_a1 - 1'b1)} - out_a0;
				end*/
				10: begin //add  10-1
					if(eq8[2] > eq9[2]) begin
						in_a0_tmp = eq8[2] - eq9[2] + eq9[1]; // Eq10 s1
						in_a1_tmp = eq8[2] - eq9[2] + eq9[0]; // Eq10 s0
					//	in_n0 = out_n0 ^ eq8_n[1]; in_n1 = out_n1 ^ eq8_n[0]; 
					end
					else begin
						in_a0_tmp = eq9[2] - eq8[2] + eq8[1]; // Eq10 s1
						in_a1_tmp = eq9[2] - eq8[2] + eq8[0]; // Eq10 s0
					//	in_n0 = out_n0 ^ eq9_n[1]; in_n1 = out_n1 ^ eq9_n[0]; 
					end
					//if(out_a1 > out_a0) sig1_nx = out_a1 - out_a0;
					//else sig1_nx = {1'b1, (out_a1 - 1'b1)} - out_a0;
				end
				/*10: begin
					in_a0_tmp = sig1 + eq8[1];
					in_a1_tmp = eq8[0];
					in_n0 = out_n0 ^ out_n1;
					if(out_a0 > eq8[2]) sig2_nx = out_a0 - eq8[2];
					else sig2_nx = {1'b1, (out_a0 - 1'b1)} - eq8[2];
				end*/
				11: begin // add 10-2 sigma1
					if(eq8[2] > eq9[2]) begin
						in_n0 = out_n0 ^ eq8_n[1]; in_n1 = out_n1 ^ eq8_n[0]; 
					end
					else begin
						in_n0 = out_n0 ^ eq9_n[1]; in_n1 = out_n1 ^ eq9_n[0]; 
					end
					if(out_a1 > out_a0) sig1_nx = out_a1 - out_a0;
					else sig1_nx = {1'b1, (out_a1 - 1'b1)} - out_a0;
				end
				/*11: begin
					in_a0_tmp = sig2 + eq5[2];
					in_a1_tmp = sig1 + eq5[1];
					in_a2_tmp = eq5[0];
					in_n0 = out_n0 ^ out_n1 ^ out_n2;
					if(out_a0 > eq5[3]) sig3_nx = out_a0 - eq5[3];
					else sig3_nx = {1'b1, (out_a0 - 1'b1)} - eq5[3];
				end*/
				12: begin //add sigma2-1
					in_a0_tmp = sig1 + eq8[1];
					in_a1_tmp = eq8[0];
				end
				/*12: begin
					in_a0_tmp = sig3 + loc2;
					in_a1_tmp = sig2 + loc3;
					in_a2_tmp = sig1 + loc4;
					in_a3_tmp = synd_a[0];
					in_n0 = out_n0 ^ out_n1 ^ out_n2 ^ out_n3;
					if(out_a0 > {2'b0, loc1}) sig4_nx = out_a0 - {2'b0, loc1};
					else sig4_nx = {1'b1, (out_a0 - 1'b1)} - {2'b0, loc1};
					error_exist = 1;
					cnt_S_nx = 0;
				end*/
				13: begin //add sigma2-2 
					in_n0 = out_n0 ^ out_n1;
					if(out_a0 > eq8[2]) sig2_nx = out_a0 - eq8[2];
					else sig2_nx = {1'b1, (out_a0 - 1'b1)} - eq8[2];
				end
				14: begin //add sigma3-1
					in_a0_tmp = sig2 + eq5[2];
					in_a1_tmp = sig1 + eq5[1];
					in_a2_tmp = eq5[0];
				end
				15: begin //add sigma3-2
					in_n0 = out_n0 ^ out_n1 ^ out_n2;
					if(out_a0 > eq5[3]) sig3_nx = out_a0 - eq5[3];
					else sig3_nx = {1'b1, (out_a0 - 1'b1)} - eq5[3];
				end
				16: begin //add sigma4-1
					in_a0_tmp = sig3 + loc2;
					in_a1_tmp = sig2 + loc3;
					in_a2_tmp = sig1 + loc4;
					in_a3_tmp = synd_a[0];
				end
				17: begin
					in_n0 = out_n0 ^ out_n1 ^ out_n2 ^ out_n3;
					if(out_a0 > {2'b0, loc1}) sig4_nx = out_a0 - {2'b0, loc1};
					else sig4_nx = {1'b1, (out_a0 - 1'b1)} - {2'b0, loc1};
					error_exist = 1;
					cnt_S_nx = 0;
				end
				default: in_n0 = 0;
			endcase								
		end
		FINAL: begin
			if(cnt_S == 1) cnt_S_nx = 0;
			else cnt_S_nx = cnt_S + 1;
			for(i = 0; i < 8; i = i + 1) begin
				synd_nx[i] = synd[i];	
				synd_a_nx[i] = synd_a[i];
			end
			in_a0_tmp = sig4 + loc1;
			in_a1_tmp = sig3 + loc2;
			in_a2_tmp = sig2 + loc3;
			in_a3_tmp = sig1 + loc4;
			if(cnt_S == 1) begin
				error_valid = 1;
				sig1_nx = out_n0;
				sig2_nx = out_n1;
				sig3_nx = out_n2;
				sig4_nx = out_n3;
			end
		end
		default: begin
			for(i = 0; i < 8; i = i + 1) begin
				synd_nx[i] = synd[i];	
				synd_a_nx[i] = synd_a[i];
			end	
		end
	endcase
end	

always@* begin
	if(in_a0_tmp[8]) in_a0 = in_a0_tmp[7:0] + 1; 
	else in_a0 = in_a0_tmp[7:0];
	if(in_a1_tmp[8]) in_a1 = in_a1_tmp[7:0] + 1; 
	else in_a1 = in_a1_tmp[7:0];
	if(in_a2_tmp[8]) in_a2 = in_a2_tmp[7:0] + 1; 
	else in_a2 = in_a2_tmp[7:0];
	if(in_a3_tmp[9]) in_a3 = in_a3_tmp[7:0] + 2;			 
	else if(in_a3_tmp[8]) in_a3 = in_a3_tmp[7:0] + 1; 		
	else in_a3 = in_a3_tmp[7:0];
end

always@* begin
	if(state == SIGMA) begin
		case(cnt_S) // synopsys parallel_case
			1: begin
				eq1_n_nx[2] = eq1_n[2]; eq1_n_nx[1] = eq1_n[1]; eq1_n_nx[0] = eq1_n[0];
				eq2_n_nx[2] = eq2_n[2]; eq2_n_nx[1] = eq2_n[1]; eq2_n_nx[0] = eq2_n[0];
				eq3_n_nx[2] = eq3_n[2]; eq3_n_nx[1] = eq3_n[1]; eq3_n_nx[0] = eq3_n[0];
				eq4_n_nx[2] = eq4_n[2]; eq4_n_nx[1] = eq4_n[1]; eq4_n_nx[0] = eq4_n[0];
				eq5_nx[3] = out_a0; eq5_nx[2] = out_a1; eq5_nx[1] = out_a2; eq5_nx[0] = out_a3;
				eq6_nx[3] = eq6[3]; eq6_nx[2] = eq6[2]; eq6_nx[1] = eq6[1]; eq6_nx[0] = eq6[0];
				eq7_nx[3] = eq7[3]; eq7_nx[2] = eq7[2]; eq7_nx[1] = eq7[1]; eq7_nx[0] = eq7[0];
				eq5_n_nx[3] = in_n0; eq5_n_nx[2] = in_n1; eq5_n_nx[1] = in_n2; eq5_n_nx[0] = in_n3;
				eq6_n_nx[3] = eq6_n[3]; eq6_n_nx[2] = eq6_n[2]; eq6_n_nx[1] = eq6_n[1]; eq6_n_nx[0] = eq6_n[0];
				eq7_n_nx[3] = eq7_n[3]; eq7_n_nx[2] = eq7_n[2]; eq7_n_nx[1] = eq7_n[1]; eq7_n_nx[0] = eq7_n[0];
				eq8_nx[2] = eq8[2]; eq8_nx[1] = eq8[1]; eq8_nx[0] = eq8[0]; 
				eq9_nx[2] = eq9[2]; eq9_nx[1] = eq9[1]; eq9_nx[0] = eq9[0]; 
				eq8_n_nx[2] = eq8_n[2]; eq8_n_nx[1] = eq8_n[1]; eq8_n_nx[0] = eq8_n[0];
				eq9_n_nx[2] = eq9_n[2]; eq9_n_nx[1] = eq9_n[1]; eq9_n_nx[0] = eq9_n[0];
			end
			2: begin
				eq1_n_nx[2] = eq1_n[2]; eq1_n_nx[1] = eq1_n[1]; eq1_n_nx[0] = eq1_n[0];
				eq2_n_nx[2] = eq2_n[2]; eq2_n_nx[1] = eq2_n[1]; eq2_n_nx[0] = eq2_n[0];
				eq3_n_nx[2] = eq3_n[2]; eq3_n_nx[1] = eq3_n[1]; eq3_n_nx[0] = eq3_n[0];
				eq4_n_nx[2] = eq4_n[2]; eq4_n_nx[1] = eq4_n[1]; eq4_n_nx[0] = eq4_n[0];
				eq5_nx[3] = eq5[3]; eq5_nx[2] = eq5[2]; eq5_nx[1] = eq5[1]; eq5_nx[0] = eq5[0];
				eq6_nx[3] = out_a0; eq6_nx[2] = out_a1; eq6_nx[1] = out_a2; eq6_nx[0] = out_a3;
				eq7_nx[3] = eq7[3]; eq7_nx[2] = eq7[2]; eq7_nx[1] = eq7[1]; eq7_nx[0] = eq7[0];
				eq5_n_nx[3] = eq5_n[3]; eq5_n_nx[2] = eq5_n[2]; eq5_n_nx[1] = eq5_n[1]; eq5_n_nx[0] = eq5_n[0];
				eq6_n_nx[3] = in_n0; eq6_n_nx[2] = in_n1; eq6_n_nx[1] = in_n2; eq6_n_nx[0] = in_n3;
				eq7_n_nx[3] = eq7_n[3]; eq7_n_nx[2] = eq7_n[2]; eq7_n_nx[1] = eq7_n[1]; eq7_n_nx[0] = eq7_n[0];
				eq8_nx[2] = eq8[2]; eq8_nx[1] = eq8[1]; eq8_nx[0] = eq8[0]; 
				eq9_nx[2] = eq9[2]; eq9_nx[1] = eq9[1]; eq9_nx[0] = eq9[0]; 
				eq8_n_nx[2] = eq8_n[2]; eq8_n_nx[1] = eq8_n[1]; eq8_n_nx[0] = eq8_n[0];
				eq9_n_nx[2] = eq9_n[2]; eq9_n_nx[1] = eq9_n[1]; eq9_n_nx[0] = eq9_n[0];
			end
			3: begin
				eq1_n_nx[2] = eq1_n[2]; eq1_n_nx[1] = eq1_n[1]; eq1_n_nx[0] = eq1_n[0];
				eq2_n_nx[2] = eq2_n[2]; eq2_n_nx[1] = eq2_n[1]; eq2_n_nx[0] = eq2_n[0];
				eq3_n_nx[2] = eq3_n[2]; eq3_n_nx[1] = eq3_n[1]; eq3_n_nx[0] = eq3_n[0];
				eq4_n_nx[2] = eq4_n[2]; eq4_n_nx[1] = eq4_n[1]; eq4_n_nx[0] = eq4_n[0];
				eq5_nx[3] = eq5[3]; eq5_nx[2] = eq5[2]; eq5_nx[1] = eq5[1]; eq5_nx[0] = eq5[0];
				eq6_nx[3] = eq6[3]; eq6_nx[2] = eq6[2]; eq6_nx[1] = eq6[1]; eq6_nx[0] = eq6[0];
				eq7_nx[3] = out_a0; eq7_nx[2] = out_a1; eq7_nx[1] = out_a2; eq7_nx[0] = out_a3;
				eq5_n_nx[3] = eq5_n[3]; eq5_n_nx[2] = eq5_n[2]; eq5_n_nx[1] = eq5_n[1]; eq5_n_nx[0] = eq5_n[0];
				eq6_n_nx[3] = eq6_n[3]; eq6_n_nx[2] = eq6_n[2]; eq6_n_nx[1] = eq6_n[1]; eq6_n_nx[0] = eq6_n[0];
				eq7_n_nx[3] = in_n0; eq7_n_nx[2] = in_n1; eq7_n_nx[1] = in_n2; eq7_n_nx[0] = in_n3;
				eq8_nx[2] = eq8[2]; eq8_nx[1] = eq8[1]; eq8_nx[0] = eq8[0];
				eq9_nx[2] = eq9[2]; eq9_nx[1] = eq9[1]; eq9_nx[0] = eq9[0]; 
				eq8_n_nx[2] = eq8_n[2]; eq8_n_nx[1] = eq9_n[1]; eq8_n_nx[0] = eq9_n[0];
				eq9_n_nx[2] = eq9_n[2]; eq9_n_nx[1] = eq9_n[1]; eq9_n_nx[0] = eq9_n[0];
			end
			4: begin
				eq1_n_nx[2] = eq1_n[2]; eq1_n_nx[1] = eq1_n[1]; eq1_n_nx[0] = eq1_n[0];
				eq2_n_nx[2] = eq2_n[2]; eq2_n_nx[1] = eq2_n[1]; eq2_n_nx[0] = eq2_n[0];
				eq3_n_nx[2] = eq3_n[2]; eq3_n_nx[1] = eq3_n[1]; eq3_n_nx[0] = eq3_n[0];
				eq4_n_nx[2] = eq4_n[2]; eq4_n_nx[1] = eq4_n[1]; eq4_n_nx[0] = eq4_n[0];
				eq5_nx[3] = eq5[3]; eq5_nx[2] = eq5[2]; eq5_nx[1] = eq5[1]; eq5_nx[0] = eq5[0];
				eq6_nx[3] = eq6[3]; eq6_nx[2] = eq6[2]; eq6_nx[1] = eq6[1]; eq6_nx[0] = eq6[0];
				eq7_nx[3] = eq7[3]; eq7_nx[2] = eq7[2]; eq7_nx[1] = eq7[1]; eq7_nx[0] = eq7[0];
				eq5_n_nx[3] = eq5_n[3]; eq5_n_nx[2] = eq5_n[2]; eq5_n_nx[1] = eq5_n[1]; eq5_n_nx[0] = eq5_n[0];
				eq6_n_nx[3] = eq6_n[3]; eq6_n_nx[2] = eq6_n[2]; eq6_n_nx[1] = eq6_n[1]; eq6_n_nx[0] = eq6_n[0];
				eq7_n_nx[3] = eq7_n[3]; eq7_n_nx[2] = eq7_n[2]; eq7_n_nx[1] = eq7_n[1]; eq7_n_nx[0] = eq7_n[0];
				eq8_nx[2] = out_a0; eq8_nx[1] = out_a1; eq8_nx[0] = out_a2;
				eq9_nx[2] = eq9[2]; eq9_nx[1] = eq9[1]; eq9_nx[0] = eq9[0]; 
				eq8_n_nx[2] = in_n0; eq8_n_nx[1] = in_n1; eq8_n_nx[0] = in_n2;
				eq9_n_nx[2] = eq9_n[2]; eq9_n_nx[1] = eq9_n[1]; eq9_n_nx[0] = eq9_n[0];
			end
			5: begin
				eq1_n_nx[2] = eq1_n[2]; eq1_n_nx[1] = eq1_n[1]; eq1_n_nx[0] = eq1_n[0];
				eq2_n_nx[2] = eq2_n[2]; eq2_n_nx[1] = eq2_n[1]; eq2_n_nx[0] = eq2_n[0];
				eq3_n_nx[2] = eq3_n[2]; eq3_n_nx[1] = eq3_n[1]; eq3_n_nx[0] = eq3_n[0];
				eq4_n_nx[2] = eq4_n[2]; eq4_n_nx[1] = eq4_n[1]; eq4_n_nx[0] = eq4_n[0];
				eq5_nx[3] = eq5[3]; eq5_nx[2] = eq5[2]; eq5_nx[1] = eq5[1]; eq5_nx[0] = eq5[0];
				eq6_nx[3] = eq6[3]; eq6_nx[2] = eq6[2]; eq6_nx[1] = eq6[1]; eq6_nx[0] = eq6[0];
				eq7_nx[3] = eq7[3]; eq7_nx[2] = eq7[2]; eq7_nx[1] = eq7[1]; eq7_nx[0] = eq7[0];
				eq5_n_nx[3] = eq5_n[3]; eq5_n_nx[2] = eq5_n[2]; eq5_n_nx[1] = eq5_n[1]; eq5_n_nx[0] = eq5_n[0];
				eq6_n_nx[3] = eq6_n[3]; eq6_n_nx[2] = eq6_n[2]; eq6_n_nx[1] = eq6_n[1]; eq6_n_nx[0] = eq6_n[0];
				eq7_n_nx[3] = eq7_n[3]; eq7_n_nx[2] = eq7_n[2]; eq7_n_nx[1] = eq7_n[1]; eq7_n_nx[0] = eq7_n[0];
				eq8_nx[2] = eq8[2]; eq8_nx[1] = eq8[1]; eq8_nx[0] = eq8[0]; 
				eq9_nx[2] = out_a0; eq9_nx[1] = out_a1; eq9_nx[0] = out_a2;
				eq8_n_nx[2] = eq8_n[2]; eq8_n_nx[1] = eq8_n[1]; eq8_n_nx[0] = eq8_n[0];
				eq9_n_nx[2] = in_n0; eq9_n_nx[1] = in_n1; eq9_n_nx[0] = in_n2;
			end 
			default: begin
				eq1_n_nx[2] = eq1_n[2]; eq1_n_nx[1] = eq1_n[1]; eq1_n_nx[0] = eq1_n[0];
				eq2_n_nx[2] = eq2_n[2]; eq2_n_nx[1] = eq2_n[1]; eq2_n_nx[0] = eq2_n[0];
				eq3_n_nx[2] = eq3_n[2]; eq3_n_nx[1] = eq3_n[1]; eq3_n_nx[0] = eq3_n[0];
				eq4_n_nx[2] = eq4_n[2]; eq4_n_nx[1] = eq4_n[1]; eq4_n_nx[0] = eq4_n[0];
				eq5_nx[3] = eq5[3]; eq5_nx[2] = eq5[2]; eq5_nx[1] = eq5[1]; eq5_nx[0] = eq5[0];
				eq6_nx[3] = eq6[3]; eq6_nx[2] = eq6[2]; eq6_nx[1] = eq6[1]; eq6_nx[0] = eq6[0];
				eq7_nx[3] = eq7[3]; eq7_nx[2] = eq7[2]; eq7_nx[1] = eq7[1]; eq7_nx[0] = eq7[0];
				eq5_n_nx[3] = eq5_n[3]; eq5_n_nx[2] = eq5_n[2]; eq5_n_nx[1] = eq5_n[1]; eq5_n_nx[0] = eq5_n[0];
				eq6_n_nx[3] = eq6_n[3]; eq6_n_nx[2] = eq6_n[2]; eq6_n_nx[1] = eq6_n[1]; eq6_n_nx[0] = eq6_n[0];
				eq7_n_nx[3] = eq7_n[3]; eq7_n_nx[2] = eq7_n[2]; eq7_n_nx[1] = eq7_n[1]; eq7_n_nx[0] = eq7_n[0];
				eq8_nx[2] = eq8[2]; eq8_nx[1] = eq8[1]; eq8_nx[0] = eq8[0]; 
				eq9_nx[2] = eq9[2]; eq9_nx[1] = eq9[1]; eq9_nx[0] = eq9[0]; 
				eq8_n_nx[2] = eq8_n[2]; eq8_n_nx[1] = eq8_n[1]; eq8_n_nx[0] = eq8_n[0];
				eq9_n_nx[2] = eq9_n[2]; eq9_n_nx[1] = eq9_n[1]; eq9_n_nx[0] = eq9_n[0];
			end
		endcase
	end
	else if(state == CORRECT) begin
		case(cnt_S) // synopsys parallel_case
			1: begin
				eq1_n_nx[2] = eq1_n[2]; eq1_n_nx[1] = eq1_n[1]; eq1_n_nx[0] = eq1_n[0];
				eq2_n_nx[2] = eq2_n[2]; eq2_n_nx[1] = eq2_n[1]; eq2_n_nx[0] = eq2_n[0];
				eq3_n_nx[2] = eq3_n[2]; eq3_n_nx[1] = eq3_n[1]; eq3_n_nx[0] = eq3_n[0];
				eq4_n_nx[2] = eq4_n[2]; eq4_n_nx[1] = eq4_n[1]; eq4_n_nx[0] = eq4_n[0];
				eq5_nx[3] = eq5[3]; eq5_nx[2] = eq5[2]; eq5_nx[1] = eq5[1]; eq5_nx[0] = eq5[0];
				eq6_nx[3] = eq6[3]; eq6_nx[2] = eq6[2]; eq6_nx[1] = eq6[1]; eq6_nx[0] = eq6[0];
				eq7_nx[3] = eq7[3]; eq7_nx[2] = eq7[2]; eq7_nx[1] = eq7[1]; eq7_nx[0] = eq7[0];
				eq5_n_nx[3] = eq5_n[3]; eq5_n_nx[2] = eq5_n[2]; eq5_n_nx[1] = eq5_n[1]; eq5_n_nx[0] = eq5_n[0];
				eq6_n_nx[3] = eq6_n[3]; eq6_n_nx[2] = eq6_n[2]; eq6_n_nx[1] = eq6_n[1]; eq6_n_nx[0] = eq6_n[0];
				eq7_n_nx[3] = eq7_n[3]; eq7_n_nx[2] = eq7_n[2]; eq7_n_nx[1] = eq7_n[1]; eq7_n_nx[0] = eq7_n[0];
				eq8_nx[2] = eq8[2]; eq8_nx[1] = eq8[1]; eq8_nx[0] = eq8[0]; 
				eq9_nx[2] = eq9[2]; eq9_nx[1] = eq9[1]; eq9_nx[0] = eq9[0]; 
				eq8_n_nx[2] = eq8_n[2]; eq8_n_nx[1] = eq8_n[1]; eq8_n_nx[0] = eq8_n[0];
				eq9_n_nx[2] = eq9_n[2]; eq9_n_nx[1] = eq9_n[1]; eq9_n_nx[0] = eq9_n[0];
			end
			2: begin
				eq1_n_nx[2] = out_n0; eq1_n_nx[1] = eq1_n[1]; eq1_n_nx[0] = eq1_n[0];
				eq2_n_nx[2] = out_n1; eq2_n_nx[1] = eq2_n[1]; eq2_n_nx[0] = eq2_n[0];
				eq3_n_nx[2] = out_n2; eq3_n_nx[1] = eq3_n[1]; eq3_n_nx[0] = eq3_n[0];
				eq4_n_nx[2] = out_n3; eq4_n_nx[1] = eq4_n[1]; eq4_n_nx[0] = eq4_n[0];
				eq5_nx[3] = eq5[3]; eq5_nx[2] = eq5[2]; eq5_nx[1] = eq5[1]; eq5_nx[0] = eq5[0];
				eq6_nx[3] = eq6[3]; eq6_nx[2] = eq6[2]; eq6_nx[1] = eq6[1]; eq6_nx[0] = eq6[0];
				eq7_nx[3] = eq7[3]; eq7_nx[2] = eq7[2]; eq7_nx[1] = eq7[1]; eq7_nx[0] = eq7[0];
				eq5_n_nx[3] = eq5_n[3]; eq5_n_nx[2] = eq5_n[2]; eq5_n_nx[1] = eq5_n[1]; eq5_n_nx[0] = eq5_n[0];
				eq6_n_nx[3] = eq6_n[3]; eq6_n_nx[2] = eq6_n[2]; eq6_n_nx[1] = eq6_n[1]; eq6_n_nx[0] = eq6_n[0];
				eq7_n_nx[3] = eq7_n[3]; eq7_n_nx[2] = eq7_n[2]; eq7_n_nx[1] = eq7_n[1]; eq7_n_nx[0] = eq7_n[0];
				eq8_nx[2] = eq8[2]; eq8_nx[1] = eq8[1]; eq8_nx[0] = eq8[0]; 
				eq9_nx[2] = eq9[2]; eq9_nx[1] = eq9[1]; eq9_nx[0] = eq9[0]; 
				eq8_n_nx[2] = eq8_n[2]; eq8_n_nx[1] = eq8_n[1]; eq8_n_nx[0] = eq8_n[0];
				eq9_n_nx[2] = eq9_n[2]; eq9_n_nx[1] = eq9_n[1]; eq9_n_nx[0] = eq9_n[0];
			end
			3: begin
				eq1_n_nx[2] = eq1_n[2]; eq1_n_nx[1] = out_n0; eq1_n_nx[0] = eq1_n[0];
				eq2_n_nx[2] = eq2_n[2]; eq2_n_nx[1] = out_n1; eq2_n_nx[0] = eq2_n[0];
				eq3_n_nx[2] = eq3_n[2]; eq3_n_nx[1] = out_n2; eq3_n_nx[0] = eq3_n[0];
				eq4_n_nx[2] = eq4_n[2]; eq4_n_nx[1] = out_n3; eq4_n_nx[0] = eq4_n[0];
				eq5_nx[3] = eq5[3]; eq5_nx[2] = eq5[2]; eq5_nx[1] = eq5[1]; eq5_nx[0] = eq5[0];
				eq6_nx[3] = eq6[3]; eq6_nx[2] = eq6[2]; eq6_nx[1] = eq6[1]; eq6_nx[0] = eq6[0];
				eq7_nx[3] = eq7[3]; eq7_nx[2] = eq7[2]; eq7_nx[1] = eq7[1]; eq7_nx[0] = eq7[0];
				eq5_n_nx[3] = eq5_n[3]; eq5_n_nx[2] = eq5_n[2]; eq5_n_nx[1] = eq5_n[1]; eq5_n_nx[0] = eq5_n[0];
				eq6_n_nx[3] = eq6_n[3]; eq6_n_nx[2] = eq6_n[2]; eq6_n_nx[1] = eq6_n[1]; eq6_n_nx[0] = eq6_n[0];
				eq7_n_nx[3] = eq7_n[3]; eq7_n_nx[2] = eq7_n[2]; eq7_n_nx[1] = eq7_n[1]; eq7_n_nx[0] = eq7_n[0];
				eq8_nx[2] = eq8[2]; eq8_nx[1] = eq8[1]; eq8_nx[0] = eq8[0]; 
				eq9_nx[2] = eq9[2]; eq9_nx[1] = eq9[1]; eq9_nx[0] = eq9[0]; 
				eq8_n_nx[2] = eq8_n[2]; eq8_n_nx[1] = eq8_n[1]; eq8_n_nx[0] = eq8_n[0];
				eq9_n_nx[2] = eq9_n[2]; eq9_n_nx[1] = eq9_n[1]; eq9_n_nx[0] = eq9_n[0];
			end
			4: begin
				eq1_n_nx[2] = eq1_n[2]; eq1_n_nx[1] = eq1_n[1]; eq1_n_nx[0] = out_n0;
				eq2_n_nx[2] = eq2_n[2]; eq2_n_nx[1] = eq2_n[1]; eq2_n_nx[0] = out_n1;
				eq3_n_nx[2] = eq3_n[2]; eq3_n_nx[1] = eq3_n[1]; eq3_n_nx[0] = out_n2;
				eq4_n_nx[2] = eq4_n[2]; eq4_n_nx[1] = eq4_n[1]; eq4_n_nx[0] = out_n3;
				eq5_nx[3] = eq5[3]; eq5_nx[2] = eq5[2]; eq5_nx[1] = eq5[1]; eq5_nx[0] = eq5[0];
				eq6_nx[3] = eq6[3]; eq6_nx[2] = eq6[2]; eq6_nx[1] = eq6[1]; eq6_nx[0] = eq6[0];
				eq7_nx[3] = eq7[3]; eq7_nx[2] = eq7[2]; eq7_nx[1] = eq7[1]; eq7_nx[0] = eq7[0];
				eq5_n_nx[3] = eq5_n[3]; eq5_n_nx[2] = eq5_n[2]; eq5_n_nx[1] = eq5_n[1]; eq5_n_nx[0] = eq5_n[0];
				eq6_n_nx[3] = eq6_n[3]; eq6_n_nx[2] = eq6_n[2]; eq6_n_nx[1] = eq6_n[1]; eq6_n_nx[0] = eq6_n[0];
				eq7_n_nx[3] = eq7_n[3]; eq7_n_nx[2] = eq7_n[2]; eq7_n_nx[1] = eq7_n[1]; eq7_n_nx[0] = eq7_n[0];
				eq8_nx[2] = eq8[2]; eq8_nx[1] = eq8[1]; eq8_nx[0] = eq8[0]; 
				eq9_nx[2] = eq9[2]; eq9_nx[1] = eq9[1]; eq9_nx[0] = eq9[0]; 
				eq8_n_nx[2] = eq8_n[2]; eq8_n_nx[1] = eq8_n[1]; eq8_n_nx[0] = eq8_n[0];
				eq9_n_nx[2] = eq9_n[2]; eq9_n_nx[1] = eq9_n[1]; eq9_n_nx[0] = eq9_n[0];
			end
			5: begin
				eq1_n_nx[2] = eq1_n[2]; eq1_n_nx[1] = eq1_n[1]; eq1_n_nx[0] = eq1_n[0];
				eq2_n_nx[2] = eq2_n[2]; eq2_n_nx[1] = eq2_n[1]; eq2_n_nx[0] = eq2_n[0];
				eq3_n_nx[2] = eq3_n[2]; eq3_n_nx[1] = eq3_n[1]; eq3_n_nx[0] = eq3_n[0];
				eq4_n_nx[2] = eq4_n[2]; eq4_n_nx[1] = eq4_n[1]; eq4_n_nx[0] = eq4_n[0];
				eq5_nx[3] = out_a0; eq5_nx[2] = out_a1; eq5_nx[1] = out_a2; eq5_nx[0] = out_a3;
				eq6_nx[3] = eq6[3]; eq6_nx[2] = eq6[2]; eq6_nx[1] = eq6[1]; eq6_nx[0] = eq6[0];
				eq7_nx[3] = eq7[3]; eq7_nx[2] = eq7[2]; eq7_nx[1] = eq7[1]; eq7_nx[0] = eq7[0];
				eq5_n_nx[3] = in_n0; eq5_n_nx[2] = in_n1; eq5_n_nx[1] = in_n2; eq5_n_nx[0] = in_n3;
				eq6_n_nx[3] = eq6_n[3]; eq6_n_nx[2] = eq6_n[2]; eq6_n_nx[1] = eq6_n[1]; eq6_n_nx[0] = eq6_n[0];
				eq7_n_nx[3] = eq7_n[3]; eq7_n_nx[2] = eq7_n[2]; eq7_n_nx[1] = eq7_n[1]; eq7_n_nx[0] = eq7_n[0];
				eq8_nx[2] = eq8[2]; eq8_nx[1] = eq8[1]; eq8_nx[0] = eq8[0]; 
				eq9_nx[2] = eq9[2]; eq9_nx[1] = eq9[1]; eq9_nx[0] = eq9[0]; 
				eq8_n_nx[2] = eq8_n[2]; eq8_n_nx[1] = eq8_n[1]; eq8_n_nx[0] = eq8_n[0];
				eq9_n_nx[2] = eq9_n[2]; eq9_n_nx[1] = eq9_n[1]; eq9_n_nx[0] = eq9_n[0];
			end
			6: begin
				eq1_n_nx[2] = eq1_n[2]; eq1_n_nx[1] = eq1_n[1]; eq1_n_nx[0] = eq1_n[0];
				eq2_n_nx[2] = eq2_n[2]; eq2_n_nx[1] = eq2_n[1]; eq2_n_nx[0] = eq2_n[0];
				eq3_n_nx[2] = eq3_n[2]; eq3_n_nx[1] = eq3_n[1]; eq3_n_nx[0] = eq3_n[0];
				eq4_n_nx[2] = eq4_n[2]; eq4_n_nx[1] = eq4_n[1]; eq4_n_nx[0] = eq4_n[0];
				eq5_nx[3] = eq5[3]; eq5_nx[2] = eq5[2]; eq5_nx[1] = eq5[1]; eq5_nx[0] = eq5[0];
				eq6_nx[3] = out_a0; eq6_nx[2] = out_a1; eq6_nx[1] = out_a2; eq6_nx[0] = out_a3;
				eq7_nx[3] = eq7[3]; eq7_nx[2] = eq7[2]; eq7_nx[1] = eq7[1]; eq7_nx[0] = eq7[0];
				eq5_n_nx[3] = eq5_n[3]; eq5_n_nx[2] = eq5_n[2]; eq5_n_nx[1] = eq5_n[1]; eq5_n_nx[0] = eq5_n[0];
				eq6_n_nx[3] = in_n0; eq6_n_nx[2] = in_n1; eq6_n_nx[1] = in_n2; eq6_n_nx[0] = in_n3;
				eq7_n_nx[3] = eq7_n[3]; eq7_n_nx[2] = eq7_n[2]; eq7_n_nx[1] = eq7_n[1]; eq7_n_nx[0] = eq7_n[0];
				eq8_nx[2] = eq8[2]; eq8_nx[1] = eq8[1]; eq8_nx[0] = eq8[0]; 
				eq9_nx[2] = eq9[2]; eq9_nx[1] = eq9[1]; eq9_nx[0] = eq9[0]; 
				eq8_n_nx[2] = eq8_n[2]; eq8_n_nx[1] = eq8_n[1]; eq8_n_nx[0] = eq8_n[0];
				eq9_n_nx[2] = eq9_n[2]; eq9_n_nx[1] = eq9_n[1]; eq9_n_nx[0] = eq9_n[0];
			end
			7: begin
				eq1_n_nx[2] = eq1_n[2]; eq1_n_nx[1] = eq1_n[1]; eq1_n_nx[0] = eq1_n[0];
				eq2_n_nx[2] = eq2_n[2]; eq2_n_nx[1] = eq2_n[1]; eq2_n_nx[0] = eq2_n[0];
				eq3_n_nx[2] = eq3_n[2]; eq3_n_nx[1] = eq3_n[1]; eq3_n_nx[0] = eq3_n[0];
				eq4_n_nx[2] = eq4_n[2]; eq4_n_nx[1] = eq4_n[1]; eq4_n_nx[0] = eq4_n[0];
				eq5_nx[3] = eq5[3]; eq5_nx[2] = eq5[2]; eq5_nx[1] = eq5[1]; eq5_nx[0] = eq5[0];
				eq6_nx[3] = eq6[3]; eq6_nx[2] = eq6[2]; eq6_nx[1] = eq6[1]; eq6_nx[0] = eq6[0];
				eq7_nx[3] = out_a0; eq7_nx[2] = out_a1; eq7_nx[1] = out_a2; eq7_nx[0] = out_a3;
				eq5_n_nx[3] = eq5_n[3]; eq5_n_nx[2] = eq5_n[2]; eq5_n_nx[1] = eq5_n[1]; eq5_n_nx[0] = eq5_n[0];
				eq6_n_nx[3] = eq6_n[3]; eq6_n_nx[2] = eq6_n[2]; eq6_n_nx[1] = eq6_n[1]; eq6_n_nx[0] = eq6_n[0];
				eq7_n_nx[3] = in_n0; eq7_n_nx[2] = in_n1; eq7_n_nx[1] = in_n2; eq7_n_nx[0] = in_n3;
				eq8_nx[2] = eq8[2]; eq8_nx[1] = eq8[1]; eq8_nx[0] = eq8[0];
				eq9_nx[2] = eq9[2]; eq9_nx[1] = eq9[1]; eq9_nx[0] = eq9[0]; 
				eq8_n_nx[2] = eq8_n[2]; eq8_n_nx[1] = eq8_n[1]; eq8_n_nx[0] = eq8_n[0];
				eq9_n_nx[2] = eq9_n[2]; eq9_n_nx[1] = eq9_n[1]; eq9_n_nx[0] = eq9_n[0];
			end
			8: begin
				eq1_n_nx[2] = eq1_n[2]; eq1_n_nx[1] = eq1_n[1]; eq1_n_nx[0] = eq1_n[0];
				eq2_n_nx[2] = eq2_n[2]; eq2_n_nx[1] = eq2_n[1]; eq2_n_nx[0] = eq2_n[0];
				eq3_n_nx[2] = eq3_n[2]; eq3_n_nx[1] = eq3_n[1]; eq3_n_nx[0] = eq3_n[0];
				eq4_n_nx[2] = eq4_n[2]; eq4_n_nx[1] = eq4_n[1]; eq4_n_nx[0] = eq4_n[0];
				eq5_nx[3] = eq5[3]; eq5_nx[2] = eq5[2]; eq5_nx[1] = eq5[1]; eq5_nx[0] = eq5[0];
				eq6_nx[3] = eq6[3]; eq6_nx[2] = eq6[2]; eq6_nx[1] = eq6[1]; eq6_nx[0] = eq6[0];
				eq7_nx[3] = eq7[3]; eq7_nx[2] = eq7[2]; eq7_nx[1] = eq7[1]; eq7_nx[0] = eq7[0];
				eq5_n_nx[3] = eq5_n[3]; eq5_n_nx[2] = eq5_n[2]; eq5_n_nx[1] = eq5_n[1]; eq5_n_nx[0] = eq5_n[0];
				eq6_n_nx[3] = eq6_n[3]; eq6_n_nx[2] = eq6_n[2]; eq6_n_nx[1] = eq6_n[1]; eq6_n_nx[0] = eq6_n[0];
				eq7_n_nx[3] = eq7_n[3]; eq7_n_nx[2] = eq7_n[2]; eq7_n_nx[1] = eq7_n[1]; eq7_n_nx[0] = eq7_n[0];
				eq8_nx[2] = out_a0; eq8_nx[1] = out_a1; eq8_nx[0] = out_a2;
				eq9_nx[2] = eq9[2]; eq9_nx[1] = eq9[1]; eq9_nx[0] = eq9[0]; 
				eq8_n_nx[2] = in_n0; eq8_n_nx[1] = in_n1; eq8_n_nx[0] = in_n2;
				eq9_n_nx[2] = eq9_n[2]; eq9_n_nx[1] = eq9_n[1]; eq9_n_nx[0] = eq9_n[0];
			end
			9: begin
				eq1_n_nx[2] = eq1_n[2]; eq1_n_nx[1] = eq1_n[1]; eq1_n_nx[0] = eq1_n[0];
				eq2_n_nx[2] = eq2_n[2]; eq2_n_nx[1] = eq2_n[1]; eq2_n_nx[0] = eq2_n[0];
				eq3_n_nx[2] = eq3_n[2]; eq3_n_nx[1] = eq3_n[1]; eq3_n_nx[0] = eq3_n[0];
				eq4_n_nx[2] = eq4_n[2]; eq4_n_nx[1] = eq4_n[1]; eq4_n_nx[0] = eq4_n[0];
				eq5_nx[3] = eq5[3]; eq5_nx[2] = eq5[2]; eq5_nx[1] = eq5[1]; eq5_nx[0] = eq5[0];
				eq6_nx[3] = eq6[3]; eq6_nx[2] = eq6[2]; eq6_nx[1] = eq6[1]; eq6_nx[0] = eq6[0];
				eq7_nx[3] = eq7[3]; eq7_nx[2] = eq7[2]; eq7_nx[1] = eq7[1]; eq7_nx[0] = eq7[0];
				eq5_n_nx[3] = eq5_n[3]; eq5_n_nx[2] = eq5_n[2]; eq5_n_nx[1] = eq5_n[1]; eq5_n_nx[0] = eq5_n[0];
				eq6_n_nx[3] = eq6_n[3]; eq6_n_nx[2] = eq6_n[2]; eq6_n_nx[1] = eq6_n[1]; eq6_n_nx[0] = eq6_n[0];
				eq7_n_nx[3] = eq7_n[3]; eq7_n_nx[2] = eq7_n[2]; eq7_n_nx[1] = eq7_n[1]; eq7_n_nx[0] = eq7_n[0];
				eq8_nx[2] = eq8[2]; eq8_nx[1] = eq8[1]; eq8_nx[0] = eq8[0]; 
				eq9_nx[2] = out_a0; eq9_nx[1] = out_a1; eq9_nx[0] = out_a2;
				eq8_n_nx[2] = eq8_n[2]; eq8_n_nx[1] = eq8_n[1]; eq8_n_nx[0] = eq8_n[0];
				eq9_n_nx[2] = in_n0; eq9_n_nx[1] = in_n1; eq9_n_nx[0] = in_n2;
			end 
			default: begin
				eq1_n_nx[2] = eq1_n[2]; eq1_n_nx[1] = eq1_n[1]; eq1_n_nx[0] = eq1_n[0];
				eq2_n_nx[2] = eq2_n[2]; eq2_n_nx[1] = eq2_n[1]; eq2_n_nx[0] = eq2_n[0];
				eq3_n_nx[2] = eq3_n[2]; eq3_n_nx[1] = eq3_n[1]; eq3_n_nx[0] = eq3_n[0];
				eq4_n_nx[2] = eq4_n[2]; eq4_n_nx[1] = eq4_n[1]; eq4_n_nx[0] = eq4_n[0];
				eq5_nx[3] = eq5[3]; eq5_nx[2] = eq5[2]; eq5_nx[1] = eq5[1]; eq5_nx[0] = eq5[0];
				eq6_nx[3] = eq6[3]; eq6_nx[2] = eq6[2]; eq6_nx[1] = eq6[1]; eq6_nx[0] = eq6[0];
				eq7_nx[3] = eq7[3]; eq7_nx[2] = eq7[2]; eq7_nx[1] = eq7[1]; eq7_nx[0] = eq7[0];
				eq5_n_nx[3] = eq5_n[3]; eq5_n_nx[2] = eq5_n[2]; eq5_n_nx[1] = eq5_n[1]; eq5_n_nx[0] = eq5_n[0];
				eq6_n_nx[3] = eq6_n[3]; eq6_n_nx[2] = eq6_n[2]; eq6_n_nx[1] = eq6_n[1]; eq6_n_nx[0] = eq6_n[0];
				eq7_n_nx[3] = eq7_n[3]; eq7_n_nx[2] = eq7_n[2]; eq7_n_nx[1] = eq7_n[1]; eq7_n_nx[0] = eq7_n[0];
				eq8_nx[2] = eq8[2]; eq8_nx[1] = eq8[1]; eq8_nx[0] = eq8[0]; 
				eq9_nx[2] = eq9[2]; eq9_nx[1] = eq9[1]; eq9_nx[0] = eq9[0]; 
				eq8_n_nx[2] = eq8_n[2]; eq8_n_nx[1] = eq8_n[1]; eq8_n_nx[0] = eq8_n[0];
				eq9_n_nx[2] = eq9_n[2]; eq9_n_nx[1] = eq9_n[1]; eq9_n_nx[0] = eq9_n[0];
			end
		endcase
	end
	else begin
		for(i = 0; i < 4; i = i + 1) begin
			eq5_nx[i] = eq5[i];
			eq6_nx[i] = eq6[i];
			eq5_n_nx[i] = eq5_n[i];
			eq6_n_nx[i] = eq6_n[i];
			eq7_nx[i] = eq7[i];
			eq7_n_nx[i] = eq7_n[i];
		end
		for(i = 0; i < 3; i = i + 1) begin
			eq1_n_nx[i] = eq1_n[i];
			eq2_n_nx[i] = eq2_n[i];
			eq3_n_nx[i] = eq3_n[i];
			eq4_n_nx[i] = eq4_n[i];
			eq8_nx[i] = eq8[i];
			eq9_nx[i] = eq9[i];
			eq8_n_nx[i] = eq8_n[i];
			eq9_n_nx[i] = eq9_n[i];
		end
	end
end
	
endmodule
