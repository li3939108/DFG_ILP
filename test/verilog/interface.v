`include "approximate/roy1/AMA_64bit_adder_bus.v"
`include "approximate/jiehan/Multiplier_appr_gate.v"
`include "approximate/jiehan/osu018_stdcells.v"

/*
 Approximate multiplier
 */
module mul_0(
	out, in_0, in_1
);
input wire [15:0] in_0, in_1;
output wire [31:0] out;

Multiplier_appr mul(out, in_0, in_1);

endmodule

/*
 * Accurate multiplier
 */
module mul_1(
	out, in_0, in_1
);
input wire [15:0] in_0, in_1;
output wire [31:0] out;

assign out = in_0 * in_1 ;

endmodule

/*
 * Approximate adder
 */
module add_0(
	 out, in_0, in_1
);
input wire [63:0] in_0, in_1;
output wire [63:0] out;
wire Cin, Cout;

assign Cin = 1'b0 ;

AMA_64bit_adder_bus add(Cout, out, in_0, in_1, Cin);

endmodule

/*
 * Accurate adder
 */
module add_1(
	 out, in_0, in_1
);
input wire [63:0] in_0, in_1;
output wire [63:0] out;
wire Cin, Cout;

assign Cin = 1'b0 ;
assign out = in_0 + in_1 + Cin;

endmodule
