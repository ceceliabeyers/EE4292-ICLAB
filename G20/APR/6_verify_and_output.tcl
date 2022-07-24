verify_lvs -ignore_floating_port
source -echo ../addCoreFiller.tcl
save_mw_cel CHIP
save_mw_cel -as 6_corefiller

set_write_stream_options -map_layer /usr/cadtool/cad/synopsys/SAED32_EDK/tech/milkyway/saed32nm_1p9m_gdsout_mw.map -child_depth 20 -flatten_via

verify_lvs -ignore_floating_port

write_stream -format gds -lib_name  CHIP -cells {6_corefiller } ../netlist/CHIP.gds

write_verilog -diode_ports -wire_declaration -keep_backslash_before_hiersep  -no_physical_only_cells -supply_statement none ../netlist/CHIP_layout.v

write_sdf -version 1.0 -context verilog ../netlist/CHIP_layout.sdf

write_sdc ../netlist/CHIP_layout.sdc -version 2.1

extract_rc

write_parasitics -output ../netlist/CHIP_layout -format SPEF -compress

report_timing > ../report_setup.rpt
report_timing -delay_type min > ../report_hold.rpt
report_power > ../report_power.rpt
report_area > ../report_area.rpt
verify_zrt_route > ../report_DRC.rpt
verify_lvs -ignore_floating_port > ../report_LVS.rpt

