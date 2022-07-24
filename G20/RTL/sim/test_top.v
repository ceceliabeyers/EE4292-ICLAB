`timescale 1ns/100ps
`define TEST_DATA 0         // 0 for 96*64, 1 for 91*61
`define SAMPLE_MODE 0       // 0 for 4:1:1, 1 for 4:2:0
`define SDFFILE "../../SYN/netlist/top_syn.sdf"
module test_top_all;
localparam ACT_PER_ADDR = 1;
localparam IN_WIDTH     = 8;
localparam OUT_WIDTH    = 23;
localparam COEF_WIDTH   = 9;
localparam COEF_FP      = 8;
localparam IMG_SIZE     = 11;
localparam BW_PER_ACT   = 8;
localparam SRAM_ADDR_R  = 22;
localparam SRAM_ADDR_W  = 20;
localparam REG_WIDTH    = 12;
localparam N1           = 2500000;
localparam N2           = 600000;
localparam IMG_WID_BW   = 11;
localparam IMG_HEI_BW   = 11;
localparam END_CYCLES   = 1000000000; // you can enlarge the cycle count limit for longer simulation
real CYCLE = 2.5;

// ===== module I/O ===== //
reg clk;
reg rst_n;
reg enable;
wire [ACT_PER_ADDR*IN_WIDTH-1:0] R;  // input pixel R, unsigned
wire [ACT_PER_ADDR*IN_WIDTH-1:0] G;  // input pixel G, unsigned
wire [ACT_PER_ADDR*IN_WIDTH-1:0] B;  // input pixel B, unsigned
wire [ACT_PER_ADDR*OUT_WIDTH-1:0] code;
reg encode;
reg sample_mode;
reg [IMG_SIZE-1:0] img_width;
reg [IMG_SIZE-1:0] img_height;
wire wsb_Y;
wire wsb_U;
wire wsb_V;
wire wsb_23b;
wire [SRAM_ADDR_R-1:0] sram_raddr_8b;  // read RGB
wire [SRAM_ADDR_W-1:0] sram_raddr_23b;
wire [IN_WIDTH-1:0] wdata_8b;
wire [OUT_WIDTH-1:0] wdata_23b;
wire [SRAM_ADDR_R-1:0] waddr_8b; 
wire [SRAM_ADDR_W-1:0] waddr_23b; 
wire [4:0] bit_valid_out;
wire finish;

