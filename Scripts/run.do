vlib work
vlog -f source_files.list -mfcu
vsim -voptargs=+acc work.Master_tb 
add wave -position insertpoint sim:/Master_tb/DUT/current_state
add wave *
run -all