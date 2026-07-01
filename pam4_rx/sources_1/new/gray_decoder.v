`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.04.2026 16:50:48
// Design Name: 
// Module Name: gray_decoder
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

module gray_decoder (
    input  wire [1:0] gray,
    output wire [1:0] bin
);
    assign bin[1] = gray[1];
    assign bin[0] = gray[1] ^ gray[0];
endmodule