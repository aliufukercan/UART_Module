
/*
Author: Ali Ufuk Ercan
Description: This module creates pulses for UART_Tx and UART_Rx modules.
It's high state and low state lengths can be adjusted with the parameters.
Version: 1.3
*/

module baudgen(
    input clk,
    input rst,
    input clk_100MHz,
    input busy,
    input rx_val,
    output reg pulse_tx,
    output reg pulse_rx
    );

reg stay_tx = 0, stay_rx= 0, pulse_rx_half = 1;
integer counter_tx = 1, counter_rx = 1;

parameter pulse_high_width = 10; // To match the 100 ns period of 10 MHz clock.
parameter pulse_length = 868; // To match the 8.68 usec period of 115200 baudrate.

reg busy_samp;
reg rx_val_samp;

wire busy_posedge;
wire rx_val_posedge;

assign busy_posedge = busy && !busy_samp;
assign rx_val_posedge = rx_val && !rx_val_samp;


always @(posedge clk_100MHz or rst)
begin
  
    if (rst==1) begin
       
        counter_tx <= 1;
        pulse_tx <= 1'b0;
        
        counter_rx <= 1;
        pulse_rx <= 1'b0;
        pulse_rx_half <= 1;
        stay_tx <= 0;
        stay_rx <= 0;
    
    end else begin
        
        busy_samp <= busy;
        rx_val_samp <= rx_val;
        
        // Reset baudgen pulse_tx every busy rising edge
        if (busy_posedge) begin
            counter_tx <= 1;
            pulse_tx <= 1'b0;
            stay_tx <= 0;
        end
                
        // Reset baudgen pulse_rx every rx_val rising edge
        if (rx_val_posedge) begin
            counter_rx <= 1;
            pulse_rx <= 1'b0;
            pulse_rx_half <= 1;
            stay_rx <= 0;
        end
        
        //For pulse_tx.
        if (busy) begin  // To create pulses only when it is busy.
            if (stay_tx == 1) begin // High state.
                if (counter_tx == pulse_high_width) begin
                    pulse_tx <= ~pulse_tx;
                    stay_tx <= 0;
                end
                counter_tx <= counter_tx + 1;
            end else begin
                counter_tx <= counter_tx + 1;
                if (counter_tx == pulse_length) begin
                    pulse_tx <= ~pulse_tx;
                    stay_tx <= 1;
                    counter_tx <= 1;
                end
            end 
        end else
            pulse_tx <= 1'b0; 
        
        //For pulse_rx.
        if (rx_val) begin // To create pulses only when it is rx_val.
            if (pulse_rx_half == 1) begin
                counter_rx <= counter_rx + 1;
                if (counter_rx == pulse_length/2)begin
                    pulse_rx <= ~pulse_rx;
                    pulse_rx_half <= 0;
                    stay_rx <= 1;
                    counter_rx <= 1;
                end
            end else if (stay_rx == 1) begin // High state.
                if (counter_rx == pulse_high_width) begin
                    pulse_rx <= ~pulse_rx;
                    stay_rx <= 0;
                end
                counter_rx <= counter_rx + 1;
            end else begin
                counter_rx <= counter_rx + 1;
                if (counter_rx == pulse_length) begin
                    pulse_rx <= ~pulse_rx;
                    stay_rx <= 1;
                    counter_rx <= 1;
                end
            end 
        end else
            pulse_rx <= 1'b0;
        
    end     
end

endmodule