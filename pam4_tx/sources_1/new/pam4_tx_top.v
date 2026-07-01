`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.04.2026 16:02:13
// Design Name: 
// Module Name: pam4_tx_top
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

module pam4_tx_top #(
    parameter CLK_FREQ   = 100000000,
    parameter SYM_RATE   = 2400, // for 9600 baud rate, we have 4 symbols per baud, so 2400      
    parameter NUM_BYTES  = 4,   // 4 bytes of data - NEEDS TO BE CHANGED
    parameter ADDR_WIDTH = 2    // fixed        
)(
    input  wire clk,    
    input  wire rst_n,  // active-low reset 
    output reg  tx0, // JA1 line LSB
    output reg  tx1  // JA2 line MSB
);

    // symbol rate divider  (sym_tick is one-cycle pulse every 1/sym rate seconds)
    localparam integer SYM_DIV = CLK_FREQ / SYM_RATE;  // this is 41666

    reg [$clog2(SYM_DIV)-1:0] sym_cnt;     // teack of symbol
    reg sym_tick;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sym_cnt  <= 0;
            sym_tick <= 1'b0;
        end else if (sym_cnt == SYM_DIV - 1) begin
            sym_cnt  <= 0;
            sym_tick <= 1'b1;
        end else begin
            sym_cnt  <= sym_cnt + 1;
            sym_tick <= 1'b0;
        end
    end

    // we are using luts across the fpga as rom, to store the data
    (* rom_style = "distributed" *)
    reg [7:0] mem [0:NUM_BYTES-1];
    initial $readmemh("data.mem", mem);

    // byte addtress goes from 0 to number of bytes - 1
    reg [ADDR_WIDTH-1:0] byte_addr;
    
    // symbol index goes from 0 to 3
    reg [1:0] sym_idx;     // for 8 bits, using pam 4, we have to transmit 4 times

    
    wire [1:0] raw_sym;
    wire [1:0] gray_sym;

    // selecting requied 2-bit slice from the current byte
    assign raw_sym = (sym_idx == 2'd0) ? mem[byte_addr][7:6] :
                     (sym_idx == 2'd1) ? mem[byte_addr][5:4] :
                     (sym_idx == 2'd2) ? mem[byte_addr][3:2] :
                                         mem[byte_addr][1:0];

    // gray code
    assign gray_sym[1] = raw_sym[1];
    assign gray_sym[0] = raw_sym[1] ^ raw_sym[0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            byte_addr <= 0;
            sym_idx   <= 0;
            tx0       <= 1'b0;
            tx1       <= 1'b0;
        end else if (sym_tick) begin
            // drive the outputs onto the lines
            tx0 <= gray_sym[0];
            tx1 <= gray_sym[1];

            // increment the counters
            if (sym_idx == 2'd3) begin
                sym_idx   <= 0;
                byte_addr <= (byte_addr == NUM_BYTES - 1) ? {ADDR_WIDTH{1'b0}} : byte_addr + 1;
            end else begin
                sym_idx <= sym_idx + 1;
            end
        end
    end

endmodule











// PAST VERSIONS ///////////////////////////////////////////////

/* ADJUSTABBLE CLOCKIGG 
module pam4_tx_top (
    input clk,
    input rst,
    output led0,
    output tx_lane0,
    output tx_lane1,
    output led1
);

    // adjustable clocking
    reg [27:0] div;
    reg div_d;
    wire symbol_ce;

    always @(posedge clk) begin
        if (rst) begin
            div   <= 0;
            div_d <= 0;
        end else begin
            div   <= div + 1;
            div_d <= div[14];
        end
    end
    assign symbol_ce = div[14] & ~div_d;

    // DATA Source
    wire [1:0] bits;

    text_source u_txt (
        .clk(clk),
        .rst(rst),
        .en(symbol_ce),
        .bits(bits)
    );

    // gray encoder
    wire [1:0] sym_gray;

    gray_encoder u_gray (
        .in(bits),
        .out(sym_gray)
    );

    // registering the symbol
    reg [1:0] sym;

    always @(posedge clk) begin
        if (rst)
            sym <= 2'b00;
        else if (symbol_ce)
            sym <= sym_gray;
    end

    // Output the final bits onto the LEDs and the Transmitter lines
    assign led0 = sym[0];
    assign led1 = sym[1];
    assign tx_lane0 = sym[0];
    assign tx_lane1 = sym[1];

endmodule
*/



/* PBRS STUFF - VERY OLD SHIT
module pam4_tx_top (
    input clk,
    input rst,
    input [3:0] delay_sel,
    output tx_lane0,
    output tx_lane1,
    output led0, 
    output led1
);

    // Clock divider
    reg [27:0] div;
    reg div_d;
    wire symbol_ce;

    always @(posedge clk) begin
        if (rst) begin
            div   <= 0;
            div_d <= 0;
        end else begin
            div   <= div + 1;
            div_d <= div[25];
        end
    end
    assign symbol_ce = div[26] & ~div_d;

    // PRBS
    wire [1:0] bits;
    prbs15_2bit u1 (
        .clk(clk),
        .rst(rst),
        .en(symbol_ce),
        .out(bits)
    );

    // Gray encoder
    wire [1:0] sym_comb;
    gray_encoder u2 (
        .in(bits),
        .out(sym_comb)
    );

    reg [1:0] sym;
    always @(posedge clk) begin
        if (rst)
            sym <= 0;
        else if (symbol_ce)
            sym <= sym_comb;
    end

    wire delayed_msb;
    delay_block u3 (
        .clk(clk),
        .rst(rst),
        .en(symbol_ce),
        .sel(delay_sel),
        .din(sym[1]),
        .dout(delayed_msb)
    );

    reg tx0_r, tx1_r;

    always @(posedge clk) begin
        if (rst) begin
            tx0_r <= 0;
            tx1_r <= 0;
        end else if (symbol_ce) begin
            tx0_r <= sym[0];
            tx1_r <= delayed_msb;
        end
    end

    assign tx_lane0 = tx0_r;
    assign tx_lane1 = tx1_r;

    assign led0 = tx0_r;
    assign led1 = tx1_r;

endmodule
*/