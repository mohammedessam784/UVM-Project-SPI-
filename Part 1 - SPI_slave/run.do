vlib work
#vlog +define+SIM -f src_files.list
vlog +define+SIM +cover  *.sv
vsim -voptargs=+acc work.top -classdebug -uvmcontrol=all
add wave /top/SPI_slaveif/*
add wave /top/*
run -all
#coverage save SPI_slave.ucdb -onexit
#vcover report SPI_slave.ucdb -details -annotate -all -output coverage_rpt.txt


