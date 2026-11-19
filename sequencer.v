`timescale 1ns / 1ps
module sequencer #(
    parameter MAX_COUNT = 24'd12_499_999 // 120 BPM (16th notes) at 100 MHz
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire       pause,
    output reg  [3:0] address,
    output wire       audio_en
);

    // State encoding
    localparam IDLE  = 2'b00;
    localparam PLAY  = 2'b01;
    localparam PAUSE = 2'b10;

    reg [1:0]  current_state, next_state;
    reg [23:0] bpm_counter;

    // ---------------------------------------------------------
    // 1. State Register (Sequential: updates current state)
    // ---------------------------------------------------------
    always @(posedge clk) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // ---------------------------------------------------------
    // 2. Next-State Logic (Combinational: decides where to go)
    // ---------------------------------------------------------
    always @(*) begin
        next_state = current_state; // Safe default prevents latches

        case (current_state)
            IDLE: begin
                if (start)
                    next_state = PLAY;
            end

            PLAY: begin
                if (pause)
                    next_state = PAUSE;
            end

            PAUSE: begin
                if (!pause)
                    next_state = PLAY;
            end

            default: next_state = IDLE;
        endcase
    end

    // ---------------------------------------------------------
    // 3. Datapath & Output Logic (Controls counters & outputs)
    // ---------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            bpm_counter <= 24'd0;
            address     <= 4'd0;
        end else begin
            case (current_state)
                IDLE: begin
                    bpm_counter <= 24'd0;
                    address     <= 4'd0;
                end

                PLAY: begin
                    if (bpm_counter == MAX_COUNT) begin
                        bpm_counter <= 24'd0;
                        address     <= address + 1'b1; // Wraps 15 -> 0 automatically
                    end else begin
                        bpm_counter <= bpm_counter + 1'b1;
                    end
                end

                PAUSE: begin
                    // Hold current bpm_counter and address values
                    bpm_counter <= bpm_counter;
                    address     <= address;
                end

                default: begin
                    bpm_counter <= 24'd0;
                    address     <= 4'd0;
                end
            endcase
        end
    end

    // Enable sound output only while actively playing
    assign audio_en = (current_state == PLAY);

endmodule
