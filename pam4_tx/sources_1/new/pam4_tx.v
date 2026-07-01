`timescale 1ns / 1ps

module pam4_tx (
    input  wire clk,              // 100 MHz clock
    input  wire rst,              // active high reset
    input  wire [3:0] delay_sel,  // coarse delay control

    output wire tx_lane0,         // LSB
    output wire tx_lane1          // MSB
);

    // CLOCK DIVIDER
    
    // ability to slow down the clock by factor of 2^24
    reg [23:0] clk_div = 0;
    wire symbol_ce;

    always @(posedge clk) begin
        if (rst)
            clk_div <= 0;
        else
            clk_div <= clk_div + 1;
    end

    // currently slowing it down by 2^20
    assign symbol_ce = clk_div[20];


    // 2 BIT PBRS GENERATOR
    reg [14:0] lfsr = 15'h1;    // defining a linear feedback shift reg
    reg [1:0]  data_bits;

    always @(posedge clk) begin
        if (rst) begin
            lfsr      <= 15'h1;
            data_bits <= 2'b00;
        end else if (symbol_ce) begin
            data_bits <= lfsr[1:0];
            lfsr      <= {lfsr[13:0], lfsr[14] ^ lfsr[13]};
        end
    end


    // GRAY CODING
    reg [1:0] gray_sym;

    always @(*) begin
        case (data_bits)
            2'b00: gray_sym = 2'd0;
            2'b01: gray_sym = 2'd1;
            2'b11: gray_sym = 2'd2;
            2'b10: gray_sym = 2'd3;
            default: gray_sym = 2'd0;
        endcase
    end


    // spliting the data into two OOK lanes
    wire lane0_raw = gray_sym[0];  // LSB
    wire lane1_raw = gray_sym[1];  // MSB


    // coarse delay control -   USELESS BLOCK 
    reg [15:0] delay_line = 0;

    always @(posedge clk) begin
        if (rst)
            delay_line <= 0;
        else if (symbol_ce)
            delay_line <= {delay_line[14:0], lane1_raw};
    end

    assign tx_lane0 = lane0_raw;
    assign tx_lane1 = delay_line[delay_sel];


endmodule