# Verilog-Project

The Serial Peripheral Interface (SPI) bus is a bus that configures the relationship between master and slave devices.
One master can control multiple slaves. I used the FPGA as a master and the Digital to Analog Converter (DAC) as the slave. 
The DAC converts binary numbers into a voltage. The SPI interface is a counter, register, and two JK flip flops.
These are designed to help the SPI bus work properly. As the program goes through the states the SPI bus is written. 
The DAC controller is made up of a multiplexer and a JK flip flop. It takes the input, then converts it to a value the SPI can take as an input. 
Based on the states it knows to transmit the data after the command and address bits have been written.
