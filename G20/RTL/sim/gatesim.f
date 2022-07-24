./test_top.v

../../SYN/netlist/top_syn.v
-v /usr/cadtool/cad/synopsys/SAED32_EDK/lib/stdcell_hvt/verilog/saed32nm_hvt.v
../hdl/sram_Nx23b.v
../hdl/sram_Nx8b.v
+access+r
+define+GATESIM
//+define+TEST_DATA=0 +define+SAMPLE_MODE=0
// TEST_DATA:   0 for 96*64, 1 for 91*61, 2 for 800*600
// SAMPLE_MODE: 0 for 4:1:1. 1 for 4:2:0
