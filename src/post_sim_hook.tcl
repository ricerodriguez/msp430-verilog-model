open_vcd /home/rice/Documents/ECE_4333/dmp/dump.vcd
log_vcd -level 1
restart
run 5000ns
stop_vcd
close_vcd
