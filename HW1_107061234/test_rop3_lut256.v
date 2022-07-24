`define CYCLE 10
module test_rop3_lut256;
parameter N = 8;
reg clk;
reg [N-1:0] P, S, D;
reg [7:0] Mode;
wire [N-1:0] Result_lut256, Result_smart;

rop3_lut256 #(.N(N)) U0(.clk(clk), .P(P), .S(S), .D(D), .Mode(Mode), .Result(Result_lut256));
rop3_smart #(.N(N)) U1(.clk(clk), .P(P), .S(S), .D(D), .Mode(Mode), .Result(Result_smart));

integer input_mode, input_i, input_j, input_k, output_mode, output_i, output_j, output_k;
integer output_cnt = 0;
initial begin
    clk = 0;
    while(1) #(`CYCLE/2) clk = ~clk;
end

reg [N-1:0] P_last, S_last, D_last;
reg [7:0]   Mode_last;
reg [N-1:0] P_lastlast, S_lastlast, D_lastlast;
reg [7:0]   Mode_lastlast;

initial begin
	Mode = 8'hzz; P = 8'hzz; S = 8'hzz; D = 8'hzz;
	for(input_mode = 0; input_mode < 256; input_mode = input_mode + 1) begin
		$display("Mode %2h", input_mode);
		for(input_i = 0; input_i < 2**N; input_i = input_i + 1) begin
			for(input_j = 0; input_j < 2**N; input_j = input_j + 1) begin
				for(input_k = 0; input_k < 2**N; input_k = input_k + 1) begin			
					@(posedge clk); #1;
					{Mode_lastlast, P_lastlast, S_lastlast, D_lastlast} = {Mode_last, P_last, S_last, D_last};
        				{Mode_last, P_last, S_last, D_last} = {Mode, P, S, D};
        				Mode = input_mode;
					P = input_i;
					S = input_j;
					D = input_k;
				end
			end
		end
	end
end

initial begin
	@(negedge clk);
	@(negedge clk);
	for(output_mode = 0; output_mode < 256; output_mode = output_mode + 1) begin
		for(output_i = 0; output_i < 2**N; output_i = output_i + 1) begin
			for(output_j = 0; output_j < 2**N; output_j = output_j + 1) begin
				for(output_k = 0; output_k < 2**N; output_k = output_k + 1) begin
        				@(negedge clk);
        				if (Result_lut256 !== Result_smart) begin
            					$display("!!!!! Comparison Fail @ pattern %0d !!!!!", output_cnt);
            					$display("[pattern %0d] Mode=%2h, {P,S,D}={%2h,%2h,%2h}, LUT256=%2h, Smart=%2h",
                      				output_cnt, Mode_lastlast, P_lastlast, S_lastlast, D_lastlast, Result_lut256, Result_smart);
           					$finish;
        				end 
					else if(output_i==255 && output_j == 255 && output_k == 255) begin
					$display("[pattern %0d] Mode=%2h, {P,S,D}={%2h,%2h,%2h}, LUT256=%2h, Smart=%2h",
                      				output_cnt, Mode_lastlast, P_lastlast, S_lastlast, D_lastlast, Result_lut256, Result_smart);
					end
        				output_cnt = output_cnt + 1;
				end
			end
		end
    	end


        $display("\n============= Congratulations =============");
        $display("    You can move on to the next part !");
        $display("============= Congratulations =============\n");   
	$finish;
end

endmodule

