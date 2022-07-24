set power_enable_analysis true
set power_analysis_mode time_based
set power_enable_clock_scaling true

set search_path ". /usr/cadtool/SAED32_EDK/lib/stdcell_hvt/db_nldm/  \
                   /usr/cadtool/SAED32_EDK/lib/io_std/db_nldm/ \
                   /usr/cadtool/SAED32_EDK/synthesis/cur/libraries/syn \
                   $search_path"
set target_library  "saed32hvt_ss0p95v125c.db \
                     saed32hvt_ff1p16vn40c.db \
                     saed32io_wb_ss0p95v125c_2p25v.db \
                     saed32io_wb_ff1p16vn40c_2p75v.db "
set link_library  "  * $target_library  \
                       dw_foundation.sldb "
read_verilog  ../netlist/CHIP_layout.v
current_design  CHIP
link
read_sdc ../netlist/CHIP_layout.sdc
read_parasitics ../netlist/CHIP_layout.max.gz

read_vcd ../posim/post_sim.fsdb -strip_path test_top_all/CHIP

check_power
update_power
report_power  -hier > pt_power_hier.rpt
report_power  > pt_power.rpt
exit
