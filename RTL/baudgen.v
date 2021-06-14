
// This module creates pulses for UART_Tx and UART_Rx modules.
// It's high state and low state lengths can be adjusted with the parameters.

module baudgen(
    input clk,rst,clk_100MHz,
    input busy,rx_val,
    output reg pulse_tx,
    output reg pulse_rx
    );

reg stay_tx = 0, stay_rx= 0, pulse_rx_half = 1;
integer counter_tx = 1, counter_rx = 1;

parameter pulse_high_width = 10; // To match the 100 ns period of 10 MHz clock.
parameter pulse_length = 868; // To match the 8.68 usec period of 115200 baudrate.

// Reset baudgen pulse_tx every busy rising edge
always @(posedge busy)
begin 
   counter_tx <= 1;
   pulse_tx <= 1'b0;
   stay_tx <= 0;
end 

// Reset baudgen pulse_rx every rx_val rising edge
always @(posedge rx_val)
begin 
   counter_rx <= 1;
   pulse_rx <= 1'b0;

   pulse_rx_half <= 1;
   stay_rx <= 0;
end 

always @(posedge rst)
begin 
 if (rst==1)
  begin
   counter_tx <= 1;
   pulse_tx <= 1'b0;
   
   counter_rx <= 1;
   pulse_rx <= 1'b0;
   pulse_rx_half <= 1;
   stay_tx <= 0;
   stay_rx <= 0;
  end
end  
  
//For pulse_tx.
always @(posedge clk_100MHz)
begin
  if (busy) // To create pulses only when it is busy.
    begin 
     if (stay_tx == 1) // High state.
      begin
       if (counter_tx == pulse_high_width)
        begin
         pulse_tx <= ~pulse_tx;
         stay_tx <= 0;
        end
        counter_tx <= counter_tx + 1;
      end 
     else begin
      counter_tx <= counter_tx + 1;
      if (counter_tx == pulse_length)
       begin
        pulse_tx <= ~pulse_tx;
        stay_tx <= 1;
        counter_tx <= 1;
       end
     end 
    end
  else
    pulse_tx <= 1'b0;  
end

//For pulse_rx.
always @(posedge clk_100MHz)
begin
  if (rx_val) // To create pulses only when it is rx_val.
   begin   
     if (pulse_rx_half == 1)
      begin
       counter_rx <= counter_rx + 1;
       if (counter_rx == pulse_length/2)
        begin
         pulse_rx <= ~pulse_rx;
         pulse_rx_half <= 0;
         stay_rx <= 1;
         counter_rx <= 1;
        end
       end   
     else if (stay_rx == 1) // High state.
      begin
       if (counter_rx == pulse_high_width)
        begin
         pulse_rx <= ~pulse_rx;
         stay_rx <= 0;
        end
        counter_rx <= counter_rx + 1;
      end 
     else 
      begin
       counter_rx <= counter_rx + 1;
       if (counter_rx == pulse_length)
        begin
         pulse_rx <= ~pulse_rx;
         stay_rx <= 1;
         counter_rx <= 1;
        end
      end 
    end
  else
    pulse_rx <= 1'b0;  
end 

endmodule





