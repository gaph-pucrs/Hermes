## synth.tcl — synthesis only; invoked by Make when sources change

set top  FpgaTop
set part xc7a100tcsg324-1
set out  ./build

set_param general.maxThreads 32
set_param synth.maxThreads   8

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

synth_design \
    -top         $top  \
    -part        $part \
    -include_dirs {../../rtl}

write_checkpoint -force $out/post_synth.dcp
report_utilization -file $out/utilization_synth.rpt

puts "\nDone. Checkpoint: $out/post_synth.dcp"
