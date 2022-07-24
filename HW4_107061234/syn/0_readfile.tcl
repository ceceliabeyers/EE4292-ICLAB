
set TOP_DIR $TOPLEVEL
set RPT_DIR report
set NET_DIR netlist

sh rm -rf ./$TOP_DIR
sh rm -rf ./$RPT_DIR
sh rm -rf ./$NET_DIR
sh mkdir ./$TOP_DIR
sh mkdir ./$RPT_DIR
sh mkdir ./$NET_DIR

define_design_lib $TOPLEVEL -path ./$TOPLEVEL
													   
set HDL_DIR "../hdl"

#Read Design File (add your files here)
analyze -library $TOPLEVEL -format verilog {"../hdl/qr_decode.v" "../hdl/qr_find.v" "../hdl/sram_addr_90.v" "../hdl/sram_addr_0.v" "../hdl/qr_control.v" "../hdl/galois.v" "../hdl/galois2.v" "../hdl/qr_demask.v"}
# put all your HDL here
										   
elaborate $TOPLEVEL -architecture verilog -library $TOPLEVEL

#Solve Multiple Instance
set uniquify_naming_style "%s_mydesign_%d"
uniquify

current_design $TOPLEVEL
link    
