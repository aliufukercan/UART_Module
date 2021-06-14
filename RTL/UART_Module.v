`timescale 1ns / 1ps

module UART_Module(

    input clk, clk_100MHz, rst, tx_val, rx,
    input [7:0] tx_data,
    output tx, rx_val, busy,
    output [7:0] rx_data
    );
    
wire pulse_tx, pulse_rx;

baudgen u1 (.clk(clk),.clk_100MHz(clk_100MHz),.rst(rst),.busy(busy),.rx_val(rx_val),.pulse_tx(pulse_tx),.pulse_rx(pulse_rx));

UART_Tx u2 (.clk(clk),.pulse_tx(pulse_tx),.rst(rst),.tx_val(tx_val),.tx_data(tx_data),.tx(tx),.busy(busy));

UART_Rx u3 (.clk(clk),.pulse_rx(pulse_rx),.rst(rst),.rx(rx),.rx_val(rx_val),.rx_data(rx_data));

endmodule
