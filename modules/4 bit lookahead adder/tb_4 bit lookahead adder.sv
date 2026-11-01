`timescale 1ns / 1ps

module tb_add_4bit;

  reg  [3:0] A;
  reg  [3:0] B;
  reg        C_in;
  wire [3:0] S;
  wire       C_out;

  // Expected output calculation (5-bit to hold Carry + Sum)
  wire [4:0] expected_result;
  assign expected_result = A + B + C_in;

 // tracking errors
  integer i, j, k;
  integer error_count;

  // Instantiation
  add_4bit dut (
    .S(S),
    .C_out(C_out),
    .A(A),
    .B(B),
    .C_in(C_in)
  );

  initial begin
    error_count = 0;

    
    for (k = 0; k < 2; k = k + 1) begin          // C_in loop (0 to 1)
      for (i = 0; i < 16; i = i + 1) begin       // A loop (0 to 15)
        for (j = 0; j < 16; j = j + 1) begin     // B loop (0 to 15)
          A    = i[3:0];
          B    = j[3:0];
          C_in = k[0];

          #10; // Wait 10ns for combinational logic to settle

          // Check DUT outputs against reference 
          if ({C_out, S} !== expected_result) begin
            $display("[ERROR] Mismatch at time %0t ns: A=%b (%0d), B=%b (%0d), C_in=%b | Expected {C_out, S}=%b, Got {C_out, S}=%b", 
                     $time, A, A, B, B, C_in, expected_result, {C_out, S});
            error_count = error_count + 1;
          end
        end
      end
    end

    // Summary report
    $display("--------------------------------------------------");
    if (error_count == 0) begin
      $display("TEST PASSED: All 512 input combinations verified successfully!");
    end else begin
      $display("TEST FAILED: %0d error(s) detected.", error_count);
    end
    $display("--------------------------------------------------");

    $finish;
  end

endmodule