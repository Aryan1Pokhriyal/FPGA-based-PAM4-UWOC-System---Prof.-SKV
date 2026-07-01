`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.05.2026 12:59:19
// Design Name: 
// Module Name: text_rom
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


module text_rom (
    input clk,
    input [7:0] addr,
    output reg [7:0] data
);

    reg [7:0] mem [0:255];

    initial begin
        $readmemh("data.mem", mem);
    end

    //always @(posedge clk)
    //   data <= mem[addr];
    
    always @(*) begin
        data = mem[addr];
    end
    

endmodule
