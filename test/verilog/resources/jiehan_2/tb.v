`timescale 1ns / 1ns 
`include "Multiplier_appr.v"
//`include "osu018_stdcells.v"

module stimulus;

parameter N = 16;

reg signed [N - 1 : 0] a, b;
wire signed [N * 2 - 1 : 0] out;

Multiplier_appr nn(out, a, b);

initial
begin
#5	a=16'b0001011001011100; b=16'b1100011101111100;
#5	a=16'b1100011101111100; b=16'b0000000001011100;
#5	a=16'b0000000010111011; b=16'b0000001010100101;
#5	a=16'b1000110010111011; b=16'b1001101010100101;
#5	a=16'b1100110010111011; b=16'b1011101010100101;

end

//initial
//	$sdf_annotate("Multiplier_appr.sdf", nn);
initial#5	$monitor("a=%d, b=%d, out=%d",a, b, out);

endmodule
