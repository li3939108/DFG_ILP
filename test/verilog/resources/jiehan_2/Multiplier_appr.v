`include "PartialProdGen.v"
`include "cell.v"
`include "adlv_17.v"
`include "adlv_19.v"
`include "adlv_23.v"
`include "adlv_31.v"
`include "cla.v"
//`include "head_adder.v"

//top module of approximate multiplier
module Multiplier_appr(out, A, B);

	parameter BIT = 16;
	parameter REC = 8;

	input [BIT - 1 : 0] A, B;
	output [BIT * 2 - 1 : 0] out;
	
	wire [BIT - 1 : 0] A_in, B_in;
	wire sign, sign_2;
	
	assign A_in = (A[BIT - 1] == 0) ? A : (~A + 1'b1);
	assign B_in = (B[BIT - 1] == 0) ? B : (~B + 1'b1);
	assign sign = A[BIT - 1] ^ B[BIT - 1];
	assign sign_2 = sign;
	
	wire [BIT * BIT - 1 : 0] prd_m;	//partial product stored

	wire [BIT : 0] ev17_1, ev17_2, ev17_3, ev17_4, ev17_5, ev17_6, ev17_7, ev17_8;
	wire [BIT : 0] es17_1, es17_2, es17_3, es17_4, es17_5, es17_6, es17_7, es17_8;

	wire [BIT + 2 : 0] ev19_1, ev19_2, ev19_3, ev19_4;
	wire [BIT + 2 : 0] es19_1, es19_2, es19_3, es19_4;

	wire [BIT + 6 : 0] ev23_1, ev23_2;
	wire [BIT + 6 : 0] es23_1, es23_2;

	wire [BIT + 14 : 0] ev31;
	wire [BIT + 14 : 0] es31;

	wire [REC - 1 : 0] er1, er2, er3, er4, er5, er6, er7, er8, er_out;	//error recovery
	wire [REC : 0] rsl_head;

	PartialProdGen ppg(prd_m, A_in, B_in);

	//LEVEL 1:
	adlv_17 ad11(ev17_1, es17_1, prd_m[BIT * 1 - 1 : BIT * 0], prd_m[BIT * 2 - 1 : BIT * 1]);
	adlv_17 ad12(ev17_2, es17_2, prd_m[BIT * 3 - 1 : BIT * 2], prd_m[BIT * 4 - 1 : BIT * 3]);
	adlv_17 ad13(ev17_3, es17_3, prd_m[BIT * 5 - 1 : BIT * 4], prd_m[BIT * 6 - 1 : BIT * 5]);
	adlv_17 ad14(ev17_4, es17_4, prd_m[BIT * 7 - 1 : BIT * 6], prd_m[BIT * 8 - 1 : BIT * 7]);
	adlv_17 ad15(ev17_5, es17_5, prd_m[BIT * 9 - 1 : BIT * 8], prd_m[BIT * 10 - 1 : BIT * 9]);
	adlv_17 ad16(ev17_6, es17_6, prd_m[BIT * 11 - 1 : BIT * 10], prd_m[BIT * 12 - 1 : BIT * 11]);
	adlv_17 ad17(ev17_7, es17_7, prd_m[BIT * 13 - 1 : BIT * 12], prd_m[BIT * 14 - 1 : BIT * 13]);
	adlv_17 ad18(ev17_8, es17_8, prd_m[BIT * 15 - 1 : BIT * 14], prd_m[BIT * 16 - 1 : BIT * 15]);

	//LEVEL 2:
	adlv_19 ad21(ev19_1, es19_1, ev17_1, ev17_2);
	adlv_19 ad22(ev19_2, es19_2, ev17_3, ev17_4);
	adlv_19 ad23(ev19_3, es19_3, ev17_5, ev17_6);
	adlv_19 ad24(ev19_4, es19_4, ev17_7, ev17_8);

	//LEVEL 3:
	adlv_23 ad31(ev23_1, es23_1, ev19_1, ev19_2);
	adlv_23 ad32(ev23_2, es23_2, ev19_3, ev19_4);

	//LEVEL 4:
	adlv_31 ad41(ev31, es31, ev23_1, ev23_2);

	//error recovery processing: 8 bits
	assign er1 = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, es17_5[16:15]};
	assign er2 = {1'b0, 1'b0, 1'b0, 1'b0, es17_6[16:13]};
	assign er3 = {1'b0, 1'b0, es17_7[16:11]};
	assign er4 = es17_8[16:9];

	assign er5 = {1'b0, 1'b0, 1'b0, 1'b0, es19_3[18:15]};
	assign er6 = es19_4[18:11];

	assign er7 = es23_2[22:15];

	assign er8 = es31[30:23];

	generate
	genvar i;
	for(i = 0; i < 8; i = i + 1)
	begin: ER_OR
		assign er_out[i] = (er1[i] | er2[i] | er3[i] | er4[i] | er5[i] | er6[i] | er7[i] | er8[i]);
	end
	endgenerate

	cla8 head(rsl_head, ev31[30:23], er_out);

//tmp claim
wire [29:0] out_tmp;
	assign out_tmp = {rsl_head[6:0], ev31[22:0]};
	
	assign out = (sign == 0) ? { sign, sign_2, out_tmp } :
					{ sign, sign_2, ~out_tmp + 1'b1};

endmodule
