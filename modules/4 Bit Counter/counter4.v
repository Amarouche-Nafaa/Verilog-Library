// =============================================================================
// 4-bit up/down counter
//   Priority : rst_n (async) > load (sync) > en (sync)
//   tc       : terminal count, high when the NEXT enabled count wraps around
//              (q == 15 while counting up, q == 0 while counting down)
// =============================================================================
`timescale 1ns/1ps
`default_nettype none

module counter4 (
    input  wire       clk,
    input  wire       rst_n,            // asynchronous reset, active low
    input  wire       load,             // synchronous parallel load
    input  wire [3:0] d,                // value to load
    input  wire       en,               // count enable
    input  wire       up,               // 1 = count up, 0 = count down
    output reg  [3:0] q,
    output wire       tc
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 4'd0;
        else if (load)
            q <= d;
        else if (en)
            q <= up ? q + 4'd1 : q - 4'd1;
    end

    assign tc = en & (up ? (q == 4'hF) : (q == 4'h0));
endmodule

`default_nettype wire
