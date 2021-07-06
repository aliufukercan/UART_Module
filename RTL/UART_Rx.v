
/*
Author: Ali Ufuk Ercan
Description: This module receives the transmitted data and stores it in rx_data.
Version: 1.3
*/

module UART_Rx(

    input clk,
    input rst,
    input pulse_rx,
    input rx,
    output [7:0] rx_data,
    output reg rx_val
    );

parameter idle = 3'b000, start = 3'b001, receive_data = 3'b010, stop = 3'b011;
reg [2:0] state;

reg r_rx = 1'b1; // Will be used to store input rx

reg [2:0] bit_index = 0;
reg [7:0] r_rx_data = 0; // Will be used to store output rx_data 


always @(posedge clk)
begin

    if (rst == 1) begin
    
        state <= idle;
        rx_val <= 1'b0;
        bit_index <= 0;
        r_rx <= rx; // Store rx
    
    end else begin
        
        r_rx <= rx; // Store rx

        case (state)
        
        idle: begin
        
            rx_val <= 1'b0;
            bit_index <= 0;
               
            if (r_rx == 1'b0) begin // Start bit detected
                state <= start;
                rx_val <= 1'b1;
            end else
                state <= idle; 
            end 
        
        start: begin // Check middle of start bit to make sure it is still low
                
            if (pulse_rx == 1) begin
                if (r_rx == 1'b0)
                    state <= receive_data;
                else
                    state <= idle; 
                end
            end
               
        receive_data: begin
              
            rx_val <= 1'b1;
            if (pulse_rx == 1) begin
                r_rx_data[bit_index] <= r_rx;
                // Check if we have received all the bits
                if(bit_index < 7) begin
                    bit_index <= bit_index + 1;
                    state <= receive_data;
                end else begin
                    bit_index <= 0;
                    state <= stop;
                end 
            end
            end   
        
        stop: begin // Stop bit =1
               
            if (pulse_rx == 1) begin
                state <= idle;
                rx_val <= 1'b1;
            end
            end
        
        default: begin
               
            r_rx_data <= 8'b11111111; // To avoid errors
            rx_val <= 0;
            state <= idle;  
            end
                                        
        endcase
    end
end

assign rx_data = r_rx_data;
    
endmodule