//`include "PartialProdGen.v"
`include "cell.v"
`include "adlv_17.v"
`include "adlv_19.v"
`include "adlv_23.v"
`include "adlv_31.v"
`include "cla.v"
`include "booth.v"
`include "CS_Adder32.v"
//`include "head_adder.v"

//top module of approximate multiplier
module Multiplier_appr(out, A, B);

	parameter BIT = 16;
	parameter REC = 16;

	input [BIT - 1 : 0] A, B;
	output [BIT * 2 - 1 : 0] out;

	wire [15:0] pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7, pp8, pp9, pp10, pp11, pp12, pp13, pp14, pp15; 
	
	wire	[31: 0]	sign_compensate;
	wire	[31: 0]	res_tmp;
	wire	[15: 0]	sign;
	
	wire [BIT * BIT - 1 : 0] prd_m;	//partial product stored

	wire [BIT : 0] ev17_1, ev17_2, ev17_3, ev17_4, ev17_5, ev17_6, ev17_7, ev17_8;
	wire [BIT : 0] es17_1, es17_2, es17_3, es17_4, es17_5, es17_6, es17_7, es17_8;

	wire [BIT + 2 : 0] ev19_1, ev19_2, ev19_3, ev19_4;
	wire [BIT + 2 : 0] es19_1, es19_2, es19_3, es19_4;

	wire [BIT + 6 : 0] ev23_1, ev23_2;
	wire [BIT + 6 : 0] es23_1, es23_2;

	wire [BIT + 14 : 0] ev31;
	wire [BIT + 14 : 0] es31;

	wire [REC - 1 : 0] er1, er2, er3, er4, er5, er6, er7, er8;	//error recovery
	wire [REC - 1 : 0] er9, er10, er11, er12, er13, er14, er15, er_out;
	wire [REC : 0] rsl_head;

//	PartialProdGen ppg(prd_m, A, B);
	Booth_Classic nqq( .M(A),	.R(B),
						.pp0( pp0 ),
						.pp1( pp1 ),
						.pp2( pp2 ),
						.pp3( pp3 ),
						.pp4( pp4 ),
						.pp5( pp5 ),
						.pp6( pp6 ),
						.pp7( pp7 ),
						.pp8( pp8 ),
						.pp9( pp9 ),
						.pp10( pp10 ),
						.pp11( pp11 ),
						.pp12( pp12 ),
						.pp13( pp13 ),
						.pp14( pp14 ),
						.pp15( pp15 ),
						.S( sign )
					);

	assign prd_m = { pp15, pp14, pp13, pp12, pp11, pp10, pp9, pp8, pp7, pp6, pp5, pp4, pp3, pp2, pp1, pp0};


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

	//error recovery processing: 16 bits
	assign er1 = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, es17_1[16:15]};
	assign er2 = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, es17_2[16:13]};
	assign er3 = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, es17_3[16:11]};
	assign er4 = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, es17_4[16:9]};
	assign er5 = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, es17_5[16:7]};
	assign er6 = {1'b0, 1'b0, 1'b0, 1'b0, es17_6[16:5]};
	assign er7 = {1'b0, 1'b0, es17_7[16:3]};
	assign er8 = es17_8[16:1];
	
	assign er9  = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, es19_1[18:15]};
	assign er10 = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, es19_2[18:11]};
	assign er11 = {1'b0, 1'b0, 1'b0, 1'b0, es19_3[18:7]};
	assign er12 = es19_4[18:3];

	assign er13 = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, es23_1[22:15]};
	assign er14 = es23_2[22:7];

	assign er15 = es31[30:15];

	generate
	genvar i;
	for(i = 0; i < 16; i = i + 1)
	begin: ER_OR
		assign er_out[i] = (er1[i] | er2[i] | er3[i] | er4[i] | er5[i] | er6[i] | er7[i] | er8[i]
					| er9[i] | er10[i] | er11[i] | er12[i] | er13[i] | er14[i] | er15[i]);
	end
	endgenerate

	cla16 head(rsl_head, ev31[30:15], er_out);
	assign res_tmp = {rsl_head, ev31[14:0]};

	CS_Adder32	signcomp (
						.a( {~sign, 16'b0} ),
						.b( {15'b0, 1'b1, 16'b0} ),
						.cin( 1'b0 ),
						.sum( sign_compensate )
					);

	CS_Adder32	result (
						.a( res_tmp ),
						.b( sign_compensate ),
						.cin( 1'b0 ),
						.sum( out)
					);





endmodule
