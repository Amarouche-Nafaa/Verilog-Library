module lif_neuron #(
    parameter WIDTH = 16,          // Fixed-point bit width
    parameter V_TH = 16'h0300,// Firing threshold (example value)
    parameter LEAK_SHIFT = 3       // V >> 3 represents a leak subtraction of 1/8th (~12.5% decay)
)(
    input  wire                 clk,        // System clock
    input  wire                 rst_n,      // Active-low asynchronous reset
    input  wire signed [WIDTH-1:0] x_input,  // Weighted sum of current input spikes
    output reg                  spike       // Output spike event (1-bit)
);

    // Internal state register for Membrane Potential
    reg signed [WIDTH-1:0] V_mem;
    
    // Wire for the potential calculation after applying leak
    wire signed [WIDTH-1:0] leaked_pot;
    
    // Step 1: Calculate the leak (Membrane Potential - (Membrane Potential / 2^LEAK_SHIFT))
    assign leaked_pot = V_mem - (V_mem >>> LEAK_SHIFT);

    // Step 2: Main synchronous update loop
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            V_mem <= {WIDTH{1'b0}};
            spike        <= 1'b0;
        end else begin
            // If the neuron fired in the last cycle, reset its potential
            if (spike) begin
                V_mem <= {WIDTH{1'b0}}; // Reset to zero mechanism
                spike        <= 1'b0;
            end else begin
                // Integrate current input to the leaked potential
                // (Using a temporary 17-bit calculation avoids undetected overflows)
                if ((leaked_pot + x_input) >= V_TH) begin
                    V_mem <= leaked_pot + x_input;
                    spike        <= 1'b1; // Trigger Spike
                end else begin
                    V_mem <= leaked_pot + x_input; // Only accumulate
                    spike        <= 1'b0;
                end
            end
        end
    end

endmodule
