# FPGA-based-PAM4-UWOC-System---Prof.-SKV
Developed a complete setup for Underwater Optical Wireless Communication applications on FPGAs for live image/video processing

  Designed a dual-Basys3 FPGA system (TX-RX) with PAM4 Gray-encoding (2 bits/sym) in Verilog HDL, implemented with Xilinx Artix-7 on Vivado
  Data rates exceeding 1 MHz SPI, using <0.3% of LUTs and <0.2% of flip-flops, with timing closure on a 100MHz clk (worst slack of +5.8ns)
  Sent data on FT232RL USB bridge for PC data capture using Python utilities, with SPI frame reconstruction &  conversion (EOI/SOI markers)
