//`include "approximate/roy1/AMA_64bit_adder_bus.v"
`include "../resources/AMA_appr4_32bit_8appr/AMA_appr4_32bit_8appr.v"
`include "../resources/AMA_appr4_28bit_7appr/AMA_appr4_28bit_7appr.v"
`include "../resources/AMA_appr4_24bit_6appr/AMA_appr4_24bit_6appr.v"
//`include "../approximate/Han_multiplier_signed/Multiplier_appr.v"
`include "../resources/jiehan_bth/Multiplier_appr.v"
//`include "approximate/jiehan/Multiplier_appr_gate.v"
//`include "approximate/jiehan/osu018_stdcells.v"

/*
 Approximate multiplier
 */

`include "parameters.v"

module mul_0(
	out, in_0, in_1
);
input wire [31:0] in_0, in_1;
output wire [31:0] out;

wire [31:0] out_intermediate ;

assign out = {{32{out_intermediate[31]}}, out_intermediate[31:0]} >> `SHIFT_WIDTH  ;

Multiplier_appr mul(
	.out(out_intermediate), 
	.A(in_0[15:0]), 
	.B(in_1[15:0])
);

endmodule

/*
 * Accurate multiplier
 */
module mul_1(
	out, in_0, in_1
);


input wire [31:0] in_0, in_1;
output wire [31:0] out;

wire [31:0] out_intermediate ;

assign out = {{32{out_intermediate[31]}}, out_intermediate[31:0]} >> `SHIFT_WIDTH  ;
assign out_intermediate = in_0 * in_1 ;

endmodule

/*
 * Approximate adder 0
 */
module add_0(
	out, in_0, in_1
);
input wire [31:0] in_0, in_1;
output wire [31:0] out;
wire Cin, Cout;

assign Cin = 1'b0 ;

AMA_appr4_32bit_8appr add(Cout, out, in_0, in_1, Cin);

endmodule

/*
 * Approximate adder 1
 */
module add_1(
	out, in_0, in_1
);
input wire [31:0] in_0, in_1;
output wire [31:0] out;
wire Cin, Cout;

assign Cin = 1'b0 ;

AMA_appr4_28bit_7appr add(Cout, out[27:0], in_0[27:0], in_1[27:0], Cin);
assign out[31:28] = {4{out[27]}};

endmodule

/*
 * Approximate adder 22
 */
module add_2(
	out, in_0, in_1
);
input wire [31:0] in_0, in_1;
output wire [31:0] out;
wire Cin, Cout;

assign Cin = 1'b0 ;

AMA_appr4_24bit_6appr add(Cout, out, in_0[23:0], in_1[23:0], Cin);

endmodule



/*
 * Accurate adder
 */
module add_x(
	out, in_0, in_1
);
input wire [31:0] in_0, in_1;
output wire [31:0] out;
wire Cin, Cout;

assign Cin = 1'b0 ;
assign out = in_0 + in_1 + Cin;

endmodule
