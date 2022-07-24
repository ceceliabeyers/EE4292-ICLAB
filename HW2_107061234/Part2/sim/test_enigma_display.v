module test_enigma_display;
reg clk;               //clock input
reg srstn;             //synchronous reset (active low)
reg load;              //load control signal (level sensitive). 0/1: inactive/active
                         //effective in IDLE and LOAD states
reg encrypt;           //encrypt control signal (level sensitive). 0/1: inactive/active
                         //effective in READY state
reg crypt_mode;        //0: encrypt; 1:decrypt
reg [8-1:0] load_idx;		//index of rotor table to be loaded; A:0~63; B:64~127; C:128~191;
reg [6-1:0] code_in;		//When load is active, 
                        //rotorA[load_idx[5:0]] <= code_in if load_idx[7:6]==2'b00
                        //rotorB[load_idx[5:0]] <= code_in if load_idx[7:6]==2'b01
						//rotorC[load_idx[5:0]] <= code_in if load_idx[7:6]==2'b10
wire [6-1:0] code_out;   //encrypted code word (register output)
wire code_valid;         //0: non-valid code_out; 1: valid code_out (register output)

parameter CYCLE = 10;
localparam TEXT2_LENGTH = 112;
localparam TEXT3_LENGTH = 122836;

enigma_part2 U0(
	// Input
	.clk(clk),
	.srstn(srstn),
	.load(load),
	.encrypt(encrypt),
	.crypt_mode(crypt_mode),
	.load_idx(load_idx),
	.code_in(code_in),
	// Output
	.code_out(code_out),
	.code_valid(code_valid)
);

reg [6-1:0] rotorA[0:64-1];
reg [6-1:0] rotorB[0:64-1];
reg [6-1:0] rotorC[0:64-1];
reg [6-1:0] ciphertext2[0:TEXT2_LENGTH-1];
reg [6-1:0] ciphertext3[0:TEXT3_LENGTH-1];
reg [7:0] ascii_code;

integer i, j, k;
integer plaintext2, plaintext3;

/*
initial begin
  $fsdbDumpfile("enigma_display.fsdb");
  $fsdbDumpvars;
end
*/

always #(CYCLE/2) clk = ~clk; 

initial begin
	clk = 0; srstn = 1;
	#(CYCLE) srstn = 0;
	#(CYCLE) srstn = 1;
	#(CYCLE*(192 + TEXT2_LENGTH + 15)) 
	#(CYCLE) srstn = 0;
	#(CYCLE) srstn = 1;
	wait(encrypt);
	#(CYCLE*(192 + TEXT3_LENGTH + 15)) 
	$finish;
end

initial begin
	load = 0;
	$readmemh("./rotor/rotorA.dat", rotorA);
	$readmemh("./rotor/rotorB.dat", rotorB);
	$readmemh("./rotor/rotorC.dat", rotorC);
	@(negedge clk)
	@(negedge clk) load = 1;
	for(i = 0; i < 64; i = i + 1) begin
		@(negedge clk)
		load_idx = i;
		code_in = rotorA[i][6-1:0];
	end
	for(i = 64; i < 128; i = i + 1) begin
		@(negedge clk)
		load_idx = i;
		code_in = rotorB[i-64][6-1:0];
	end
	for(i = 128; i < 192; i = i + 1) begin
		@(negedge clk)
		load_idx = i;
		code_in = rotorC[i-128][6-1:0];
	end
	#(CYCLE/2 + 1) load = 0;
	wait(!srstn);
	@(negedge clk) load = 1;
	for(i = 0; i < 64; i = i + 1) begin
		@(negedge clk)
		load_idx = i;
		code_in = rotorA[i][6-1:0];
	end
	for(i = 64; i < 128; i = i + 1) begin
		@(negedge clk)
		load_idx = i;
		code_in = rotorB[i-64][6-1:0];
	end
	for(i = 128; i < 192; i = i + 1) begin
		@(negedge clk)
		load_idx = i;
		code_in = rotorC[i-128][6-1:0];
	end
	#(CYCLE/2 + 1) load = 0;
	
end

initial begin
	encrypt = 0; crypt_mode = 1;
	$readmemh("./pat/ciphertext2.dat", ciphertext2);
	$readmemh("./pat/ciphertext3.dat", ciphertext3);
	@(negedge load) 
	#(CYCLE) encrypt = 1;
	for(j = 0; j < TEXT2_LENGTH; j = j + 1) begin
		@(negedge clk)
		code_in = ciphertext2[j][6-1:0];
	end
	#(CYCLE)
	encrypt = 0;
	@(negedge load) 
	#(CYCLE) encrypt = 1;
	for(j = 0; j < TEXT3_LENGTH; j = j + 1) begin
		@(negedge clk)
		code_in = ciphertext3[j][6-1:0];
	end
	#(CYCLE)
	encrypt = 0;

