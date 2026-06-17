## impl.tcl — implementation only; invoked by Make when post_synth.dcp changes

set out ./build

set_param general.maxThreads 32
set_param route.maxThreads   32

open_checkpoint $out/post_synth.dcp

opt_design
place_design
phys_opt_design
route_design

write_checkpoint -force $out/post_route.dcp
report_timing_summary -file $out/timing.rpt
report_utilization    -file $out/utilization_route.rpt
report_utilization -hierarchical -hierarchical_depth 4 -file $out/utilization_hier.rpt

puts "\nDone. Checkpoint: $out/post_route.dcp"
