`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.04.2026 13:50:44
// Design Name: 
// Module Name: bin_to_gray_2bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bin_to_gray_2bit (
    input  wire [1:0] sw,
    output wire [1:0] LED
);

    assign LED[1] = sw[1];
    assign LED[0] = sw[1] ^ sw[0];

endmodule