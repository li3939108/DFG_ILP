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
#5	a=16'b1000001010111001; b=16'b1000101111000100;
#5	a=16'b0101011001011100; b=16'b0100011101111100;
#5	a=16'b0001011001011100; b=16'b1100011101111100;
#5	a=16'b1100011101111100; b=16'b0000000001011100;
#5	a=16'b0000000010111011; b=16'b0000001010100101;
#5	a=16'b1000110010111011; b=16'b1001101010100101;
#5	a=16'b0100000010111011; b=16'b0100001010100101;
#5	a=16'b1000000000000001; b=16'b1000000000000001;
#5	a=16'b1111111111111111; b=16'b1111111111111111;
#5	a=16'b1111111000111111; b=16'b0000000000000110;
#5	a=16'b0000000000000110; b=16'b1111111000111111;
#5	a=16'b0101011001011100; b=16'b0100011101111100;
#5	a=16'b0001011001011100; b=16'b1100011101111100;
#5	a=16'b1011011101111100; b=16'b1011100001011100;
#5	a=16'b0000000010111011; b=16'b0000001010100101;
#5	a=16'b1000110010111011; b=16'b1001101010100101;
#5	a=16'b1111110010111011; b=16'b1111111010100101;
#5	a=16'b0111111111111111; b=16'b0111111111111111;
#5	a=16'b1000000000000001; b=16'b1000000000000001;
end

//initial
//	$sdf_annotate("Multiplier_appr.sdf", nn);
initial

endmodule