end

initial begin
	plaintext2 = $fopen("../result/plaintext2_ascii.dat", "w");
	plaintext3 = $fopen("../result/plaintext3_ascii.dat", "w");
	@(posedge code_valid)
	for(k = 0; k < TEXT2_LENGTH; k = k + 1) begin
		@(negedge clk)
		EnigmaCodetoASCII(code_out, ascii_code);
		$fwrite(plaintext2, "%s",ascii_code);
	end
	@(posedge code_valid)
	for(k = 0; k < TEXT3_LENGTH; k = k + 1) begin
		@(negedge clk)
		EnigmaCodetoASCII(code_out, ascii_code);
		$fwrite(plaintext3, "%s",ascii_code);
	end
	$finish;
end

task EnigmaCodetoASCII;
input [6-1:0] eingmacode;
output [8-1:0] ascii_out;
reg [8-1:0] ascii_out;

begin
  case(eingmacode)
    6'h00: ascii_out = 8'h61; //'a'
    6'h01: ascii_out = 8'h62; //'b'
    6'h02: ascii_out = 8'h63; //'c'
    6'h03: ascii_out = 8'h64; //'d'
    6'h04: ascii_out = 8'h65; //'e'
    6'h05: ascii_out = 8'h66; //'f'
    6'h06: ascii_out = 8'h67; //'g'
    6'h07: ascii_out = 8'h68; //'h'
    6'h08: ascii_out = 8'h69; //'i'
    6'h09: ascii_out = 8'h6a; //'j'
    6'h0a: ascii_out = 8'h6b; //'k'
    6'h0b: ascii_out = 8'h6c; //'l'
    6'h0c: ascii_out = 8'h6d; //'m'
    6'h0d: ascii_out = 8'h6e; //'n'
    6'h0e: ascii_out = 8'h6f; //'o'
    6'h0f: ascii_out = 8'h70; //'p'
    6'h10: ascii_out = 8'h71; //'q'
    6'h11: ascii_out = 8'h72; //'r'
    6'h12: ascii_out = 8'h73; //'s'
    6'h13: ascii_out = 8'h74; //'t'
    6'h14: ascii_out = 8'h75; //'u'
    6'h15: ascii_out = 8'h76; //'v'
    6'h16: ascii_out = 8'h77; //'w'
    6'h17: ascii_out = 8'h78; //'x'
    6'h18: ascii_out = 8'h79; //'y'
    6'h19: ascii_out = 8'h7a; //'z'
    6'h1a: ascii_out = 8'h20; //' '
    6'h1b: ascii_out = 8'h21; //'!'
    6'h1c: ascii_out = 8'h2c; //','
    6'h1d: ascii_out = 8'h2d; //'-'
    6'h1e: ascii_out = 8'h2e; //'.'
    6'h1f: ascii_out = 8'h0a; //'\n' (change line)
    6'h20: ascii_out = 8'h41; //'A'
    6'h21: ascii_out = 8'h42; //'B'
    6'h22: ascii_out = 8'h43; //'C'
    6'h23: ascii_out = 8'h44; //'D'
    6'h24: ascii_out = 8'h45; //'E'
    6'h25: ascii_out = 8'h46; //'F'
    6'h26: ascii_out = 8'h47; //'G'
    6'h27: ascii_out = 8'h48; //'H'
    6'h28: ascii_out = 8'h49; //'I'
    6'h29: ascii_out = 8'h4a; //'J'
    6'h2a: ascii_out = 8'h4b; //'K'
    6'h2b: ascii_out = 8'h4c; //'L'
    6'h2c: ascii_out = 8'h4d; //'M'
    6'h2d: ascii_out = 8'h4e; //'N'
    6'h2e: ascii_out = 8'h4f; //'O'
    6'h2f: ascii_out = 8'h50; //'P'
    6'h30: ascii_out = 8'h51; //'Q'
    6'h31: ascii_out = 8'h52; //'R'
    6'h32: ascii_out = 8'h53; //'S'
    6'h33: ascii_out = 8'h54; //'T'
    6'h34: ascii_out = 8'h55; //'U'
    6'h35: ascii_out = 8'h56; //'V'
    6'h36: ascii_out = 8'h57; //'W'
    6'h37: ascii_out = 8'h58; //'X'
    6'h38: ascii_out = 8'h59; //'Y'
    6'h39: ascii_out = 8'h5a; //'Z'
    6'h3a: ascii_out = 8'h3a; //':'
    6'h3b: ascii_out = 8'h23; //'#'
    6'h3c: ascii_out = 8'h3b; //';'
    6'h3d: ascii_out = 8'h5f; //'_'
    6'h3e: ascii_out = 8'h2b; //'+'
    6'h3f: ascii_out = 8'h26; //'&'
  endcase
end
endtask

endmodule
