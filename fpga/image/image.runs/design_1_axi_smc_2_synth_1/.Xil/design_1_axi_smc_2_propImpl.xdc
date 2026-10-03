set_property SRC_FILE_INFO {cfile:c:/Users/eziochen/Desktop/fpga_project/fpga/image/image.gen/sources_1/bd/design_1/ip/design_1_axi_smc_2/bd_0/ip/ip_0/bd_6e42_sc_ul_0_cdc.xdc rfile:../../../image.gen/sources_1/bd/design_1/ip/design_1_axi_smc_2/bd_0/ip/ip_0/bd_6e42_sc_ul_0_cdc.xdc id:1 order:EARLY scoped_inst:inst/sc_ul/inst} [current_design]
current_instance inst/sc_ul/inst
set_property src_info {type:SCOPED_XDC file:1 line:22 export:INPUT save:INPUT read:READ} [current_design]
create_waiver -type CDC -id {CDC-7} -user "axi_switch" -desc "Debug output only; no operational CDC" -tags "1171415" -scope -internal -to [get_pins -filter REF_PIN_NAME=~*CLR -of_objects [get_cells -hierarchical -filter {NAME =~ *si_checker_inst/*}]]
set_property src_info {type:SCOPED_XDC file:1 line:27 export:INPUT save:INPUT read:READ} [current_design]
create_waiver -type CDC -id {CDC-11} -user "axi_switch" -desc "AXI Switch resets contain known-good CDC paths" -tags "1171415" -scope -internal -from [get_pins -quiet -filter REF_PIN_NAME=~*C -of_objects [get_cells -hierarchical -filter {NAME =~ *gen_axi_full_nxm.sasd_inst/gen_write.m_wdata_reg*}]]
