## =============================================================================
## pam4_rx.xdc  -  Basys3 pin constraints for the PAM4 Receiver board
## =============================================================================

## ---- 100 MHz system clock ---------------------------------------------------
#set_property PACKAGE_PIN W5      [get_ports clk]
#set_property IOSTANDARD LVCMOS33 [get_ports clk]
#create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## ---- Active-low reset (CPU_RESETN push-button) ------------------------------
#set_property PACKAGE_PIN C12     [get_ports rst_n]
#set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

## ---- JA PMOD inputs (from TX board) ----------------------------------------
## JA1 (J1) = rx0  - Gray[0] LSB received from TX board JA1
#set_property PACKAGE_PIN J1      [get_ports rx0]
#set_property IOSTANDARD LVCMOS33 [get_ports rx0]

## JA2 (L2) = rx1  - Gray[1] MSB received from TX board JA2
#set_property PACKAGE_PIN L2      [get_ports rx1]
#set_property IOSTANDARD LVCMOS33 [get_ports rx1]

## ---- JA PMOD output (to CH340G) --------------------------------------------
## JA3 (J2) = uart_txd  - UART serial output (9600 8N1) to CH340G TXD pin
#set_property PACKAGE_PIN J2      [get_ports uart_txd]
#set_property IOSTANDARD LVCMOS33 [get_ports uart_txd]

## ---- Timing exceptions for async inter-board signals -----------------------
#set_false_path -from [get_ports rx0]
#set_false_path -from [get_ports rx1]
#set_false_path -to   [get_ports uart_txd]




RX

## =============================
## CLOCK
## =============================
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name sys_clk -period 10.000 [get_ports clk]

## =============================
## RESET (switch 0)
## =============================
set_property PACKAGE_PIN V17 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

## =============================
## PAM4 INPUT LINES (JA PMOD)
## =============================
## JA1 <- rx0
set_property PACKAGE_PIN J1 [get_ports rx0]
set_property IOSTANDARD LVCMOS33 [get_ports rx0]

## JA2 <- rx1
set_property PACKAGE_PIN L2 [get_ports rx1]
set_property IOSTANDARD LVCMOS33 [get_ports rx1]

## Optional: add weak pull-downs to avoid floating
set_property PULLDOWN true [get_ports rx0]
set_property PULLDOWN true [get_ports rx1]

## =============================
## UART TX (to PC)
## =============================
set_property PACKAGE_PIN J2 [get_ports uart_txd]
set_property IOSTANDARD LVCMOS33 [get_ports uart_txd]
