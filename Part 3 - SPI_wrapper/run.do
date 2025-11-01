vlib work
vlog +define+SIM -f src_files.list +cover -covercells
vsim -voptargs=+acc work.top -classdebug -uvmcontrol=all -cover
vlog -cover bcs -f src_files.list
add wave /top/SPI_wrapperif/*
add wave /top/DUT/*
add wave /top/REF/*
run 0
run -all
coverage save top.ucdb -onexit
vcover report top.ucdb -details -annotate -all -output coverage_rpt.txt