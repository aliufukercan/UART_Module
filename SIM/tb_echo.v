`timescale 1ns / 1ps

/*
Author: Ali Ufuk Ercan
Description: With this testbench, we transmit a byte data to design's 
receiver and make it to send that data back to us.
Version: 1.3
*/

module tb_echo();

parameter clk_period_ns = 100;
reg clk_100MHz = 1; // Will be used in baudgen

reg clk = 1, rst = 0, tx_val = 0;
reg [7:0] tx_data;

wire pulse_tx, pulse_rx;
wire [7:0] rx_data;
wire tx,busy,rx_val;

reg tx_val1 = 0;
wire [7:0] rx_data1;
wire tx1,busy1;
wire rx_val1;

reg rx_val_temp = 0;
reg busy_temp = 0;

always #(clk_period_ns/2) clk = ~clk;
always #5 clk_100MHz = ~clk_100MHz; 

initial begin
tx_data = 8'b10101100;
end


baudgen u0 (.clk(clk),.rst(rst),.clk_100MHz(clk_100MHz),.busy(busy_temp),.rx_val(rx_val_temp),.pulse_tx(pulse_tx),.pulse_rx(pulse_rx));

UART_Tx u1 (.clk(clk),.pulse_tx(pulse_tx),.rst(rst),.tx_val(tx_val),.tx_data(tx_data),.tx(tx),.busy(busy));

UART_Rx u2 (.clk(clk),.pulse_rx(pulse_rx),.rst(rst),.rx(tx),.rx_val(rx_val),.rx_data(rx_data));

UART_Tx u3 (.clk(clk),.pulse_tx(pulse_tx),.rst(rst),.tx_val(tx_val1),.tx_data(rx_data),.tx(tx1),.busy(busy1));

UART_Rx u4 (.clk(clk),.pulse_rx(pulse_rx),.rst(rst),.rx(tx1),.rx_val(rx_val1),.rx_data(rx_data1));


always @(clk_100MHz)
begin 
    if (busy1) begin
        rx_val_temp <= rx_val1;
        busy_temp <= busy1;
    end else begin
        rx_val_temp = rx_val;
        busy_temp = busy;
    end
end         

// Main Testing
initial begin

#1;
rst=1;
#1;
rst=0;

repeat(130)
begin
@(posedge clk);
end

tx_val = 1'b1;
#(clk_period_ns);
tx_val = 1'b0;

@(negedge busy); // Wait for busy signal's falling edge to send tx_val1.
tx_val1 <= 1'b1;
#(clk_period_ns);
tx_val1 <= 1'b0;

end

initial begin
#200000;
$finish;
end

endmodule
