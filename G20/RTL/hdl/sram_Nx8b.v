module sram_Nx8b 
#(
parameter N = 1048576,
parameter ACT_PER_ADDR = 1,
parameter BW_PER_ACT = 8,
parameter IMG_WID_BW = 10,
parameter IMG_HEI_BW = 10
)
(
input clk,
input csb,  // chip enable
input wsb,  // write enable
input [ACT_PER_ADDR*BW_PER_ACT-1:0] wdata, // 8 bit per sram address
input [IMG_WID_BW+IMG_HEI_BW-1:0] waddr, // write address
input [IMG_WID_BW+IMG_HEI_BW-1:0] raddr, // read address

output reg [ACT_PER_ADDR*BW_PER_ACT-1:0] rdata // read data of one pixel (8 bits)
);

reg [ACT_PER_ADDR*BW_PER_ACT-1:0] _rdata;
reg [ACT_PER_ADDR*BW_PER_ACT-1:0] mem [0:N-1];

always @(posedge clk) begin
    if(~csb && ~wsb) begin
        mem[waddr] <= wdata;
    end
end

always @(posedge clk) begin
    if(~csb) begin
        _rdata <= mem[raddr];
    end
end

always @* begin
    rdata = #(1) _rdata;
end

task load_param(
    input integer index,
    input [ACT_PER_ADDR*BW_PER_ACT-1:0] param_input
);
    mem[index] = param_input;
endtask

endmodule
