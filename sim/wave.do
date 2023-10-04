onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 50 {PE 1x0}
add wave -noupdate {/tb/noc1/genblk1[1]/genblk1[0]/router/clk_i}
add wave -noupdate {/tb/noc1/genblk1[1]/genblk1[0]/router/rx_i}
add wave -noupdate -expand {/tb/noc1/genblk1[1]/genblk1[0]/router/credit_o}
add wave -noupdate -expand {/tb/noc1/genblk1[1]/genblk1[0]/router/data_i}
add wave -noupdate {/tb/noc1/genblk1[1]/genblk1[0]/router/tx_o}
add wave -noupdate {/tb/noc1/genblk1[1]/genblk1[0]/router/credit_i}
add wave -noupdate -expand {/tb/noc1/genblk1[1]/genblk1[0]/router/data_o}
add wave -noupdate -divider -height 50 {PE 2x0}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[0]/router/clk_i}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[0]/router/rx_i}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[0]/router/credit_o}
add wave -noupdate -expand {/tb/noc1/genblk1[2]/genblk1[0]/router/data_i}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[0]/router/tx_o}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[0]/router/credit_i}
add wave -noupdate -expand {/tb/noc1/genblk1[2]/genblk1[0]/router/data_o}
add wave -noupdate -divider -height 50 {PE 2x1}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/clk_i}
add wave -noupdate -expand {/tb/noc1/genblk1[2]/genblk1[1]/router/rx_i}
add wave -noupdate -expand {/tb/noc1/genblk1[2]/genblk1[1]/router/credit_o}
add wave -noupdate -expand {/tb/noc1/genblk1[2]/genblk1[1]/router/data_i}
add wave -noupdate -expand {/tb/noc1/genblk1[2]/genblk1[1]/router/tx_o}
add wave -noupdate -expand {/tb/noc1/genblk1[2]/genblk1[1]/router/credit_i}
add wave -noupdate -expand {/tb/noc1/genblk1[2]/genblk1[1]/router/data_o}
add wave -noupdate -divider -height 25 {PE 2x1 Buffer NORTH}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/clk_i}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/req_o}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/req_ack_i}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/rx_i}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/credit_o}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/data_i}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/data_av_o}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/data_ack_i}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/data_o}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/sending_o}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/full}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/empty}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/head}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/tail}
add wave -noupdate -expand {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/buffer}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/can_receive}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/can_send}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/state}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[2]/buffer/flit_cntr}
add wave -noupdate -divider -height 25 {PE 2x1 Buffer SOUTH}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/clk_i}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/req_o}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/req_ack_i}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/rx_i}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/credit_o}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/data_i}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/data_av_o}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/data_ack_i}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/data_o}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/sending_o}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/full}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/empty}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/head}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/tail}
add wave -noupdate -expand {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/buffer}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/can_receive}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/can_send}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/state}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/genblk1[3]/buffer/flit_cntr}
add wave -noupdate -divider -height 25 {PE 2x1 SWITCH}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/clk_i}
add wave -noupdate -expand {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/req_i}
add wave -noupdate -expand {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/ack_o}
add wave -noupdate -expand {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/data_i}
add wave -noupdate -expand {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/free_o}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/inport_o}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/outport_o}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/dirs}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/dim}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/state}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/next_state}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/has_req}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/sel_port}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/next_port}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/target}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/tgts}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/force_io}
add wave -noupdate {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/force_port}
add wave -noupdate -expand {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/sending_i}
add wave -noupdate -expand {/tb/noc1/genblk1[2]/genblk1[1]/router/switch/sending_r}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1305 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1072 ns} {1605 ns}
