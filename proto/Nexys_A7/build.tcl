## build.tcl — Vivado non-project batch flow for Hermes NoC PoC
## Usage: vivado -mode batch -source build.tcl

set top  FpgaTop
set part xc7a100tcsg324-1
set out  ./build

file mkdir $out

## Sources — order matters: packages first
read_verilog -sv [list \
    ../../rtl/HermesPkg.sv         \
    ../../RingBuffer/rtl/RingBuffer.sv \
    ../../rtl/HermesBuffer.sv      \
    ../../rtl/HermesCrossbar.sv    \
    ../../rtl/HermesSwitch.sv      \
    ../../rtl/HermesRouter.sv      \
    ../../sim/HermesNoC.sv         \
    UartTx.sv                      \
    TrafficGen.sv                  \
    Responder.sv                   \
    LatencyCounter.sv              \
    FpgaTop.sv                     \
]

read_xdc nexys_a7.xdc

## Synthesis
synth_design \
    -top         $top  \
    -part        $part \
    -include_dirs {../../rtl}

write_checkpoint -force $out/post_synth.dcp
report_utilization  -file $out/utilization_synth.rpt

## Implementation
opt_design
place_design
phys_opt_design
route_design

write_checkpoint -force $out/post_route.dcp
report_timing_summary -file $out/timing.rpt
report_utilization    -file $out/utilization_route.rpt

## Bitstream
write_bitstream -force $out/$top.bit

puts "\nDone. Bitfile: $out/$top.bit"
