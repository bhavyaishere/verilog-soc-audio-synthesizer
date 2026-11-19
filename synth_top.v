module synth_top #(
    parameter MAX_COUNT = 24'd12_499_999
)(
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire pause,
    output wire audio_out
);

    wire [3:0]  rom_addr;
    wire [22:0] current_divisor;
    wire        audio_en;
    wire        raw_audio;

    sequencer #(
        .MAX_COUNT(MAX_COUNT)
    ) u_seq (
        .clk      (clk),
        .rst      (rst),
        .start    (start),
        .pause    (pause),
        .address  (rom_addr),
        .audio_en (audio_en)
    );

    note_rom u_rom (
        .clk     (clk),
        .address (rom_addr),
        .divisor (current_divisor)
    );

    tonegen u_tone (
        .clk       (clk),
        .rst       (rst),
        .divisor   (current_divisor),
        .audio_out (raw_audio)
    );

    assign audio_out = raw_audio & audio_en & (current_divisor != 23'd0);

endmodule
