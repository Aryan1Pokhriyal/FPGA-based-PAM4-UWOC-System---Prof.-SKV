`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.04.2026 16:03:03
// Design Name: 
// Module Name: delay_block
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


module delay_block (
    input clk,
    input rst,
    input en,
    input [3:0] sel,
    input din,
    output dout
);
    reg [15:0] shift;

    always @(posedge clk) begin
        if (rst)
            shift <= 0;
        else if (en)
            shift <= {shift[14:0], din};
    end

    assign dout = shift[sel];
endmodule
