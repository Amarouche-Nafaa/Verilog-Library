// =============================================================================
// exhaustive self-checking testbench for rca4
// 2^9 = 512 input combinations (a, b, cin) are applied and every result is
// compared with a golden model written with the '+' operator.
// =============================================================================
`timescale 1ns/1ps

module tb_rca4;
    // ---- DUT signals: inputs are 'reg' (driven here), outputs are 'wire'
    reg  [3:0] a, b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;

    // ---- Verification bookkeeping
    reg  [4:0] expected;
    integer    i;
    integer    errors = 0;

    // ---- Device Under Test
    rca4 dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    initial begin
`ifdef FST                                 // iverilog -DFST ... ; vvp ... -fst
        $dumpfile("tb_rca4.fst");
`else
        $dumpfile("tb_rca4.vcd");          // waveform file for GTKWave
`endif
        $dumpvars(0, tb_rca4);             // dump everything below tb_rca4

        // Directed worst case (0-20 ns): 1111 + 0000 with cin 0 -> 1 at t = 10 ns
        // forces the carry to ripple through all four full adders.
        a = 4'hF; b = 4'h0; cin = 1'b0;  #10;
        cin = 1'b1;                      #10;

        // Exhaustive test (from t = 20 ns): every {cin, a, b} combination
        for (i = 0; i < 512; i = i + 1) begin
            {cin, a, b} = i[8:0];          // apply the stimulus
            #10;                           // wait > worst-case ripple delay
            expected = a + b + cin;        // golden (reference) model
            if ({cout, sum} !== expected) begin
                errors = errors + 1;
                $display("[%0d ns] ERROR: %0d + %0d + %0d = %0d, expected %0d",
                         $time, a, b, cin, {cout, sum}, expected);
            end
        end

        if (errors == 0) $display("PASS: tb_rca4 - all 512 vectors correct");
        else             $display("FAIL: tb_rca4 - %0d of 512 vectors wrong", errors);
        $finish;
    end
endmodule
