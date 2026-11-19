`timescale 1ns / 1ps
//"Every clock cycle, check whether I'm resetting. If I am, clear everything. Otherwise, keep counting clock cycles.
 //When I've counted half of the required period, flip the audio output and start counting again."
//The tone generator converts the high-frequency system clock into an audio-frequency square wave. It uses a counter and a programmable divisor
// to determine when to toggle the output. By changing the divisor, it can generate different musical notes such as C4, D4, or A4
module tonegen (
    input  wire        clk,
    input  wire        rst,
    input  wire [22:0] divisor,
    output reg         audio_out
);
    reg [22:0] counter;

    always @(posedge clk) begin
        if (rst) begin
            audio_out <= 1'b0;
            counter   <= 23'd0;
        end else if (counter >= (divisor >> 1)) begin
            audio_out <= ~audio_out;
            counter   <= 23'd0;
        end else begin
            counter   <= counter + 1'b1;
        end
    end
endmodule