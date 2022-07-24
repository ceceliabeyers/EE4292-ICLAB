set TOP_DIR $TOPLEVEL
set RPT_DIR report
set NET_DIR netlist

sh rm -rf ./$TOP_DIR
sh rm -rf ./$RPT_DIR
sh rm -rf ./$NET_DIR
sh mkdir ./$TOP_DIR
sh mkdir ./$RPT_DIR
sh mkdir ./$NET_DIR

# define a lib path here
define_design_lib $TOPLEVEL -path ./$TOPLEVEL

# Read Design File (add your files here)
set HDL_DIR "../RTL/hdl"
analyze -library $TOPLEVEL -format verilog "$HDL_DIR/$TOPLEVEL.v"
analyze -library $TOPLEVEL -format verilog "$HDL_DIR/control_en.v"
analyze -library $TOPLEVEL -format verilog "$HDL_DIR/dct1D.v"
analyze -library $TOPLEVEL -format verilog "$HDL_DIR/rgb2yuv.v"
analyze -library $TOPLEVEL -format verilog "$HDL_DIR/reg8x8.v"
analyze -library $TOPLEVEL -format verilog "$HDL_DIR/quan_DCT2D.v"
analyze -library $TOPLEVEL -format verilog "$HDL_DIR/encoder.v"
analyze -library $TOPLEVEL -format verilog "$HDL_DIR/decoder.v"
analyze -library $TOPLEVEL -format verilog "$HDL_DIR/idct1D.v"
analyze -library $TOPLEVEL -format verilog "$HDL_DIR/dequan.v"
analyze -library $TOPLEVEL -format verilog "$HDL_DIR/control_de.v"

# elaborate your design
elaborate $TOPLEVEL -architecture verilog -library $TOPLEVEL

# Solve Multiple Instance
set uniquify_naming_style "%s_mydesign_%d"
uniquify

# link the design
current_design $TOPLEVEL
link
