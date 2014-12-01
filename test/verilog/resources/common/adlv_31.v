//`include "cell.v"
`ifndef __ADLV_31_V__
`define __ADLV_31_V__
module adlv_31(s_out, e_out, A, B);	//output 31bits, input 23bits
	parameter BIT = 23;		//input bit width
	parameter SPA = 8;		//space bits before A and after B
	input [BIT - 1 : 0] A, B;
	output [BIT + SPA - 1 : 0] s_out, e_out;

	wire [BIT + SPA - 1 : 0] mid_u, mid_l;

	assign mid_u = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, A};
	assign mid_l = {B, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};

	cell n0(s_out[0], e_out[0], mid_u[0], mid_l[0], 1'b0, 1'b0); //process the last bit

	genvar j;
	generate
	for (j = 0; j < 30;  j = j + 1)	//BIT + SPA - 1
	begin: LVL1
		cell n1(s_out[j + 1], e_out[j + 1], mid_u[j + 1], mid_l[j + 1], mid_u[j], mid_l[j]);
	end
	endgenerate
endmodule
`endif
