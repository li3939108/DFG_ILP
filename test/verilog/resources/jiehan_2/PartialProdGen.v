module PartialProdGen(out, A, B);
	parameter BITWIDTH = 16;
	input [BITWIDTH - 1 : 0] A, B;
	output [BITWIDTH * BITWIDTH - 1 : 0] out;
	wire [BITWIDTH * BITWIDTH - 1 : 0] out;

	generate 
	genvar i, j;

	for(i = 0; i < 16; i = i + 1)
	begin: gen_1
		for(j = 0; j < 16; j = j + 1)
		begin: gen_2
			assign out[16 * i + j] = A[j] & B[i];
		end
	end
	endgenerate

endmodule
