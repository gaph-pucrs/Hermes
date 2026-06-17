## build.tcl — bitstream only; invoked by Make when post_route.dcp changes

set top FpgaTop
set out ./build

open_checkpoint $out/post_route.dcp

write_bitstream -force $out/$top.bit

puts "\nDone. Bitfile: $out/$top.bit"