// ===== instantiation ===== //
`ifdef GATESIM
initial $sdf_annotate(`SDFFILE, top);
top  top (
// Input
.clk(clk),
.rst_n(rst_n),
.enable(enable),
.encode(encode),
.R(R),  
.G(G), 
.B(B), 
.code(code),
.sample_mode(sample_mode),
.img_width(img_width),
.img_height(img_height),
// Output
.wsb_Y(wsb_Y),
.wsb_U(wsb_U),
.wsb_V(wsb_V),
.wsb_23b(wsb_23b),
.sram_raddr_8b(sram_raddr_8b),   // read RGB
.sram_raddr_23b(sram_raddr_23b),
.wdata_8b(wdata_8b),
.wdata_23b(wdata_23b),
.waddr_8b(waddr_8b), 
.waddr_23b(waddr_23b), 
.bit_valid_out(bit_valid_out),
.finish(finish)
);
`else
top #(
.N(N1),
.ACT_PER_ADDR(ACT_PER_ADDR),
.IN_WIDTH(IN_WIDTH),
.OUT_WIDTH(OUT_WIDTH),
.COEF_WIDTH(COEF_WIDTH),
.COEF_FP(COEF_FP),
.IMG_SIZE(IMG_SIZE),
.SRAM_ADDR_R(SRAM_ADDR_R),
.SRAM_ADDR_W(SRAM_ADDR_W),  // 23b, read code
.REG_WIDTH(REG_WIDTH)
) top (
// Input
.clk(clk),
.rst_n(rst_n),
.enable(enable),
.encode(encode),
.R(R),  
.G(G), 
.B(B), 
.code(code),
.sample_mode(sample_mode),
.img_width(img_width),
.img_height(img_height),
// Output
.wsb_Y(wsb_Y),
.wsb_U(wsb_U),
.wsb_V(wsb_V),
.wsb_23b(wsb_23b),
.sram_raddr_8b(sram_raddr_8b),   // read RGB
.sram_raddr_23b(sram_raddr_23b),
.wdata_8b(wdata_8b),
.wdata_23b(wdata_23b),
.waddr_8b(waddr_8b), 
.waddr_23b(waddr_23b), 
.bit_valid_out(bit_valid_out),
.finish(finish)
);
`endif
// ===== sram connection ===== //
sram_Nx8b #(
.N(N1),
.ACT_PER_ADDR(ACT_PER_ADDR),
.BW_PER_ACT(IN_WIDTH),
.IMG_WID_BW(IMG_WID_BW),
.IMG_HEI_BW(IMG_HEI_BW)
) sram_Nx8b_R(
.clk(clk),
.csb(1'b0),
.wsb(wsb_Y),
.wdata(wdata_8b), 
.waddr(waddr_8b), 
.raddr(sram_raddr_8b), 
.rdata(R)
);

sram_Nx8b #(
.N(N1),
.ACT_PER_ADDR(ACT_PER_ADDR),
.BW_PER_ACT(IN_WIDTH),
.IMG_WID_BW(IMG_WID_BW),
.IMG_HEI_BW(IMG_HEI_BW)
) sram_Nx8b_G(
.clk(clk),
.csb(1'b0),
.wsb(wsb_U),
.wdata(wdata_8b), 
.waddr(waddr_8b), 
.raddr(sram_raddr_8b), 
.rdata(G)
);

sram_Nx8b #(
.N(N1),
.ACT_PER_ADDR(ACT_PER_ADDR),
.BW_PER_ACT(IN_WIDTH),
.IMG_WID_BW(IMG_WID_BW),
.IMG_HEI_BW(IMG_HEI_BW)
) sram_Nx8b_B(
.clk(clk),
.csb(1'b0),
.wsb(wsb_V),
.wdata(wdata_8b), 
.waddr(waddr_8b), 
.raddr(sram_raddr_8b), 
.rdata(B)
);

sram_Nx23b #(
.N(N2),
.ACT_PER_ADDR(ACT_PER_ADDR),
.BW_PER_ACT(OUT_WIDTH),
.STORE_BW(SRAM_ADDR_W)
) sram_Nx23b(
.clk(clk),
.csb(1'b0),
.wsb(wsb_23b),
.wdata(wdata_23b), 
.waddr(waddr_23b), 
.raddr(sram_raddr_23b), 
.rdata(code)
);
// ===== waveform dumpping ===== //
initial begin
//   $fsdbDumpfile("jpeg.fsdb");
//   $fsdbDumpvars;
end

// ===== parameters & golden answers ===== //
reg [BW_PER_ACT*3-1:0] data [0:N1-1];
reg [BW_PER_ACT-1:0] data_R [0:N1-1];
reg [BW_PER_ACT-1:0] data_G [0:N1-1];
reg [BW_PER_ACT-1:0] data_B [0:N1-1];

reg [23-1:0] code_ans[0:N2-1]; //2484 2416 2482 2397
reg [23-1:0] code_ans2[0:N2-1]; //2484 2416 2482 2397
reg [IN_WIDTH-1:0] golden_Y[0:N1-1];
reg [IN_WIDTH-1:0] golden_U[0:N1-1];
reg [IN_WIDTH-1:0] golden_V[0:N1-1];
integer i, j;

initial begin
    $display("Start Reading RGB Data........");
    if(`TEST_DATA === 0) begin
      $readmemh("../../SW/TP/param/img_96x64.txt", data);
    end
    else if(`TEST_DATA === 1)begin
      $readmemh("../../SW/TP/param/img_91x61.txt", data);
    end
    else if(`TEST_DATA === 2)begin
      $readmemh("../../SW/TP/param/img_800x600.txt", data);
    end
    else begin
      $readmemh("../../SW/TP/param/img_1920x1280.txt", data);
    end
    for(i = 0; i < N1; i = i + 1) begin
      data_R[i] = data[i][BW_PER_ACT*3-1:BW_PER_ACT*2];
	    data_G[i] = data[i][BW_PER_ACT*2-1:BW_PER_ACT*1];
	    data_B[i] = data[i][BW_PER_ACT*1-1:BW_PER_ACT*0];
    end
    $display("Start Loading Data into SRAM........");
    // store param into sram
    for(i=0; i<N1; i=i+1) begin
        sram_Nx8b_R.load_param(i, 0);
        sram_Nx8b_G.load_param(i, 0);
      	sram_Nx8b_B.load_param(i, 0);
    end
    if(`TEST_DATA === 0) begin
      for(i=0; i<96*64; i=i+1) begin
        sram_Nx8b_R.load_param(i, data_R[i]);
      	sram_Nx8b_G.load_param(i, data_G[i]);
      	sram_Nx8b_B.load_param(i, data_B[i]);
      end
    end
    else if(`TEST_DATA === 1) begin
      for(i=0; i<91*61; i=i+1) begin
        sram_Nx8b_R.load_param(i, data_R[i]);
      	sram_Nx8b_G.load_param(i, data_G[i]);
      	sram_Nx8b_B.load_param(i, data_B[i]);
      end
    end
    else if(`TEST_DATA === 2) begin
      for(i=0; i<800*600; i=i+1) begin
        sram_Nx8b_R.load_param(i, data_R[i]);
      	sram_Nx8b_G.load_param(i, data_G[i]);
      	sram_Nx8b_B.load_param(i, data_B[i]);
      end
    end
    else begin
      for(i=0; i<1920*1280; i=i+1) begin
        sram_Nx8b_R.load_param(i, data_R[i]);
      	sram_Nx8b_G.load_param(i, data_G[i]);
      	sram_Nx8b_B.load_param(i, data_B[i]);
      end
    end
    $display("Start Reading Golden Data........");
    // read golden data 
    if(`TEST_DATA === 0) begin
      if(`SAMPLE_MODE === 0) begin
        $readmemb("../../SW/TP/golden/golden_96x64_411.txt", code_ans);
        $readmemb("../../SW/TP/golden/golden_96x64_z_411.txt", code_ans2);
        $readmemh("../../SW/TP/golden/decode_Y_96x64_411.txt", golden_Y);
        $readmemh("../../SW/TP/golden/decode_U_96x64_411.txt", golden_U);
        $readmemh("../../SW/TP/golden/decode_V_96x64_411.txt", golden_V);
      end
      else begin
        $readmemb("../../SW/TP/golden/golden_96x64_420.txt", code_ans);
        $readmemb("../../SW/TP/golden/golden_96x64_z_420.txt", code_ans2);
        $readmemh("../../SW/TP/golden/decode_Y_96x64_420.txt", golden_Y);
        $readmemh("../../SW/TP/golden/decode_U_96x64_420.txt", golden_U);
        $readmemh("../../SW/TP/golden/decode_V_96x64_420.txt", golden_V);
      end
    end
    else if(`TEST_DATA === 1) begin
      if(`SAMPLE_MODE === 0) begin
        $readmemb("../../SW/TP/golden/golden_91x61_411.txt", code_ans);
        $readmemb("../../SW/TP/golden/golden_91x61_z_411.txt", code_ans2);
        $readmemh("../../SW/TP/golden/decode_Y_91x61_411.txt", golden_Y);
        $readmemh("../../SW/TP/golden/decode_U_91x61_411.txt", golden_U);
        $readmemh("../../SW/TP/golden/decode_V_91x61_411.txt", golden_V);
      end
      else begin
        $readmemb("../../SW/TP/golden/golden_91x61_420.txt", code_ans);
        $readmemb("../../SW/TP/golden/golden_91x61_z_420.txt", code_ans2);
        $readmemh("../../SW/TP/golden/decode_Y_91x61_420.txt", golden_Y);
        $readmemh("../../SW/TP/golden/decode_U_91x61_420.txt", golden_U);
        $readmemh("../../SW/TP/golden/decode_V_91x61_420.txt", golden_V);
      end
    end
    else if(`TEST_DATA === 2) begin
      if(`SAMPLE_MODE === 0) begin
        $readmemb("../../SW/TP/golden/golden_800x600_411.txt", code_ans);
        $readmemb("../../SW/TP/golden/golden_800x600_z_411.txt", code_ans2);
        $readmemh("../../SW/TP/golden/decode_Y_800x600_411.txt", golden_Y);
        $readmemh("../../SW/TP/golden/decode_U_800x600_411.txt", golden_U);
        $readmemh("../../SW/TP/golden/decode_V_800x600_411.txt", golden_V);
      end
      else begin
        $readmemb("../../SW/TP/golden/golden_800x600_420.txt", code_ans);
        $readmemb("../../SW/TP/golden/golden_800x600_z_420.txt", code_ans2);
        $readmemh("../../SW/TP/golden/decode_Y_800x600_420.txt", golden_Y);
        $readmemh("../../SW/TP/golden/decode_U_800x600_420.txt", golden_U);
        $readmemh("../../SW/TP/golden/decode_V_800x600_420.txt", golden_V);
      end
    end
    else begin
      if(`SAMPLE_MODE === 0) begin
        $readmemb("../../SW/TP/golden/golden_1920x1280_411.txt", code_ans);
        $readmemb("../../SW/TP/golden/golden_1920x1280_z_411.txt", code_ans2);
        $readmemh("../../SW/TP/golden/decode_Y_1920x1280_411.txt", golden_Y);
        $readmemh("../../SW/TP/golden/decode_U_1920x1280_411.txt", golden_U);
        $readmemh("../../SW/TP/golden/decode_V_1920x1280_411.txt", golden_V);
      end
      else begin
        $readmemb("../../SW/TP/golden/golden_1920x1280_420.txt", code_ans);
        $readmemb("../../SW/TP/golden/golden_1920x1280_z_420.txt", code_ans2);
        $readmemh("../../SW/TP/golden/decode_Y_1920x1280_420.txt", golden_Y);
        $readmemh("../../SW/TP/golden/decode_U_1920x1280_420.txt", golden_U);
        $readmemh("../../SW/TP/golden/decode_V_1920x1280_420.txt", golden_V);
      end
    end
    $display("End of Reading Golden Data........");
end

// ===== system reset ===== //
initial begin
    clk = 0;
    rst_n = 1;
    enable = 0;
    encode = 1;
    if(`SAMPLE_MODE === 0) begin
      sample_mode = 0;
    end
    else begin
      sample_mode = 1;
    end
    if(`TEST_DATA === 0) begin
      img_width = 96;
      img_height = 64;
    end
    else if(`TEST_DATA === 1) begin
      img_width = 91;
      img_height = 61;
    end
    else if(`TEST_DATA === 2) begin
      img_width = 800;
      img_height = 600;
    end
    else begin
      img_width = 1920;
      img_height = 1280;
    end
end

always #(CYCLE/2) clk = ~clk;

initial begin
    #(CYCLE*END_CYCLES);
    $display("\n========================================================");
    $display("You have exceeded the cycle count limit.");
    $display("Try to debug your code or you can enlarge the cycle count limit!");
    $display("========================================================");
    $finish;    
end

// ===== cycle counter ===== //
real cycle_cnt = 0;
real cycle_cnt2 = 0;

initial begin
    wait(enable);
    @(negedge clk);

    while(finish !== 1) begin 
        cycle_cnt = cycle_cnt+1;
        @(negedge clk);
    end

	wait(enable);
	@(negedge clk);

	while(finish !== 1) begin
		cycle_cnt2 = cycle_cnt2 + 1;
		@(negedge clk);
	end
end

// ===== input feeding ===== //
initial begin
    @(negedge clk);
    rst_n = 1'b0;
    $display("Start Input Feeding........");
    @(negedge clk);
    rst_n = 1'b1;
    enable = 1'b1;
end

// ===== output comparision ===== //
integer error = 0;
integer ii, jj;
integer pass_cnt = 0;
integer ans_ptr = 0;
integer ans_len;
integer index;
integer len1, len2;
real total_pix;
real total_rgb;
real total_bit = 0;

initial begin
  if(`TEST_DATA === 0) begin
    total_rgb = 96*64*3*8;
    total_pix = 96*64;
    len1 = 96*64;
    if(`SAMPLE_MODE === 0) begin
      ans_len = 2484;
      len2 = 24*64;
    end
    else begin
      ans_len = 2482;
      len2 = 48*32;
    end
  end
  else if(`TEST_DATA === 1)begin
    total_rgb = 91*61*3*8;
    total_pix = 91*61;
    len1 = 91*61;
    if(`SAMPLE_MODE === 0) begin
      ans_len = 2416;
      len2 = 23*61;
    end
    else begin
      ans_len = 2397;
      len2 = 46*31;
    end
  end
  else if(`TEST_DATA === 2)begin
    total_rgb = 800*600*3*8;
    total_pix = 800*600;
    len1 = 800*600;
    if(`SAMPLE_MODE === 0) begin
      ans_len = 56967;
      len2 = 200*600;
    end
    else begin
      ans_len = 56884;
      len2 = 400*300;
    end
  end
  else begin
    total_rgb = 1920*1280*3*8;
    total_pix = 1920*1280;
    len1 = 1920*1280;
    if(`SAMPLE_MODE === 0) begin
      ans_len = 529376;
      len2 = 480*1280;
    end
    else begin
      ans_len = 531497;
      len2 = 960*640;
    end
  end

  $display("Start Output Comparing........");
  @(negedge clk);
  @(negedge clk);
  @(negedge clk);
  @(negedge clk);
  while(!finish) begin
    @(negedge clk);
    if(bit_valid_out !== 0) begin
      if(wdata_23b === code_ans2[ans_ptr]) begin
	if(pass_cnt % 1000 === 0) begin
        	$display("RTL:%23b, GOLDEN:%23b", wdata_23b, code_ans2[ans_ptr]);
		$display("Pass %d code", pass_cnt);
	end
        ans_ptr = ans_ptr + 1;
	pass_cnt = pass_cnt + 1;
        total_bit = total_bit + bit_valid_out;
      end
      else begin
        $display("*****************************************");
	$display("             Error occurred");
        $display("*****************************************");
        $display("RTL:%23b, GOLDEN:%23b", wdata_23b, code_ans2[ans_ptr]);
        #(CYCLE);
	/*
        $display("*****************************************");
	$display("     Data in register after quantize");
        $display("*****************************************");
        for (ii = 0; ii < 8; ii = ii + 1) begin
          for (jj = 0; jj < 8; jj = jj + 1) begin
            $display("(row = %3d, col = %3d), RTL: %6g,", ii, jj, $signed(top.reg_U0.register[ii][jj]));
	  end
	end
	*/
	$finish;
      end
    end
  end
  if(ans_ptr != ans_len) begin //2484 2416 2482 2397
    $display("\n");
    $display("*****************************************");
    $display("          Still code left!!!!!");
    $display("*****************************************");
    $display("\n");
    $finish;
  end
  else begin
    $display("\n");
    $display("*****************************************");
    $display("      All Answers Are Correct!!!!!");
    $display("*****************************************");
    $display("\n");
  end
  $display("\n");
  $display("*****************************************");
  $display("            Start decode                 ");
  $display("*****************************************");
  $display("\n");
  @(negedge clk);
  rst_n = 1'b0;
  enable = 1'b0;
  encode = 1'b0;
  @(negedge clk);
  rst_n = 1'b1;
  enable = 1'b1;
  wait(finish == 1);
  $display("\n");
  $display("*****************************************");
  $display("      Start Output Comparing             ");
  $display("*****************************************");
  $display("\n");
  $display("Compare Y.....................");
  for(index = 0; index < len1; index=index+1) begin
    if(sram_Nx8b_R.mem[index] !== golden_Y[index]) begin
      $display("Wrong! index = %d, %d, %d", index, $signed(sram_Nx8b_R.mem[index]), $signed(golden_Y[index]));
	    $finish;
    end
    else if(index % 1000 === 0) begin
      $display("Correct! index = %d", index);
    end
  end
  $display("Compare U.....................");
  for(index = 0; index < len2; index=index+1) begin
    if(sram_Nx8b_G.mem[index] !== golden_U[index]) begin
      $display("Wrong! index = %d", index);
	    $finish;
    end
    else if(index % 1000 === 0) begin
      $display("Correct! index = %d", index);
    end
  end
  $display("Compare V.....................");
  for(index = 0; index < len2; index=index+1) begin
    if(sram_Nx8b_B.mem[index] !== golden_V[index]) begin
      $display("Wrong! index = %d", index);
	    $finish;
    end
    else if(index % 1000 === 0) begin
      $display("Correct! index = %d", index);
    end
  end
  $display("*****************************************");
  $display("             All Correct!!!!!!!!!!!!!!!!!");
  $display("*****************************************");
  $display("*****************************************");
  $display("       Performance of Compress Part      ");
  $display("         Compression: %f", (total_bit/total_rgb));
  $display("     Throughput: %fM pixels/sec", (total_pix*(10**3))/(CYCLE*cycle_cnt));
  $display("*****************************************");
  $display("      Performance of Decompress Part      ");
  $display("     Throughput: %fM pixels/sec", (total_pix*(10**3))/(CYCLE*cycle_cnt2));
  $display("*****************************************");
  $finish;
end

endmodule
