`timescale 1ns / 1ps

module rampwaveform(
    input clk,
    input [4:0] IV,
    output reg [11:0] DAC_D
    );
    reg [16:0] counter;
    initial counter = 0;
    
    always@(posedge clk)
    begin
        counter <= counter + IV;
        DAC_D <= counter[16:5];
    end
endmodule
