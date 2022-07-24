###################################################################

# Created by write_sdc on Mon Jan 17 09:29:49 2022

###################################################################
set sdc_version 2.1

set_units -time ns -resistance MOhm -capacitance fF -voltage V -current uA
set_operating_conditions ss0p95v125c -library saed32hvt_ss0p95v125c
set_wire_load_mode enclosed
set_max_fanout 0.82 [current_design]
set_wire_load_selection_group predcaps
set_max_area 0
set_ideal_network [get_ports clk]
create_clock [get_ports clk]  -period 2.5  -waveform {0 1.25}
set_input_delay -clock clk  1  [get_ports rst_n]
set_input_delay -clock clk  1  [get_ports enable]
set_input_delay -clock clk  1  [get_ports sample_mode]
set_input_delay -clock clk  1  [get_ports encode]
set_input_delay -clock clk  1  [get_ports {R[7]}]
set_input_delay -clock clk  1  [get_ports {R[6]}]
set_input_delay -clock clk  1  [get_ports {R[5]}]
set_input_delay -clock clk  1  [get_ports {R[4]}]
set_input_delay -clock clk  1  [get_ports {R[3]}]
set_input_delay -clock clk  1  [get_ports {R[2]}]
set_input_delay -clock clk  1  [get_ports {R[1]}]
set_input_delay -clock clk  1  [get_ports {R[0]}]
set_input_delay -clock clk  1  [get_ports {G[7]}]
set_input_delay -clock clk  1  [get_ports {G[6]}]
set_input_delay -clock clk  1  [get_ports {G[5]}]
set_input_delay -clock clk  1  [get_ports {G[4]}]
set_input_delay -clock clk  1  [get_ports {G[3]}]
set_input_delay -clock clk  1  [get_ports {G[2]}]
set_input_delay -clock clk  1  [get_ports {G[1]}]
set_input_delay -clock clk  1  [get_ports {G[0]}]
set_input_delay -clock clk  1  [get_ports {B[7]}]
set_input_delay -clock clk  1  [get_ports {B[6]}]
set_input_delay -clock clk  1  [get_ports {B[5]}]
set_input_delay -clock clk  1  [get_ports {B[4]}]
set_input_delay -clock clk  1  [get_ports {B[3]}]
set_input_delay -clock clk  1  [get_ports {B[2]}]
set_input_delay -clock clk  1  [get_ports {B[1]}]
set_input_delay -clock clk  1  [get_ports {B[0]}]
set_input_delay -clock clk  1  [get_ports {code[22]}]
set_input_delay -clock clk  1  [get_ports {code[21]}]
set_input_delay -clock clk  1  [get_ports {code[20]}]
set_input_delay -clock clk  1  [get_ports {code[19]}]
set_input_delay -clock clk  1  [get_ports {code[18]}]
set_input_delay -clock clk  1  [get_ports {code[17]}]
set_input_delay -clock clk  1  [get_ports {code[16]}]
set_input_delay -clock clk  1  [get_ports {code[15]}]
set_input_delay -clock clk  1  [get_ports {code[14]}]
set_input_delay -clock clk  1  [get_ports {code[13]}]
set_input_delay -clock clk  1  [get_ports {code[12]}]
set_input_delay -clock clk  1  [get_ports {code[11]}]
set_input_delay -clock clk  1  [get_ports {code[10]}]
set_input_delay -clock clk  1  [get_ports {code[9]}]
set_input_delay -clock clk  1  [get_ports {code[8]}]
set_input_delay -clock clk  1  [get_ports {code[7]}]
set_input_delay -clock clk  1  [get_ports {code[6]}]
set_input_delay -clock clk  1  [get_ports {code[5]}]
set_input_delay -clock clk  1  [get_ports {code[4]}]
set_input_delay -clock clk  1  [get_ports {code[3]}]
set_input_delay -clock clk  1  [get_ports {code[2]}]
set_input_delay -clock clk  1  [get_ports {code[1]}]
set_input_delay -clock clk  1  [get_ports {code[0]}]
set_input_delay -clock clk  1  [get_ports {img_width[10]}]
set_input_delay -clock clk  1  [get_ports {img_width[9]}]
set_input_delay -clock clk  1  [get_ports {img_width[8]}]
set_input_delay -clock clk  1  [get_ports {img_width[7]}]
set_input_delay -clock clk  1  [get_ports {img_width[6]}]
set_input_delay -clock clk  1  [get_ports {img_width[5]}]
set_input_delay -clock clk  1  [get_ports {img_width[4]}]
set_input_delay -clock clk  1  [get_ports {img_width[3]}]
set_input_delay -clock clk  1  [get_ports {img_width[2]}]
set_input_delay -clock clk  1  [get_ports {img_width[1]}]
set_input_delay -clock clk  1  [get_ports {img_width[0]}]
set_input_delay -clock clk  1  [get_ports {img_height[10]}]
set_input_delay -clock clk  1  [get_ports {img_height[9]}]
set_input_delay -clock clk  1  [get_ports {img_height[8]}]
set_input_delay -clock clk  1  [get_ports {img_height[7]}]
set_input_delay -clock clk  1  [get_ports {img_height[6]}]
set_input_delay -clock clk  1  [get_ports {img_height[5]}]
set_input_delay -clock clk  1  [get_ports {img_height[4]}]
set_input_delay -clock clk  1  [get_ports {img_height[3]}]
set_input_delay -clock clk  1  [get_ports {img_height[2]}]
set_input_delay -clock clk  1  [get_ports {img_height[1]}]
set_input_delay -clock clk  1  [get_ports {img_height[0]}]
set_output_delay -clock clk  1.25  [get_ports wsb_Y]
set_output_delay -clock clk  1.25  [get_ports wsb_U]
set_output_delay -clock clk  1.25  [get_ports wsb_V]
set_output_delay -clock clk  1.25  [get_ports wsb_23b]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[21]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[20]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[19]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[18]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[17]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[16]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[15]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[14]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[13]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[12]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[11]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[10]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[9]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[8]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[7]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[6]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[5]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[4]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[3]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[2]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[1]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_8b[0]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[19]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[18]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[17]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[16]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[15]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[14]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[13]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[12]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[11]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[10]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[9]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[8]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[7]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[6]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[5]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[4]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[3]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[2]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[1]}]
set_output_delay -clock clk  1.25  [get_ports {sram_raddr_23b[0]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_8b[7]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_8b[6]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_8b[5]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_8b[4]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_8b[3]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_8b[2]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_8b[1]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_8b[0]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[22]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[21]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[20]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[19]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[18]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[17]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[16]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[15]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[14]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[13]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[12]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[11]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[10]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[9]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[8]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[7]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[6]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[5]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[4]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[3]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[2]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[1]}]
set_output_delay -clock clk  1.25  [get_ports {wdata_23b[0]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[21]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[20]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[19]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[18]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[17]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[16]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[15]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[14]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[13]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[12]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[11]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[10]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[9]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[8]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[7]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[6]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[5]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[4]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[3]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[2]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[1]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_8b[0]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[19]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[18]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[17]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[16]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[15]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[14]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[13]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[12]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[11]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[10]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[9]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[8]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[7]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[6]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[5]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[4]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[3]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[2]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[1]}]
set_output_delay -clock clk  1.25  [get_ports {waddr_23b[0]}]
set_output_delay -clock clk  1.25  [get_ports {bit_valid_out[4]}]
set_output_delay -clock clk  1.25  [get_ports {bit_valid_out[3]}]
set_output_delay -clock clk  1.25  [get_ports {bit_valid_out[2]}]
set_output_delay -clock clk  1.25  [get_ports {bit_valid_out[1]}]
set_output_delay -clock clk  1.25  [get_ports {bit_valid_out[0]}]
set_output_delay -clock clk  1.25  [get_ports finish]