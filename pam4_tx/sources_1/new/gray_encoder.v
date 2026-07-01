`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.04.2026 16:04:24
// Design Name: 
// Module Name: gray_encoder
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


module gray_encoder (
    input  [1:0] in,
    output reg [1:0] out
);
    always @(*) begin
        case (in)
            2'b00: out = 2'd0;
            2'b01: out = 2'd1;
            2'b11: out = 2'd2;
            2'b10: out = 2'd3;
        endcase
    end
endmodule
