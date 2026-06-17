## prog.tcl — Program Nexys A7 via JTAG
## Usage: vivado -mode batch -source prog.tcl
## Ensure the board is connected and powered before running.

set bitfile "./build/FpgaTop.bit"

open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target

set dev [lindex [get_hw_devices] 0]
current_hw_device $dev
refresh_hw_device -update_hw_probes false $dev

set_property PROGRAM.FILE $bitfile $dev
program_hw_devices $dev
refresh_hw_device $dev

puts "Programmed: $bitfile"
close_hw_manager
