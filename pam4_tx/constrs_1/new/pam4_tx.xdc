## =============================================================================
## pam4_tx.xdc  -  Basys3 pin constraints for the PAM4 Transmitter board
## =============================================================================

## ---- 100 MHz system clock ---------------------------------------------------
set_property PACKAGE_PIN W5      [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## ---- Active-low reset (CPU_RESETN push-button, slide to release = HIGH) -----
set_property PACKAGE_PIN C12     [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

## ---- JA PMOD outputs --------------------------------------------------------
## JA1 (J1) = tx0  - Gray[0] LSB of 2-bit PAM4 symbol
set_property PACKAGE_PIN J1      [get_ports tx0]
set_property IOSTANDARD LVCMOS33 [get_ports tx0]

## JA2 (L2) = tx1  - Gray[1] MSB of 2-bit PAM4 symbol
set_property PACKAGE_PIN L2      [get_ports tx1]
set_property IOSTANDARD LVCMOS33 [get_ports tx1]

## ---- Timing: outputs are slow (< 10 kHz), no timing constraint needed ------
set_false_path -to [get_ports tx0]
set_false_path -to [get_ports tx1]
