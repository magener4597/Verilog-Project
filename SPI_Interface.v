`timescale 1ns / 1ps

module SPI_Interface(
    input clk,
    input go_DAC,
    input [27:0] DAC_in,
    input reset_Async,
    output reg trans,
    output reg SPI_MOSI,
    output reg DAC_CS,
    output reg SPI_SCK
    );
    reg C0,C1,C2,C3,C4;
    wire Z;
    reg [4:0] count;
    reg [31:0] register;
    reg [2:0] state_reg, state_next;
    localparam [2:0] S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;
    
    //5-bit counter
    always@(posedge clk)
    begin
        if(C2)
            count <= 31;
        else if(C4)
            count <= count - 1;
    end
    
    assign Z = (count == 0);
    
    //JK 1
    always@(posedge clk)
    begin
        case({C0,C1})
            2'b11: SPI_SCK <= ~ SPI_SCK;
            2'b01: SPI_SCK <= 0;
            2'b10: SPI_SCK <= 1;
            2'b00: SPI_SCK <= SPI_SCK;
        endcase
    end
    
    //JK 2
    always@(posedge clk)
    begin
        case({C2,C3})
            2'b11: trans <= ~ trans;
            2'b01: trans <= 0;
            2'b10: trans <= 1;
            2'b00: trans <= trans;
        endcase
    end
    
    always@(trans)
    DAC_CS = ~trans;
    
    //32-bit register
    always@(posedge clk)
    begin
        if(C2)
            register <= {4'b0,DAC_in};
        else if(C4)
            register <= register << 1;
    end
    
    always@(register)
    SPI_MOSI = register[31];
    
    //FSM
    always@(posedge clk)
    begin
        state_reg <= state_next;
    end
    
    always@*
    begin
        state_next = state_reg;
        if(reset_Async)
        begin
            C4 = 0; C3 = 0; C2 = 0; C1 = 0; C0 = 0;
            state_next = S0;
        end
        case(state_reg)
            S0:
            begin
                if(go_DAC)
                begin
                    C4 = 0; C3 = 0; C2 = 1; C1 = 1; C0 = 0;
                    state_next = S1;
                end
                else
                begin
                    C4 = 0; C3 = 0; C2 = 0; C1 = 1; C0 = 0;
                    state_next = S0;
                end
            end
            S1:
            begin
                C4 = 0; C3 = 0; C2 = 0; C1 = 0; C0 = 1;
                state_next = S2;
            end
            S2:
            begin
                if(Z)
                begin
                    C4 = 0; C3 = 0; C2 = 0; C1 = 1; C0 = 0;
                    state_next = S4;
                end
                else
                begin
                    C4 = 0; C3 = 0; C2 = 0; C1 = 1; C0 = 0;
                    state_next = S3;
                end
            end
            S3:
            begin
                C4 = 1; C3 = 0; C2 = 0; C1 = 0; C0 = 1;
                state_next = S2;
            end
            S4:
            begin
                C4 = 0; C3 = 1; C2 = 0; C1 = 1; C0 = 0;
                state_next = S0;
            end
            default:
            begin
                C4 = 0; C3 = 0; C2 = 0; C1 = 0; C0 = 0;
                state_next = S0;
            end
        endcase
    end
    
endmodule


/*`timescale 1ns / 1ps

module interfaceSPI(

input clk,

reset_Async,

go_DAC,

input [27:0] DAC_in,

output transmitting,

SPI_MOSI,

DAC_CS,

SPI_SCK

);

wire z;

reg [4:0] bitCount;

// 5 bit counter =================================

always @(posedge clk)

begin

if(c[2])

bitCount<=5'b11111;

else if (c[4])

bitCount<=bitCount-1;

end // end 5 bit counter

assign z=(!bitCount);

localparam [2:0] s0=0, s1=1, s2=2, s3=3, s4=4;

reg [5:0] c;

reg [2:0] presState=s0;

// state machine =================================

always @(posedge clk)

begin

if(reset_Async)

begin

presState<=s0;

c<=3'b000;

end // end IF reset_Async

else

case(presState)

s0:

begin

if(go_DAC)

begin

presState<=s1;

c<=5'b00110;

end // end IF go_DAC

else

begin

c<='b00010;

end // end ELSE go_DAC

end // end STATE 0

s1:

begin

presState<=s2;

c<=5'b00001;

end // end STATE 1

s2:

begin

c<=5'b00010;

if(z)

presState<=s4; // end IF z

else

presState<=s3; // end ELSE z

end // end STATE 2

s3:

begin

presState<=s2;

c<=5'b10001;

end // end STATE 3

s4:

begin

presState<=s0;

c<=5'b01010;

end // end STATE 4

default:

begin

presState<=s0;

c<=5'b00000;

end // end DEFAULT

endcase // end STATE MACHINE case

end // end STATE MACHINE

wire [1:0] jk0, jk1;

reg jkq0, jkq1;

// jk-flip flops =================================

assign jk1[1]=c[0];

assign jk1[0]=c[1];

assign jk0[1]=c[2];

assign jk0[0]=c[3];

always @(posedge clk)

begin

case(jk0)

0: jkq0<=jkq0; // hold

1: jkq0<=0; // reset

2: jkq0<=1; // set

3: jkq0<=~jkq0;// toggle

default: jkq0<=0; // default

endcase // end jk0

case(jk1)

0: jkq1<=jkq1; // hold

1: jkq1<=0; // reset

2: jkq1<=1; // set

3: jkq1<=~jkq1;// toggle

default: jkq1<=0; // default

endcase // end jk1

end // end jk-flip flops

assign SPI_SCK=jkq1;

assign transmitting=jkq0;

assign DAC_CS=~jkq0;

reg [31:0] shlReg;

// 32-bit reg =================================

always @(posedge clk)

begin

if(c[2])

shlReg<={4'd0, DAC_in};

else if(c[4])

shlReg<=(shlReg<<1);

end // end 32-bit reg

assign SPI_MOSI=shlReg[31];

endmodule

*/
