 
/*
Author: Ali Ufuk Ercan
Description: Transmits data via given pulse_tx pulses. 
One bit of data is transmitted until the following pulse arrives. 
Version: 1.3
*/ 

module UART_Tx(

    input clk,
    input rst,
    input tx_val,
    input pulse_tx,
    input [7:0] tx_data,
    output reg tx,
    output reg busy
    );

parameter idle = 3'b000, start = 3'b001, transmit_data = 3'b010, stop = 3'b011, done = 3'b100;
reg [2:0] state;

reg [2:0] bit_index = 0;
reg [7:0] r_tx_data = 0; // Will be used to store tx_data in reg.


always @(posedge clk or posedge rst)
begin

    if (rst == 1) begin
        
        state <= idle;
        tx <= 1'b1;
        busy <= 0;
        bit_index <= 0;
    
    end else begin
       
        case (state)
        
        idle: begin
            
            tx <= 1'b1;
            busy <= 0;
            bit_index <= 0;
               
            if (tx_val == 1) begin
                r_tx_data <= tx_data;
                state <= start;
            end else
                state <= idle; 
            end 
        
        start: begin // Start bit = 0.
                
            busy <= 1;
            tx <= 1'b0;
            state <= transmit_data;
                 
            end
               
        transmit_data: begin
              
            if (pulse_tx == 1) begin
                tx <= r_tx_data[bit_index];
                // Check if we have sent all the bits.
                if(bit_index < 7) begin
                    bit_index <= bit_index + 1;
                    state <= transmit_data;
                end else begin
                    bit_index <= 0;
                    state <= stop;
                end 
            end
            end   
        
        stop: begin // Stop bit = 1.
            
            if (pulse_tx == 1) begin
                tx <= 1'b1;
                state <= done;
            end
            end
        
        done: begin // This state is included so that the stop bit can last for 8.68 usec.
               
            if (pulse_tx == 1) begin
                busy <= 1'b0;
                if (tx_val == 1) begin // Check if there is tx_val as soon as the transmit is done.
                    r_tx_data <= tx_data; // Store tx_data.
                    state <= start;
                end else
                    state <= idle; 
            end
            end
                                        
        endcase
    end    
end    

endmodule
