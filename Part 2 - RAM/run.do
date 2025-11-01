vlib work
vlog  -f src_files.list
#vlog +define+SIM +cover  *.sv
vsim -voptargs=+acc work.top -classdebug -uvmcontrol=all
add wave /top/RAMif/*
add wave /top/dut/inst_sva/_2a
add wave /top/dut/inst_sva/_3a
run 0

run -all
coverage save RAM.ucdb -onexit
#vcover report RAM.ucdb -details -annotate -all -output coverage_rpt.txt


