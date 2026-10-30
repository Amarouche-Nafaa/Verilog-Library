// =============================================================================
// MNE303 - Lab 3 | Part 1: 1-bit full adder (dataflow style)
// DELAY models a gate propagation delay so that carry ripple and glitches
// become visible in GTKWave. Synthesis tools IGNORE '#' delays.
// =============================================================================
`timescale 1ns/1ps
`default_nettype none

module full_adder #(
    parameter DELAY = 1                 // propagation delay in ns (simulation only)
) (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire s,
    output wire cout
);
    assign #DELAY s    = a ^ b ^ cin;
    assign #DELAY cout = (a & b) | (cin & (a ^ b));
endmodule

`default_nettype wire
