./test_top.v

../netlist/CHIP_layout.v
-v /usr/cadtool/SAED32_EDK/lib/stdcell_hvt/verilog/saed32nm_hvt.v
../../RTL/hdl/sram_Nx23b.v
../../RTL/hdl/sram_Nx8b.v
+access+r
//+define+TEST_DATA=0 +define+SAMPLE_MODE=0
// TEST_DATA:   0 for 96*64, 1 for 91*61, 2 for 800*600
// SAMPLE_MODE: 0 for 4:1:1. 1 for 4:2:0
