`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.05.2026 15:50:57
// Design Name: 
// Module Name: uart_tx
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

module uart_tx #(
    parameter CLK_FREQ  = 100000000,// follwoing same specs
    parameter BAUD_RATE = 9600
)(
    input  wire clk,
    input  wire rst_n,
    input  wire [7:0] data_in,
    input  wire tx_start,
    output reg tx_busy,
    output reg tx_out
);

    localparam integer BIT_DIV = CLK_FREQ / BAUD_RATE;  // this is numebr of clocks per bit, 10416

    localparam [1:0]
        S_IDLE  = 2'd0,
        S_START = 2'd1,
        S_DATA  = 2'd2,
        S_STOP  = 2'd3;

    reg [1:0] state;
    reg [$clog2(BIT_DIV)-1:0] bit_cnt;
    reg [2:0] bit_idx;    // 0 to 7 bit index
    reg [7:0] shift_reg;  //shift register

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_IDLE;
            bit_cnt   <= 0;
            bit_idx   <= 0;
            shift_reg <= 8'h00;
            tx_busy   <= 1'b0;
            tx_out    <= 1'b1;
        end else begin
            case (state)
                //idle state
                S_IDLE: begin
                    tx_out  <= 1'b1;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        shift_reg <= data_in;
                        bit_cnt   <= 0;
                        tx_busy   <= 1'b1;
                        state     <= S_START;
                    end
                end

                //start bit
                S_START: begin
                    tx_out <= 1'b0;
                    if (bit_cnt == BIT_DIV - 1) begin
                        bit_cnt <= 0;
                        bit_idx <= 0;
                        state   <= S_DATA;
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end

                //data bits
                S_DATA: begin
                    tx_out <= shift_reg[0];
                    if (bit_cnt == BIT_DIV - 1) begin
                        bit_cnt   <= 0;
                        shift_reg <= {1'b0, shift_reg[7:1]};
                        if (bit_idx == 3'd7) begin
                            state <= S_STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end

                //stop bit
                S_STOP: begin
                    tx_out <= 1'b1;
                    if (bit_cnt == BIT_DIV - 1) begin
                        bit_cnt <= 0;
                        tx_busy <= 1'b0;
                        state   <= S_IDLE;
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule

/// PAST VERSUONS //////////////////////////////////////////////////////////////////////////////////////////
/* GOOD UART
module uart_tx (
    input clk,
    input rst,
    input [7:0] data,
    input send,
    output reg tx
);

    parameter CLK_FREQ = 100_000_000;
    parameter BAUD = 9600;
    localparam BAUD_DIV = CLK_FREQ / BAUD; // ~10416

    reg [15:0] baud_cnt;

    always @(posedge clk) begin
        if (rst)
            baud_cnt <= 0;
        else if (baud_cnt == BAUD_DIV - 1)
            baud_cnt <= 0;
        else
            baud_cnt <= baud_cnt + 1;
    end

    wire baud_tick = (baud_cnt == BAUD_DIV - 1);

    reg [3:0] bit_cnt;
    reg [9:0] shift = 10'b1111111111;
    reg busy;

    always @(posedge clk) begin
        if (rst) begin
            tx      <= 1;
            busy    <= 0;
            bit_cnt <= 0;
            shift <= 10'b1111111111;
        end else begin
            if (send && !busy) begin
                shift   <= {1'b1, data, 1'b0}; // stop + data + start
                busy    <= 1;
                bit_cnt <= 0;
            end else if (busy && baud_tick) begin
                tx      <= shift[0];
                shift <= {1'b1, shift[9:1]};
                bit_cnt <= bit_cnt + 1;

                if (bit_cnt == 9)
                    busy <= 0;
            end
        end
    end

endmodule

*/

/*  working s012
module uart_tx (
    input clk,
    input rst,
    input [7:0] data,
    input send,
    output reg tx
);
    parameter BAUD_DIV = 10416;
    reg [15:0] baud_cnt;
    always @(posedge clk) begin
        if (rst)
            baud_cnt <= 0;
        else if (baud_cnt == BAUD_DIV - 1)
            baud_cnt <= 0;
        else
            baud_cnt <= baud_cnt + 1;
    end
    wire baud_tick = (baud_cnt == 0);

    reg [3:0] bit_cnt;
    reg [9:0] shift;
    reg busy;
    always @(posedge clk) begin
        if (rst) begin
            tx      <= 1;
            busy    <= 0;
            bit_cnt <= 0;
        end else begin
            if (send && !busy) begin
                shift   <= {1'b1, data, 1'b0}; // stop + data + start
                busy    <= 1;
                bit_cnt <= 0;
            end
            if (busy && baud_tick) begin
                tx      <= shift[0];
                shift   <= shift >> 1;
                bit_cnt <= bit_cnt + 1;
                if (bit_cnt == 9)
                    busy <= 0;
            end
        end
    end
endmodule
*/
