// =============================================================================
// MNE303 - Lab 3 | Part 1: 4-bit ripple-carry adder (structural style)
// Four full_adder instances chained through the carry vector c[4:0].
// =============================================================================
`timescale 1ns/1ps
`default_nettype none

module rca4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       cin,
    output wire [3:0] sum,
    output wire       cout
);
    wire [4:0] c;                       // internal carry chain
    assign c[0] = cin;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : g_fa
            full_adder u_fa (
                .a   (a[i]),
                .b   (b[i]),
                .cin (c[i]),
                .s   (sum[i]),
                .cout(c[i+1])
            );
        end
    endgenerate

    assign cout = c[4];
endmodule

`default_nettype wire
