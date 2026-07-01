`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.04.2026 16:05:12
// Design Name: 
// Module Name: prbs15_2bit
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


module prbs15_2bit (
    input clk,
    input rst,
    input en,
    output reg [1:0] out
);
    reg [14:0] lfsr;

    always @(posedge clk) begin
        if (rst) begin
            lfsr <= 15'h1;
            out  <= 0;
        end else if (en) begin
            out  <= lfsr[1:0];
            lfsr <= {lfsr[13:0], lfsr[14] ^ lfsr[13]};
        end
    end
endmodule

/*
module prbs15_2bit (
    input clk,
    input rst,
    input en,
    output reg [1:0] out
);
    reg [1:0] lfsr;
    assign lsfr = out;

    always @(posedge clk) begin
    if (rst) begin
        lfsr <= 2'b00;
    end else if (en) begin
        lfsr <= lfsr + 1'b1;
    end
end
endmodule
*/