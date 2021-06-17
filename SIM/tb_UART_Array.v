`timescale 1ns / 1ps

// With this testbench, we send an array of data to design's
// receiver from design's transmitter.

module tb_UART_Array();

parameter clk_period_ns = 100;
reg clk_100MHz = 1; // Will be used in baudgen

reg clk = 1, rst = 0, tx_val = 0;
reg [7:0] tx_data [0:12];

wire pulse_tx, pulse_rx;
wire [7:0] rx_data;
wire tx,busy,rx_val;

reg [7:0] data;
reg [3:0] n=0;
reg [3:0] n1=0;
reg [7:0] received_data [0:12];

always #(clk_period_ns/2) clk = ~clk;
always #5 clk_100MHz = ~clk_100MHz;

initial begin
    tx_data[12] = 8'h6d;//m
    tx_data[11] = 8'h69;//i
    tx_data[10] = 8'h72;//r
    tx_data[9] = 8'h61;//a
    tx_data[8] = 8'h73;//s
    tx_data[7] = 8'h61;//a
    tx_data[6] = 8'h54;//T
    tx_data[5] = 8'h2d;//-
    tx_data[4] = 8'h6f;//o
    tx_data[3] = 8'h72;//r
    tx_data[2] = 8'h6b;//k
    tx_data[1] = 8'h69;//i
    tx_data[0] = 8'h4d;//M

    data = 8'b11111111;
end

baudgen u0 (.clk(clk),.clk_100MHz(clk_100MHz),.rst(rst),.busy(busy),.rx_val(rx_val),.pulse_tx(pulse_tx),.pulse_rx(pulse_rx));

UART_Tx u1 (.clk(clk),.pulse_tx(pulse_tx),.rst(rst),.tx_val(tx_val),.tx_data(data),.tx(tx),.busy(busy));

UART_Rx u2 (.clk(clk),.pulse_rx(pulse_rx),.rst(rst),.rx(tx),.rx_val(rx_val),.rx_data(rx_data));


// Send the new byte in the following tx_val.
 
always @(posedge tx_val)
begin
  if (tx_val==1)
   begin
     data <= tx_data[n]; 
     n <= n+1; 
   end
end

// Store the received bytes in received_data to display better in the simulation.

always @(negedge busy)
begin
  received_data[n1-1] <= rx_data; // After rst, busy has a falling edge, to prevent counting that we write [n1-1].
  n1 <= n1+1;
end


// Main Testing
initial begin

@(posedge clk);
rst=1;
#(clk_period_ns);
rst=0;

repeat(500)
begin
@(posedge clk);
end

tx_val <= 1'b1;
#(clk_period_ns);
tx_val <= 1'b0;


repeat(12)
begin
    @(negedge busy); // Wait for busy signal's falling edge to send tx_val.
    tx_val <= 1'b1;
    #(clk_period_ns);
    tx_val <= 1'b0;
end
end

initial begin
#1250000;
$finish;
end

endmodule
