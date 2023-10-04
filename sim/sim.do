vlib work
vmap work work

vlog ../rtl/HermesPkg.sv
vlog ../rtl/HermesBuffer.sv
vlog ../rtl/HermesCrossbar.sv
vlog ../rtl/HermesSwitch.sv
vlog ../rtl/HermesRouter.sv
vlog HermesNoC.sv

vlog tb.sv

vsim work.tb -voptargs=+acc
do wave.do
run 50 us
quit
