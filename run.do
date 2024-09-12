vlib work
vlog -f source_files.list -mfcu
vsim -voptargs=+acc work.Master_tb 
add wave -position insertpoint sim:/Master_tb/DUT/current_state
add wave -position insertpoint  \
sim:/Master_tb/DUT/data_in_reg \
sim:/Master_tb/DUT/opcode_reg \
sim:/Master_tb/DUT/addr_reg \
sim:/Master_tb/DUT/enable__reg \
sim:/Master_tb/DUT/busy_reg \
sim:/Master_tb/DUT/new_trans
add wave *
run -all