# UART Module

## Overview
This module sends and receives 8 bits of data with one start and one stop bit (no parity bit) with a selected baudrate. It consists of 3 sub modules. There are two testbenches for testing the design.
</br></br>
## 1. Sub Modules
----

Module Name | Explanation | Input Ports |Output Ports
--- | --- | --- | ---
baudgen | Sets the baudrate | clk_100MHz, rst | pulse_tx, pulse_rx
UART_Tx | Transmits given data|clk, rst, tx_val, pulse_tx, tx_data (7:0)| tx, busy
UART_Rx | Receives and stores data | clk, rst, pulse_rx, rx| rx_data (7:0), rx_val
</br>

## 1.1 baudgen
**baudgen** module is used for generating pulses which will be used in **UART_Tx** and **UART_Rx** modules. In our testbench we are using a 10 MHz clock (100 ns period) and from 115200 baudrate, our bits will have 8.68 usec period. From 10 MHz / 115200 Hz, we get 87. That means if we pass 87 clock cycles of 10 Mhz clock, that will be equal to 8.7 usec period. To improve the accuracy, we will be using a 100 MHz clock for only **baudgen** module, that way we will be able to pass 868 cyles of 100 MHz clock and that will be equal to 8.68 usec. 

For transmitting the datas, we will create a pulse signal (**pulse_tx**) that is low for 8.58 us and high for 100 ns (total 8.68 usec). On the receiver side, we will also create a pulse signal (**pulse_rx**) with the same lengths but to be able to sample the received data safely, we will arrange it to be high for 100ns at the middle of the low states of transmit pulses.
</br></br>
## 1.2 UART_Tx
This module uses 5 states to transmit an 8 bit data with start and stop bits.
In **idle** state, in every rising edge of 10 MHz clock, it checks if a **tx_val** signal exists which is a signal to initiate data transmit given by the testbench.
If there is a **tx_val** signal in any rising edge clock, the **baudgen** is reset and at the next clock edge, the state becomes **start**. 
From this point to the **done** state, in order to begin executing the next state, the module will wait for the **pulse_tx** signal. 

**Busy** signal will be high from the **start** state to the end of the **stop** state, so that we can observe and know when the **UART_Tx** is busy. In state **transmit_data**, we will begin transmitting our data. After sending 8 bits of data, the **stop** state will begin and the module will send high signal from its **tx** port until the next **pulse_tx**. 

The final transmission state is **done**, which makes the **busy** signal low and checks the **tx_val** signal in case of a tx valid signal exists. If there is not, on the next rising edge of the clock, the **idle** state begins.
</br></br>
## 1.3 UART_Rx
In this module there are 4 states to receive the transmitted data. In **idle** state, the module waits for a low signal in its **rx** input port.
If it arrives, **start** state begins and on the the next **pulse_rx**, it checks the received data to make sure it is still low. If it is, on the following **pulse_rx** pulses, the module
receives the arriving data through its **rx** port and writes it on register **rx_data** in state **receive_data** . On the last state **stop**, it makes the state **idle** for the next rising edge clock. **rx_val** signal becomes high between states **start** and **stop**.
</br></br>
## 2. Testbenches
---
</br>

## 2.1 tb_echo
This testbench tests our design by sending its receiver an 8 bit data and makes it to send that data back. To start sending the received data (**rx_data**) back to the testbenches receiver, first the falling edge of the testbench's transmitter busy signal is checked to initiate transmission by **tx_val1** signal. Then the **rx_data** is succesfully transmitted an stored in testbench's receiver register **rx_data1**.

</br>

![](https://github.com/aliufukercan/UART_Module/blob/master/SIM/tb_echo.PNG?raw=true)
## 2.2 tb_UART_Array

In this testbench, we use our design to send an array of 13 element data. We check the falling edge of the busy signal to transmit the next data byte. As seen in the below image, the **UART_Tx** module transmits each data byte continuously and the **UART_Rx** module samples the transmitted datas and store them in registers **rx_data** and **received_data**.
</br></br>

![](https://github.com/aliufukercan/UART_Module/blob/master/SIM/tb_Array.PNG?raw=true)

