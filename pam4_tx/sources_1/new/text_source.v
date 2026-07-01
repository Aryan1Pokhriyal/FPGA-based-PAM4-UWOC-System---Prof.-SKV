`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.05.2026 12:58:27
// Design Name: 
// Module Name: text_source
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
module text_source (
    input clk,
    input rst,
    input en,
    output reg [1:0] bits
);

    reg [7:0] addr;
    wire [7:0] rom_data;
    reg [7:0] byte_reg;

    reg [1:0] cnt;
    
    
    // extracting the data from ROM
    text_rom rom (
        .clk(clk),
        .addr(addr),
        .data(rom_data)
    );

    always @(posedge clk) begin
        if (rst) begin
            addr <= 0;
            cnt <= 0;
            byte_reg <= 0;
            bits <= 0;
        end else if (en) begin

            // load bytes at edge
            if (cnt == 0)
                byte_reg <= rom_data;

            case (cnt)
                2'd0: bits <= byte_reg[7:6];
                2'd1: bits <= byte_reg[5:4];
                2'd2: bits <= byte_reg[3:2];
                2'd3: bits <= byte_reg[1:0];
            endcase

            cnt <= cnt + 1;

            if (cnt == 3)
                addr <= addr + 1;
        end
    end

endmodule

