`define EN 0
`define DE 0
module test_enigma_part2;
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
reg [6-1:0] plaintext1[0:24-1];
reg [6-1:0] ciphertext1[0:24-1];

integer i, j, k;

initial begin
  $fsdbDumpfile("enigma_part2.fsdb");
  $fsdbDumpvars;
end

always #(CYCLE/2) clk = ~clk; 

initial begin
	clk = 0; srstn = 1;
	#(CYCLE) srstn = 0;
	#(CYCLE) srstn = 1;
	#(CYCLE*300) $finish;
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
end

initial begin
	encrypt = 0; 
	if(`EN)	begin
		$readmemh("./pat/plaintext1.dat", plaintext1);
		crypt_mode = 0;
	end
	else if(`DE) begin
		$readmemh("./pat/ciphertext1.dat", plaintext1);
		crypt_mode = 1;
	end
	else $finish;
	@(negedge load) 
	#(CYCLE) encrypt = 1;
	for(j = 0; j < 24; j = j + 1) begin
		@(negedge clk)
		code_in = plaintext1[j][6-1:0];
	end
	#(CYCLE)
	encrypt = 0;
end

initial begin
	if(`EN) $readmemh("./pat/ciphertext1.dat", ciphertext1);
	else if(`DE) $readmemh("./pat/plaintext1.dat", ciphertext1);
	@(posedge code_valid)
	for(k = 0; k < 24; k = k + 1) begin
		@(negedge clk)
		if(ciphertext1[k] !== code_out) begin
			$display("No. %d is wrong, code_out=%h, Ans=%h", k, code_out, ciphertext1[k]);
			$finish;
		end
		else begin
			$display("No. %d is correct, code_out=%h, Ans=%h", k, code_out, ciphertext1[k]);
		end
	end
	$display("All correct");
	$finish;
end

endmodule
