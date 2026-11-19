`timescale 1ns / 1ps
//It stores the sequence of notes as divisor values at different memory addresses.
//The sequencer gives it an address, and the ROM returns the corresponding divisor.
//The divisor is sent to the Tone Generator, which produces that note's frequency.
module note_rom (
    input  wire clk,input  wire  [3:0] address, output reg  [22:0] divisor);

    // Defining dummy 23-bit parameters for the sequence
parameter d0  = 23'd100000,
d1  = 23'd110000,
d2  = 23'd120000,
d3  = 23'd130000,
d4  = 23'd140000,
d5  = 23'd150000,
d6  = 23'd160000,
d7  = 23'd170000,
d8  = 23'd180000,
d9  = 23'd190000,
d10 = 23'd200000,
d11 = 23'd210000,
 d12 = 23'd220000,
  d13 = 23'd230000,
  d14 = 23'd240000,
  d15 = 23'd0;      // 0 can act as a musical rest

always @(posedge clk) begin
case (address)
4'd0:  divisor <= d0;
4'd1:  divisor <= d1;
4'd2:  divisor <= d2;
4'd3:  divisor <= d3;
4'd4:  divisor <= d4;
4'd5:  divisor <= d5;
4'd6:  divisor <= d6;
4'd7:  divisor <= d7;
4'd8:  divisor <= d8;
4'd9:  divisor <= d9;
4'd10: divisor <= d10;
4'd11: divisor <= d11;
4'd12: divisor <= d12;
4'd13: divisor <= d13;
4'd14: divisor <= d14;
4'd15: divisor <= d15;
default: divisor <= 23'd0;
endcase
end

endmodule