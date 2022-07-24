`define MY 0
`define BEHAVIOR 0
module test_enigma_part1;
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
wire [6-1:0] code_out_be, code_out_my;   //encrypted code word (register output)
wire code_valid_be, code_valid_my;         //0: non-valid code_out; 1: valid code_out (register output)

parameter CYCLE = 10;

behavior_model U0(
	// Input
	.clk(clk),
	.srstn(srstn),
	.load(load),
	.encrypt(encrypt),
	.crypt_mode(crypt_mode),
	.load_idx(load_idx),
	.code_in(code_in),
	// Output
	.code_out(code_out_be),
	.code_valid(code_valid_be)
);

enigma_part1 U1(
	// Input
	.clk(clk),
	.srstn(srstn),
	.load(load),
	.encrypt(encrypt),
	.crypt_mode(crypt_mode),
	.load_idx(load_idx),
	.code_in(code_in),
	// Output
	.code_out(code_out_my),
	.code_valid(code_valid_my)
);

reg [6-1:0] rotorA[0:64-1];
reg [6-1:0] plaintext1[0:23-1];
reg [6-1:0] ciphertext1[0:23-1];

integer i, j, k;

/*
initial begin
  $fsdbDumpfile("enigma_part1.fsdb");
  $fsdbDumpvars;
end
*/

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
	@(negedge clk)
	@(negedge clk) load = 1;
	for(i = 0; i < 192; i = i + 1) begin
		@(negedge clk)
		load_idx = i;
		code_in = rotorA[i][6-1:0];
	end
	#(CYCLE/2 + 1) load = 0;
end

initial begin
	encrypt = 0; crypt_mode = 1; 
	$readmemh("./pat/plaintext1.dat", plaintext1);
	@(negedge load) 
	#(CYCLE) encrypt = 1;
	for(j = 0; j < 23; j = j + 1) begin
		@(negedge clk)
		code_in = plaintext1[j][6-1:0];
	end
	#(CYCLE)
	encrypt = 0;
end

initial begin
	$readmemh("./pat/ciphertext1.dat", ciphertext1);
	if(`BEHAVIOR) begin
		@(posedge code_valid_be)
		for(k = 0; k < 23; k = k + 1) begin
			@(negedge clk)
			if(ciphertext1[k] !== code_out_be) begin
				$display("No. %d is wrong, code_out_be=%d, cipher=%d", k, code_out_be, ciphertext1[k]);
				$finish;
			end
			else begin
				$display("No. %d is correct, code_out_be=%d, cipher=%d", k, code_out_be, ciphertext1[k]);
			end
		end
		$display("All correct");
		$finish;
	end
	else if(`MY) begin
		@(posedge code_valid_my)
		for(k = 0; k < 23; k = k + 1) begin
			@(negedge clk)
			if(ciphertext1[k] !== code_out_my) begin
				$display("No. %d is wrong, code_out_my=%d, cipher=%d", k, code_out_my, ciphertext1[k]);
				$finish;
			end
			else begin
				$display("No. %d is correct, code_out_my=%d, cipher=%d", k, code_out_my, ciphertext1[k]);
			end
		end
		$display("All correct");
		$finish;
	end
	else $finish;
end
endmodule
