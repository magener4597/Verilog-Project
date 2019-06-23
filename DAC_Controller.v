`timescale 1ns / 1ps

module DAC_Controller(
    input [11:0] DAC_D,
    input clk,
    input trans,
    input reset_Async,
    output reg [27:0] DAC_in,
    output reg go_DAC
    );
    reg s;
    reg C0,C1;
    reg [2:0] state_next,state_reg;
    reg [2:0] S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5;
    
    //JK
    always@(posedge clk)
    begin
        case({C0,C1})
            2'b11: s <= ~ s;
            2'b01: s <= 0;
            2'b10: s <= 1;
            2'b00: s <= s;
        endcase
    end
    
    //Mux
    always@*
    begin
        if(s)
            DAC_in = {4'd8,4'd0,12'd0,8'd1};
        else if(s == 0)
            DAC_in = {4'd3,4'd0,DAC_D,8'd0};
    end
    
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
            go_DAC = 0; C1 = 0; C0 = 0;
            state_next = S0;
        end
        case(state_reg)
            S0:
            begin
                go_DAC = 0; C1 = 0; C0 = 1;
                state_next = S1;
            end
            S1:
            begin
                go_DAC = 1; C1 = 0; C0 = 0;
                state_next = S2;
            end
            S2:
            begin
                if(trans)
                begin
                    go_DAC = 0; C1 = 0; C0 = 0;
                    state_next = S2;
                end
                else
                begin
                    go_DAC = 0; C1 = 1; C0 = 0;
                    state_next = S3;
                end
            end
            S3:
            begin
                go_DAC = 1; C1 = 0; C0 = 0;
                state_next = S4;
            end
            S4:
            begin
                if(trans)
                begin
                    go_DAC = 0; C1 = 0; C0 = 0;
                    state_next = S4;
                end
                else
                begin
                    go_DAC = 0; C1 = 0; C0 = 0;
                    state_next = S5;
                end
            end
            S5:
            begin
                go_DAC = 0; C1 = 0; C0 = 1;
                state_next = S3;
            end
            default:
            begin
                go_DAC = 0; C1 = 0; C0 = 0;
                state_next = S0;
            end
        endcase
    end
    
endmodule


/*`timescale 1ns / 1ps

module controllerDAC(

input clk,

reset_Async,

transmitting,

input [11:0] DAC_D,

output go_DAC,

output [27:0] DAC_in

);

localparam [2:0] s0=0,

s1=1,

s2=2,

s3=3,

s4=4,

s5=5;

reg [2:0] presState=0;

reg [2:0] c;

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

presState<=s1;

c<=3'b001;

end // end STATE 0

s1:

begin

presState<=s2;

c<=3'b100;

end // end STATE1

s2:

begin

if(transmitting)

c<=3'b000; // end IF transmitting

else

begin

presState<=s3;

c<=3'b010;

end // end ELSE transmitting

end

s3:

begin

presState<=s4;

c<=3'b100;

end // end STATE 3

s4:

begin

c<=3'b000;

if(!transmitting)

presState<=s5; // end IF !transmitting

end // end STATE 4

s5:

begin

presState<=s3;

c<=3'b000;

end // end STATE 5

default:

begin

presState<=s0;

c<=3'b000;

end // end DEFAULT

endcase // end STATE MACHINE case

end // end STATE MACHINE

wire [1:0] jk;

reg jkq;

// jk-flip flop =================================

assign jk[1]=c[0];

assign jk[0]=c[1];

always @(posedge clk)

case(jk)

0: jkq<=jkq; // hold

1: jkq<=0; // reset

2: jkq<=1; // set

3: jkq<=~jkq; // toggle

default: jkq<=0; // default

endcase // end jk-flip flop

wire [27:0] i0, i1;

// mux =================================

assign i1={4'd8, 4'd0, 12'd0, 8'd1};

assign i0={4'd3, 4'd0, DAC_D, 8'd0};

assign DAC_in=(jkq)?i1:i0;

assign go_DAC=c[2];

endmodule



*/
