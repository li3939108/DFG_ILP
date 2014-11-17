//`include "cell.v"
module adlv_19(s_out, e_out, A, B);	//output 19bits, input 17bits
	parameter BIT = 17;		//input bit width
	parameter SPA = 2;
	input [BIT - 1 : 0] A, B;
	output [BIT + SPA - 1 : 0] s_out, e_out;

	wire [BIT + SPA - 1 : 0] mid_u, mid_l;

	assign mid_u = {1'b0, 1'b0, A};
	assign mid_l = {B, 1'b0, 1'b0};

	cell n0(s_out[0], e_out[0], mid_u[0], mid_l[0], 1'b0, 1'b0); //process the last bit

	genvar j;
	generate
	for (j = 0; j < 18;  j = j + 1)	//BIT + SPA - 1
	begin: LVL1
		cell n1(s_out[j + 1], e_out[j + 1], mid_u[j + 1], mid_l[j + 1], mid_u[j], mid_l[j]);
	end
	endgenerate
endmodule

