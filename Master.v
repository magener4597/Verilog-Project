`timescale 1ns / 1ps

module Master(
input clk,reset_Async,
input [11:0] DAC_D,
output SPI_MOSI,DAC_CS,SPI_SCK);

wire trans,go_DAC,reset_Async;
wire [27:0] DAC_in;

    DAC_Controller control(DAC_D,clk,trans,reset_Async,DAC_in,go_DAC);
    SPI_Interface interface(clk,go_DAC,DAC_in,reset_Async,trans,SPI_MOSI,DAC_CS,SPI_SCK);
endmodule


/*`timescale 1ns / 1ps

module Master(
input clk,
input [4:0] IV,
output SPI_MOSI,DAC_CS,SPI_SCK);

wire trans,go_DAC,reset_Async;
wire [11:0]DAC_D;
wire [27:0] DAC_in;

controllerDAC cDAC(clk,reset_Async,trans,DAC_D,go_DAC,DAC_in);
interfaceSPI iSPI(clk,reset_Async,go_DAC,DAC_in,trans,SPI_MOSI,DAC_CS,SPI_SCK);
rampwaveform wave(clk,IV,DAC_D);

endmodule*/