// =============================================================================
// MNE303 - Lab 3 | Part 2: self-checking testbench for counter4
//   * clock generator + reset sequence
//   * directed tests (wrap up, hold, load, wrap down, async reset)
//   * constrained-random test, seed selectable with +seed=<n>
//   * reference model + automatic comparison + simple functional coverage
// Timing convention: stimulus changes on negedge, checks 2 ns after negedge,
// DUT samples on posedge -> no race between testbench and design.
// =============================================================================
`timescale 1ns/1ps

module tb_counter4;
    localparam CLK_PERIOD = 10;            // 100 MHz

    reg        clk   = 1'b0;
    reg        rst_n = 1'b0;
    reg        load  = 1'b0, en = 1'b0, up = 1'b1;
    reg  [3:0] d     = 4'd0;
    wire [3:0] q;
    wire       tc;

    // ---- Verification bookkeeping
    reg  [3:0] ref_q;                      // reference model state
    integer    errors = 0, checks = 0;
    integer    cov_wrap_up = 0, cov_wrap_dn = 0, cov_load = 0;
    integer    seed = 1, k;

    // ---- Device Under Test
    counter4 dut (.clk(clk), .rst_n(rst_n), .load(load), .d(d),
                  .en(en), .up(up), .q(q), .tc(tc));

    // ---- Clock generator
    always #(CLK_PERIOD/2) clk = ~clk;

    // ---- Reference model (behavioural, cycle accurate) + coverage counters
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            ref_q <= 4'd0;
        else if (load) begin
            ref_q    <= d;
            cov_load = cov_load + 1;
        end
        else if (en) begin
            if ( up && ref_q == 4'hF) cov_wrap_up = cov_wrap_up + 1;
            if (!up && ref_q == 4'h0) cov_wrap_dn = cov_wrap_dn + 1;
            ref_q <= up ? ref_q + 4'd1 : ref_q - 4'd1;
        end
    end

    // ---- Checker (scoreboard)
    always @(negedge clk) begin
        #2;
        checks = checks + 1;
        if (q !== ref_q || tc !== (en & (up ? ref_q == 4'hF : ref_q == 4'h0))) begin
            errors = errors + 1;
            $display("[%0d ns] ERROR: q=%h tc=%b, expected q=%h (en=%b up=%b load=%b)",
                     $time, q, tc, ref_q, en, up, load);
        end
    end

    // ---- Helper task: wait n clock cycles (stimulus changes on negedge)
    task cycles(input integer n);
        repeat (n) @(negedge clk);
    endtask

    // ---- Stimulus
    initial begin
`ifdef FST                                 // iverilog -DFST ... ; vvp ... -fst
        $dumpfile("tb_counter4.fst");
`else
        $dumpfile("tb_counter4.vcd");
`endif
        $dumpvars(0, tb_counter4);
        if ($value$plusargs("seed=%d", seed))
            $display("INFO: using random seed %0d", seed);

        // T1: reset
        cycles(2);  rst_n = 1'b1;
        // T2: count up through a wrap-around (0 -> 15 -> 0 -> ...)
        en = 1'b1; up = 1'b1;            cycles(20);
        // T3: hold
        en = 1'b0;                       cycles(3);
        // T4: synchronous load of 0xA
        load = 1'b1; d = 4'hA;           cycles(1);
        load = 1'b0;
        // T5: count down through a wrap-around
        en = 1'b1; up = 1'b0;            cycles(14);
        // T6: asynchronous reset pulse in the middle of a clock-high phase
        @(posedge clk); #2 rst_n = 1'b0; #2 rst_n = 1'b1;
        cycles(3);
        // T7: constrained random (load is rare: about 1 cycle in 8)
        for (k = 0; k < 300; k = k + 1) begin
            @(negedge clk);
            load = (($random(seed) & 7) == 0);
            d    = $random(seed);
            en   = $random(seed);
            up   = $random(seed);
        end
        cycles(2);

        $display("------------------------------------------------------------");
        $display("Coverage : %0d wrap-ups, %0d wrap-downs, %0d loads",
                 cov_wrap_up, cov_wrap_dn, cov_load);
        if (errors == 0) $display("PASS: tb_counter4 - %0d checks, 0 errors", checks);
        else             $display("FAIL: tb_counter4 - %0d checks, %0d errors", checks, errors);
        $finish;
    end
endmodule
