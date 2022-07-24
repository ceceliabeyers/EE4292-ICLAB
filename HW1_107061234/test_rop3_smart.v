`define CYCLE 10
module test_rop3_smart;
parameter N = 8;
reg clk;
reg [N-1:0] P, S, D;
reg [7:0] Mode;
wire [N-1:0] Result_lut16, Result_smart;

rop3_lut16 #(.N(N)) U0(.clk(clk), .P(P), .S(S), .D(D), .Mode(Mode), .Result(Result_lut16));
rop3_smart #(.N(N)) U1(.clk(clk), .P(P), .S(S), .D(D), .Mode(Mode), .Result(Result_smart));

integer input_mode, input_i, input_j, input_k, output_mode, output_i, output_j, output_k;
integer output_cnt = 0;
parameter [8*15-1:0] mode_ary = {8'h00, 8'h11, 8'h33, 8'h44, 8'h55, 8'h5A, 8'h66, 8'h88, 8'hBB, 8'hC0, 8'hCC, 8'hEE, 8'hF0, 8'hFB, 8'hFF};
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
	for(input_mode = 0; input_mode < 15; input_mode = input_mode + 1) begin
		$display("Mode %2h", mode_ary[(8*(15-input_mode)-1)-:8]);
		for(input_i = 0; input_i < 2**N; input_i = input_i + 1) begin
			for(input_j = 0; input_j < 2**N; input_j = input_j + 1) begin
				for(input_k = 0; input_k < 2**N; input_k = input_k + 1) begin			
					@(posedge clk); #1;
					{Mode_lastlast, P_lastlast, S_lastlast, D_lastlast} = {Mode_last, P_last, S_last, D_last};
        				{Mode_last, P_last, S_last, D_last} = {Mode, P, S, D};
        				Mode = mode_ary[(8*(15-input_mode)-1)-:8];
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
	for(output_mode = 0; output_mode < 15; output_mode = output_mode + 1) begin
		for(output_i = 0; output_i < 2**N; output_i = output_i + 1) begin
			for(output_j = 0; output_j < 2**N; output_j = output_j + 1) begin
				for(output_k = 0; output_k < 2**N; output_k = output_k + 1) begin
        				@(negedge clk);
        				if (Result_lut16 !== Result_smart) begin
            					$display("!!!!! Comparison Fail @ pattern %0d !!!!!", output_cnt);
            					$display("[pattern %0d] Mode=%2h, {P,S,D}={%2h,%2h,%2h}, LUT16=%2h, Smart=%2h",
                      				output_cnt, Mode_lastlast, P_lastlast, S_lastlast, D_lastlast, Result_lut16, Result_smart);
           					$finish;
        				end 
					//else if (output_mode == 3) begin
            					//$display(">>>>> Comparison Pass @ pattern %0d <<<<<", output_cnt);
					//	$display("[pattern %0d] Mode=%2h, {P,S,D}={%2h,%2h,%2h}, LUT16=%2h, Smart=%2h",
                      			//	output_cnt, Mode_lastlast, P_lastlast, S_lastlast, D_lastlast, Result_lut16, Result_smart);
        				//end
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
