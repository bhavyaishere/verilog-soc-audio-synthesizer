`timescale 1ns / 1ps

module tb_synth_top;

    // Testbench signals
    reg  clk;
    reg  rst;
    reg  start;
    reg  pause;
    wire audio_out;

    integer errors = 0;
    reg [3:0] saved_addr;

    // Override MAX_COUNT to 300,000 cycles (3 ms per step at 100 MHz)
    // so all 16 ROM steps simulate in under 60 ms
    synth_top #(
        .MAX_COUNT(24'd300_000)
    ) dut (
        .clk       (clk),
        .rst       (rst),
        .start     (start),
        .pause     (pause),
        .audio_out (audio_out)
    );

    // 100 MHz System Clock (10 ns period)
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $display("=== STARTING SYNTH_TOP SELF-CHECKING TESTBENCH ===");

        // 1. Test Reset
        rst   = 1'b1;
        start = 1'b0;
        pause = 1'b0;
        #50;
        if (audio_out !== 1'b0 || dut.rom_addr !== 4'd0) begin
            $display("[FAIL] Reset state invalid.");
            errors = errors + 1;
        end else begin
            $display("[PASS] Reset verified.");
        end

        // 2. Test IDLE State (should remain silent before start)
        rst = 1'b0;
        #1000;
        if (audio_out !== 1'b0) begin
            $display("[FAIL] Audio active while in IDLE state.");
            errors = errors + 1;
        end else begin
            $display("[PASS] IDLE silence verified.");
        end

        // 3. Test PLAY State & Tone Generation
        start = 1'b1;
        @(posedge audio_out); // Wait for first wave toggle from tonegen
        $display("[PASS] PLAY state active: audio_out toggling detected at %0t ns.", $time);

        // Wait for sequencer to step from address 0 -> 1 -> 2
        wait (dut.rom_addr == 4'd2);
        $display("[PASS] Sequencer stepped to ROM address 2 at %0t ns.", $time);

        // 4. Test PAUSE State
        #100;
        pause      = 1'b1;
        saved_addr = dut.rom_addr;
        #50; // Allow state transition

        if (audio_out !== 1'b0) begin
            $display("[FAIL] Audio did not mute during PAUSE.");
            errors = errors + 1;
        end

        // Wait longer than one full step (3.5 ms) to ensure address stays frozen
        #3_500_000;
        if (dut.rom_addr !== saved_addr) begin
            $display("[FAIL] Sequencer address changed during PAUSE.");
            errors = errors + 1;
        end else begin
            $display("[PASS] PAUSE verified: output muted and ROM address frozen at %0d.", saved_addr);
        end

        // 5. Test RESUME & Step Rollover
        pause = 1'b0;
        wait (dut.rom_addr == 4'd3);
        $display("[PASS] Resumed playback: advanced to ROM address 3 at %0t ns.", $time);

        // Final Verification Summary
        #1000;
        if (errors == 0)
            $display("=== ALL TESTS PASSED (0 ERRORS) ===");
        else
            $display("=== SIMULATION FAILED WITH %0d ERROR(S) ===", errors);

        $finish;
    end

endmodule