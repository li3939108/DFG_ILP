module cla8 (SUM, IN1, IN2);

  input [7:0] IN1,IN2;
  output [8:0] SUM;
//  output cout;

  wire [7:0] P,G;
  wire [8:0] C;

  assign C[0] = 1'b0;

  assign P = IN1^IN2;
  assign G = IN1&IN2;
  assign SUM[7:0] = P^C;
  assign SUM[8] = C[8];
//  assign AC = C[4];

  assign C[1] = G[0];
generate
  genvar i;
  for (i = 1; i < 9; i = i + 1)
  begin: L1
    assign C[i] = G[i-1]|(P[i-1]&C[i-1]);
  end
endgenerate

endmodule
