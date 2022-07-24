`define CYCLE 10
`define MODE_L 0
`define MODE_U 255
module test_rop3;

// 1. variable declaration and clock connection
// -----------------------------

// declare variables and connect clock here

// -----------------------------
parameter N = 8;
reg clk;
reg [N-1:0] P, S, D;
reg [7:0] Mode;
wire [N-1:0] Result_lut256, Result_smart;

initial begin
    clk = 0;
    while(1) #(`CYCLE/2) clk = ~clk;
end

// 2. connect RTL module 
// -----------------------------

// add your module here

// -----------------------------
rop3_lut256 #(.N(N)) U0(.clk(clk), .P(P), .S(S), .D(D), .Mode(Mode), .Result(Result_lut256));
rop3_smart #(.N(N)) U1(.clk(clk), .P(P), .S(S), .D(D), .Mode(Mode), .Result(Result_smart));

reg [N-1:0] P_last, S_last, D_last;
reg [7:0]   Mode_last;
reg [N-1:0] P_lastlast, S_lastlast, D_lastlast;
reg [7:0]   Mode_lastlast;
integer output_cnt = 0;

// Don't modify this two blocks
// -----------------------------
// input preparation
initial begin
    input_preparation;
end
// output comparision
initial begin
    output_comparison;
end
// -----------------------------


// 3. implement the above two functions in the task file
`include "./rop3.task"


endmodule
