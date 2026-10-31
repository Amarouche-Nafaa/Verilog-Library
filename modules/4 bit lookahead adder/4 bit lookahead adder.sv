//4-bit carry-lookahead adder:

module add_4bit (S,C_out,A,B,C_in);
  input [3:0] A, B;  // A and B are 4 bit numbers 
  input C_in;
  output[3:0] S;  // S is the result, it's a 4 bit number .
  output C_out; 
  wire [3:0] P, G; 
  wire [3:0] C;  // C[0] will be C_in.
  
  // carry propagate:
  
  assign P = A ^ B; 
  
  
  
  //carry generate:
  
  assign G = A & B;
  
  
  
  
  // put the carries in one bus:
  
  assign C[0] = C_in;
  
  
   
  // carries: 
  
  assign C[1] = G[0] | (P[0] & C[0]);
  assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
  assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
  assign C_out = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & C[0]);
  
  
  
  // Sum: 
  
  assign S = P ^ C;
  
  
  
  endmodule