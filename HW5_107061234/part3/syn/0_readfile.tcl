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
set HDL_DIR "../hdl"
analyze -library $TOPLEVEL -format verilog "$HDL_DIR/Convnet_top.v"
analyze -library $TOPLEVEL -format verilog "$HDL_DIR/control.v"
analyze -library $TOPLEVEL -format verilog "$HDL_DIR/unshuffle.v"
analyze -library $TOPLEVEL -format verilog "$HDL_DIR/conv_ctrl.v"
analyze -library $TOPLEVEL -format verilog "$HDL_DIR/mul.v"

# elaborate your design
elaborate $TOPLEVEL -architecture verilog -library $TOPLEVEL

# Solve Multiple Instance
set uniquify_naming_style "%s_mydesign_%d"
uniquify

# link the design
current_design $TOPLEVEL
link
