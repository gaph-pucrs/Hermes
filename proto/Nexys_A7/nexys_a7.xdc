## Nexys A7-100T — Hermes NoC PoC constraints
## Verify pin assignments against the official Digilent Nexys A7 Master XDC
## before programming.

## -------------------------------------------------------------------------
## Clock — 100 MHz
## -------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk_i]
create_clock -name sys_clk -period 10.000 [get_ports clk_i]

## -------------------------------------------------------------------------
## Reset — CPU_RESETN, active low
## -------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports rst_ni]

## -------------------------------------------------------------------------
## UART TX — FPGA → FTDI (uart_txd_in on schematic)
## -------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports uart_tx_o]

## -------------------------------------------------------------------------
## LEDs (LD0–LD3)
## -------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {led_o[0]}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {led_o[1]}]
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {led_o[2]}]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {led_o[3]}]

## -------------------------------------------------------------------------
## Timing exceptions
## -------------------------------------------------------------------------
## Relax CDC between the always-1 credit bus and NoC internals (none here).
## Constrain false path on reset tree if needed.
set_false_path -from [get_ports rst_ni]
