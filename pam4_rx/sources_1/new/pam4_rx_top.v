`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.04.2026 16:48:05
// Design Name: 
// Module Name: pam4_rx_top
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

module pam4_rx_top #(
    parameter CLK_FREQ  = 100000000,
    parameter SYM_RATE  = 2400,         // also done in Tx
    parameter BAUD_RATE = 9600
)(
    input  wire clk,        // 100 MHz clk
    input  wire rst_n,      // active low reset
    input  wire rx0,        // JA1
    input  wire rx1,        // JA2
    output wire uart_txd    // JA3 - uart serial output
);

    localparam integer SYM_DIV  = CLK_FREQ / SYM_RATE;   // this is 41666
    localparam integer HALF_DIV = SYM_DIV / 2;            // this is 20833

    // two stage sync to not have maetastabiltiy
    reg [1:0] sync0_r; 
    reg [1:0] sync1_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync0_r <= 2'b00;
            sync1_r <= 2'b00;
        end else begin
            sync0_r <= {sync0_r[0], rx0};
            sync1_r <= {sync1_r[0], rx1};
        end
    end
    
    // synced lines
    wire rx0_s = sync0_r[1];
    wire rx1_s = sync1_r[1]; 

    
    reg rx0_d, rx1_d;   // previous values

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx0_d <= 1'b0;
            rx1_d <= 1'b0;
        end else begin
            rx0_d <= rx0_s;
            rx1_d <= rx1_s;
        end
    end

    wire edge_det = (rx0_s ^ rx0_d) | (rx1_s ^ rx1_d);

    // this is symbol divider with mid level sampling
    reg [$clog2(SYM_DIV)-1:0] sym_cnt;
    reg sample_tick;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sym_cnt     <= 0;
            sample_tick <= 1'b0;
        end else begin
            sample_tick <= 1'b0;

            if (edge_det) begin
                // reset countere
                sym_cnt <= 1;
            end else if (sym_cnt == SYM_DIV - 1) begin
                sym_cnt <= 0;
            end else begin
                sym_cnt <= sym_cnt + 1;
                if (sym_cnt == HALF_DIV - 1)
                    sample_tick <= 1'b1;
            end
        end
    end

    // gray decoder module called
    wire [1:0] gray_in = {rx1_s, rx0_s};
    wire [1:0] bin_sym;

    gray_decoder u_gray_dec (
        .gray (gray_in),
        .bin  (bin_sym)
    );

    // now this is the byte assembler
    reg [1:0] sym_cnt_rx;   //0, 1 2, 3
    reg [7:0] acc;          //accumulator
    reg [7:0] byte_data;    //complete byte
    reg       byte_valid;   //1  pulse when byte_data is ready

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sym_cnt_rx <= 0;
            acc        <= 8'h00;
            byte_data  <= 8'h00;
            byte_valid <= 1'b0;
        end else begin
            byte_valid <= 1'b0;

            if (sample_tick) begin
                if (sym_cnt_rx == 2'd3) begin
                    byte_data  <= {acc[5:0], bin_sym};
                    byte_valid <= 1'b1;
                    sym_cnt_rx <= 0;
                    acc        <= 8'h00;
                end else begin
                    //shift
                    acc        <= {acc[5:0], bin_sym};
                    sym_cnt_rx <= sym_cnt_rx + 1;
                end
            end
        end
    end

    // Uart transmitter
    wire uart_busy;

    uart_tx #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) u_uart_tx (
        .clk      (clk),
        .rst_n    (rst_n),
        .data_in  (byte_data),
        .tx_start (byte_valid & ~uart_busy),
        .tx_busy  (uart_busy),
        .tx_out   (uart_txd)
    );

endmodule






// PAST VERSIONS ///////////////////////////////////////////////////////////////////////

/* working kind of
module pam4_rx_top (
    input  CLK100MHZ,
    input  [2:0] sw,      // sw[0]=rst, sw[1]=rx0, sw[2]=rx1
    output tx,
    output [1:0] LED
);

    wire rst = sw[0];
    wire rx0 = sw[1];
    wire rx1 = sw[2];

    // =============================
    // INPUT SYNCHRONIZER (CRITICAL)
    // =============================
    reg rx0_d1, rx0_d2;
    reg rx1_d1, rx1_d2;

    always @(posedge CLK100MHZ) begin
        rx0_d1 <= rx0;
        rx0_d2 <= rx0_d1;

        rx1_d1 <= rx1;
        rx1_d2 <= rx1_d1;
    end

    wire rx0_sync = rx0_d2;
    wire rx1_sync = rx1_d2;

    // =============================
    // SYMBOL CLOCK (MATCH TX)
    // =============================
    reg [14:0] div;
    wire symbol_ce;

    always @(posedge CLK100MHZ) begin
        if (rst)
            div <= 0;
        else if (div == 26040)
            div <= 0;
        else
            div <= div + 1;
    end

    assign symbol_ce = (div == 0);

    // =============================
    // GRAY DECODING
    // =============================
    wire [1:0] gray_sym = {rx1_sync, rx0_sync};
    wire [1:0] bin_sym;

    gray_decoder u_dec (
        .in(gray_sym),
        .out(bin_sym)
    );

    assign LED = bin_sym;

    // =============================
    // BYTE ASSEMBLY
    // =============================
    reg [1:0] sym_cnt;
    reg [7:0] byte_reg;
    reg byte_ready;

    always @(posedge CLK100MHZ) begin
        if (rst) begin
            sym_cnt <= 0;
            byte_reg <= 0;
            byte_ready <= 0;
        end else begin
            byte_ready <= 0; // default

            if (symbol_ce) begin
                case (sym_cnt)
                    2'd0: byte_reg[1:0] <= bin_sym;
                    2'd1: byte_reg[3:2] <= bin_sym;
                    2'd2: byte_reg[5:4] <= bin_sym;
                    2'd3: byte_reg[7:6] <= bin_sym;
                endcase

                if (sym_cnt == 3)
                    byte_ready <= 1;

                sym_cnt <= sym_cnt + 1;
            end
        end
    end

    // =============================
    // UART TRANSMITTER
    // =============================
    uart_tx u_uart (
        .clk(CLK100MHZ),
        .rst(rst),
        .data(byte_reg),
        .send(byte_ready),
        .tx(tx)
    );

endmodule
*/