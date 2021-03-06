module arf_variance(
	in_1_0,	in_2_0,	in_3_0,	in_4_0,	in_5_0,	in_6_0,	in_7_0,	in_8_0,
	in_13_1, in_14_1,	
	out_27, out_28
);
`include "declarations.v"

/*****arf***ILP**50000*****/

mul_0 multiplier_1 (out_1, in_1_0, in_1_1 );
mul_1 multiplier_2 (out_2, in_2_0, in_2_1 );
mul_0 multiplier_3 (out_3, in_3_0, in_3_1 );
mul_0 multiplier_4 (out_4, in_4_0, in_4_1 );
mul_1 multiplier_5 (out_5, in_5_0, in_5_1 );
mul_1 multiplier_6 (out_6, in_6_0, in_6_1 );
mul_1 multiplier_7 (out_7, in_7_0, in_7_1 );
mul_0 multiplier_8 (out_8, in_8_0, in_8_1 );
add_1 adder_9       (out_9, in_9_0, in_9_1 );
add_2 adder_10       (out_10, in_10_0, in_10_1 );
add_2 adder_11       (out_11, in_11_0, in_11_1 );
add_2 adder_12       (out_12, in_12_0, in_12_1 );
add_3 adder_13       (out_13, in_13_0, in_13_1 );
add_2 adder_14       (out_14, in_14_0, in_14_1 );
mul_0 multiplier_15 (out_15, in_15_0, in_15_1 );
mul_1 multiplier_16 (out_16, in_16_0, in_16_1 );
mul_1 multiplier_17 (out_17, in_17_0, in_17_1 );
mul_0 multiplier_18 (out_18, in_18_0, in_18_1 );
add_2 adder_19       (out_19, in_19_0, in_19_1 );
add_2 adder_20       (out_20, in_20_0, in_20_1 );
mul_0 multiplier_21 (out_21, in_21_0, in_21_1 );
mul_0 multiplier_22 (out_22, in_22_0, in_22_1 );
mul_1 multiplier_23 (out_23, in_23_0, in_23_1 );
mul_1 multiplier_24 (out_24, in_24_0, in_24_1 );
add_1 adder_25       (out_25, in_25_0, in_25_1 );
add_2 adder_26       (out_26, in_26_0, in_26_1 );
add_1 adder_27       (out_27, in_27_0, in_27_1 );
add_2 adder_28       (out_28, in_28_0, in_28_1 );


/*****arf***ILP***30000****/
/*
mul_0 multiplier_1 (out_1, in_1_0, in_1_1 );
mul_0 multiplier_2 (out_2, in_2_0, in_2_1 );
mul_0 multiplier_3 (out_3, in_3_0, in_3_1 );
mul_1 multiplier_4 (out_4, in_4_0, in_4_1 );
mul_1 multiplier_5 (out_5, in_5_0, in_5_1 );
mul_1 multiplier_6 (out_6, in_6_0, in_6_1 );
mul_0 multiplier_7 (out_7, in_7_0, in_7_1 );
mul_0 multiplier_8 (out_8, in_8_0, in_8_1 );
add_2 adder_9       (out_9, in_9_0, in_9_1 );
add_2 adder_10       (out_10, in_10_0, in_10_1 );
add_2 adder_11       (out_11, in_11_0, in_11_1 );
add_2 adder_12       (out_12, in_12_0, in_12_1 );
add_2 adder_13       (out_13, in_13_0, in_13_1 );
add_2 adder_14       (out_14, in_14_0, in_14_1 );
mul_1 multiplier_15 (out_15, in_15_0, in_15_1 );
mul_1 multiplier_16 (out_16, in_16_0, in_16_1 );
mul_1 multiplier_17 (out_17, in_17_0, in_17_1 );
mul_0 multiplier_18 (out_18, in_18_0, in_18_1 );
add_2 adder_19       (out_19, in_19_0, in_19_1 );
add_2 adder_20       (out_20, in_20_0, in_20_1 );
mul_0 multiplier_21 (out_21, in_21_0, in_21_1 );
mul_0 multiplier_22 (out_22, in_22_0, in_22_1 );
mul_1 multiplier_23 (out_23, in_23_0, in_23_1 );
mul_1 multiplier_24 (out_24, in_24_0, in_24_1 );
add_2 adder_25       (out_25, in_25_0, in_25_1 );
add_2 adder_26       (out_26, in_26_0, in_26_1 );
add_2 adder_27       (out_27, in_27_0, in_27_1 );
add_2 adder_28       (out_28, in_28_0, in_28_1 );
*/
/*****arf***ILP***10000****/
/*
mul_0 multiplier_1 (out_1, in_1_0, in_1_1 );
mul_0 multiplier_2 (out_2, in_2_0, in_2_1 );
mul_1 multiplier_3 (out_3, in_3_0, in_3_1 );
mul_1 multiplier_4 (out_4, in_4_0, in_4_1 );
mul_1 multiplier_5 (out_5, in_5_0, in_5_1 );
mul_1 multiplier_6 (out_6, in_6_0, in_6_1 );
mul_0 multiplier_7 (out_7, in_7_0, in_7_1 );
mul_0 multiplier_8 (out_8, in_8_0, in_8_1 );
add_2 adder_9       (out_9, in_9_0, in_9_1 );
add_2 adder_10       (out_10, in_10_0, in_10_1 );
add_2 adder_11       (out_11, in_11_0, in_11_1 );
add_2 adder_12       (out_12, in_12_0, in_12_1 );
add_2 adder_13       (out_13, in_13_0, in_13_1 );
add_2 adder_14       (out_14, in_14_0, in_14_1 );
mul_1 multiplier_15 (out_15, in_15_0, in_15_1 );
mul_1 multiplier_16 (out_16, in_16_0, in_16_1 );
mul_1 multiplier_17 (out_17, in_17_0, in_17_1 );
mul_1 multiplier_18 (out_18, in_18_0, in_18_1 );
add_2 adder_19       (out_19, in_19_0, in_19_1 );
add_2 adder_20       (out_20, in_20_0, in_20_1 );
mul_1 multiplier_21 (out_21, in_21_0, in_21_1 );
mul_0 multiplier_22 (out_22, in_22_0, in_22_1 );
mul_0 multiplier_23 (out_23, in_23_0, in_23_1 );
mul_1 multiplier_24 (out_24, in_24_0, in_24_1 );
add_2 adder_25       (out_25, in_25_0, in_25_1 );
add_2 adder_26       (out_26, in_26_0, in_26_1 );
add_2 adder_27       (out_27, in_27_0, in_27_1 );
add_2 adder_28       (out_28, in_28_0, in_28_1 );
*/

/*****arf***ILP**3000*****/
/*

mul_1 multiplier_1 (out_1, in_1_0, in_1_1 );
mul_1 multiplier_2 (out_2, in_2_0, in_2_1 );
mul_1 multiplier_3 (out_3, in_3_0, in_3_1 );
mul_1 multiplier_4 (out_4, in_4_0, in_4_1 );
mul_1 multiplier_5 (out_5, in_5_0, in_5_1 );
mul_1 multiplier_6 (out_6, in_6_0, in_6_1 );
mul_1 multiplier_7 (out_7, in_7_0, in_7_1 );
mul_1 multiplier_8 (out_8, in_8_0, in_8_1 );
add_2 adder_9       (out_9, in_9_0, in_9_1 );
add_2 adder_10       (out_10, in_10_0, in_10_1 );
add_2 adder_11       (out_11, in_11_0, in_11_1 );
add_2 adder_12       (out_12, in_12_0, in_12_1 );
add_2 adder_13       (out_13, in_13_0, in_13_1 );
add_2 adder_14       (out_14, in_14_0, in_14_1 );
mul_1 multiplier_15 (out_15, in_15_0, in_15_1 );
mul_1 multiplier_16 (out_16, in_16_0, in_16_1 );
mul_1 multiplier_17 (out_17, in_17_0, in_17_1 );
mul_1 multiplier_18 (out_18, in_18_0, in_18_1 );
add_2 adder_19       (out_19, in_19_0, in_19_1 );
add_2 adder_20       (out_20, in_20_0, in_20_1 );
mul_1 multiplier_21 (out_21, in_21_0, in_21_1 );
mul_1 multiplier_22 (out_22, in_22_0, in_22_1 );
mul_1 multiplier_23 (out_23, in_23_0, in_23_1 );
mul_1 multiplier_24 (out_24, in_24_0, in_24_1 );
add_2 adder_25       (out_25, in_25_0, in_25_1 );
add_2 adder_26       (out_26, in_26_0, in_26_1 );
add_2 adder_27       (out_27, in_27_0, in_27_1 );
add_2 adder_28       (out_28, in_28_0, in_28_1 );
*/






















/*
mul_1 multiplier_1 (out_1 , in_1_0 , in_1_1);
mul_1 multiplier_2 (out_2 , in_2_0 , in_2_1);
mul_x multiplier_3 (out_3 , in_3_0 , in_3_1);
mul_x multiplier_4 (out_4 , in_4_0 , in_4_1);
mul_x multiplier_5 (out_5 , in_5_0 , in_5_1);
mul_x multiplier_6 (out_6 , in_6_0 , in_6_1); 
mul_1 multiplier_7 (out_7 , in_7_0 , in_7_1); 
mul_1 multiplier_8 (out_8 , in_8_0 , in_8_1); 
add_1 adder_9      (out_9 , in_9_0 , in_9_1 );
add_2 adder_10     (out_10, in_10_0, in_10_1);
add_2 adder_11     (out_11, in_11_0, in_11_1);
add_1 adder_12     (out_12, in_12_0, in_12_1);
add_2 adder_13     (out_13, in_13_0, in_13_1);
add_2 adder_14     (out_14, in_14_0, in_14_1);
mul_x multiplier_15(out_15, in_15_0, in_15_1);
mul_x multiplier_16(out_16, in_16_0, in_16_1);
mul_x multiplier_17(out_17, in_17_0, in_17_1);
mul_x multiplier_18(out_18, in_18_0, in_18_1);
add_1 adder_19     (out_19, in_19_0, in_19_1);
add_2 adder_20     (out_20, in_20_0, in_20_1);
mul_1 multiplier_21(out_21, in_21_0, in_21_1);
mul_1 multiplier_22(out_22, in_22_0, in_22_1);
mul_1 multiplier_23(out_23, in_23_0, in_23_1);
mul_x multiplier_24(out_24, in_24_0, in_24_1);
add_1 adder_25     (out_25, in_25_0, in_25_1);
add_1 adder_26     (out_26, in_26_0, in_26_1);
add_2 adder_27     (out_27, in_27_0, in_27_1);
add_1 adder_28     (out_28, in_28_0, in_28_1);
*/
/* ILP 30000*/
/*
mul_0 multiplier_1 (out_1, in_1_0, in_1_1 );
mul_0 multiplier_2 (out_2, in_2_0, in_2_1 );
mul_1 multiplier_3 (out_3, in_3_0, in_3_1 );
mul_1 multiplier_4 (out_4, in_4_0, in_4_1 );
mul_1 multiplier_5 (out_5, in_5_0, in_5_1 );
mul_1 multiplier_6 (out_6, in_6_0, in_6_1 );
mul_0 multiplier_7 (out_7, in_7_0, in_7_1 );
mul_0 multiplier_8 (out_8, in_8_0, in_8_1 );
add_1 adder_9       (out_9, in_9_0, in_9_1 );
add_2 adder_10       (out_10, in_10_0, in_10_1 );
add_2 adder_11       (out_11, in_11_0, in_11_1 );
add_2 adder_12       (out_12, in_12_0, in_12_1 );
add_2 adder_13       (out_13, in_13_0, in_13_1 );
add_2 adder_14       (out_14, in_14_0, in_14_1 );
mul_1 multiplier_15 (out_15, in_15_0, in_15_1 );
mul_1 multiplier_16 (out_16, in_16_0, in_16_1 );
mul_0 multiplier_17 (out_17, in_17_0, in_17_1 );
mul_1 multiplier_18 (out_18, in_18_0, in_18_1 );
add_2 adder_19       (out_19, in_19_0, in_19_1 );
add_2 adder_20       (out_20, in_20_0, in_20_1 );
mul_0 multiplier_21 (out_21, in_21_0, in_21_1 );
mul_0 multiplier_22 (out_22, in_22_0, in_22_1 );
mul_0 multiplier_23 (out_23, in_23_0, in_23_1 );
mul_0 multiplier_24 (out_24, in_24_0, in_24_1 );
add_2 adder_25       (out_25, in_25_0, in_25_1 );
add_1 adder_26       (out_26, in_26_0, in_26_1 );
add_1 adder_27       (out_27, in_27_0, in_27_1 );
add_2 adder_28       (out_28, in_28_0, in_28_1 );
*/
/* KILS */
/*
mul_1 multiplier_1 (out_1, in_1_0, in_1_1 );
mul_1 multiplier_2 (out_2, in_2_0, in_2_1 );
mul_1 multiplier_3 (out_3, in_3_0, in_3_1 );
mul_1 multiplier_4 (out_4, in_4_0, in_4_1 );
mul_1 multiplier_5 (out_5, in_5_0, in_5_1 );
mul_1 multiplier_6 (out_6, in_6_0, in_6_1 );
mul_1 multiplier_7 (out_7, in_7_0, in_7_1 );
mul_1 multiplier_8 (out_8, in_8_0, in_8_1 );
add_2 adder_9      (out_9, in_9_0, in_9_1 );
add_2 adder_10      (out_10, in_10_0, in_10_1 );
add_2 adder_11      (out_11, in_11_0, in_11_1 );
add_2 adder_12      (out_12, in_12_0, in_12_1 );
add_2 adder_13      (out_13, in_13_0, in_13_1 );
add_2 adder_14      (out_14, in_14_0, in_14_1 );
mul_1 multiplier_15 (out_15, in_15_0, in_15_1 );
mul_1 multiplier_16 (out_16, in_16_0, in_16_1 );
mul_1 multiplier_17 (out_17, in_17_0, in_17_1 );
mul_1 multiplier_18 (out_18, in_18_0, in_18_1 );
add_2 adder_19      (out_19, in_19_0, in_19_1 );
add_2 adder_20      (out_20, in_20_0, in_20_1 );
mul_1 multiplier_21 (out_21, in_21_0, in_21_1 );
mul_1 multiplier_22 (out_22, in_22_0, in_22_1 );
mul_1 multiplier_23 (out_23, in_23_0, in_23_1 );
mul_1 multiplier_24 (out_24, in_24_0, in_24_1 );
add_2 adder_25      (out_25, in_25_0, in_25_1 );
add_2 adder_26      (out_26, in_26_0, in_26_1 );
add_2 adder_27      (out_27, in_27_0, in_27_1 );
add_2 adder_28      (out_28, in_28_0, in_28_1 );
*/
/*KLS*/
/*
mul_0 multiplier_1 (out_1, in_1_0, in_1_1  );
mul_0 multiplier_2 (out_2, in_2_0, in_2_1  );
mul_1 multiplier_3 (out_3, in_3_0, in_3_1  );
mul_1 multiplier_4 (out_4, in_4_0, in_4_1  );
mul_1 multiplier_5 (out_5, in_5_0, in_5_1  );
mul_1 multiplier_6 (out_6, in_6_0, in_6_1  );
mul_0 multiplier_7 (out_7, in_7_0, in_7_1  );
mul_0 multiplier_8 (out_8, in_8_0, in_8_1  );
add_1 adder_9      (out_9, in_9_0, in_9_1  );
add_2 adder_10      (out_10, in_10_0, in_10_1  );
add_2 adder_11      (out_11, in_11_0, in_11_1  );
add_1 adder_12      (out_12, in_12_0, in_12_1  );
add_2 adder_13      (out_13, in_13_0, in_13_1  );
add_2 adder_14      (out_14, in_14_0, in_14_1  );
mul_0 multiplier_15 (out_15, in_15_0, in_15_1  );
mul_1 multiplier_16 (out_16, in_16_0, in_16_1  );
mul_1 multiplier_17 (out_17, in_17_0, in_17_1  );
mul_1 multiplier_18 (out_18, in_18_0, in_18_1  );
add_2 adder_19      (out_19, in_19_0, in_19_1  );
add_2 adder_20      (out_20, in_20_0, in_20_1  );
mul_0 multiplier_21 (out_21, in_21_0, in_21_1  );
mul_0 multiplier_22 (out_22, in_22_0, in_22_1  );
mul_1 multiplier_23 (out_23, in_23_0, in_23_1  );
mul_1 multiplier_24 (out_24, in_24_0, in_24_1  );
add_1 adder_25      (out_25, in_25_0, in_25_1  );
add_2 adder_26      (out_26, in_26_0, in_26_1  );
add_2 adder_27      (out_27, in_27_0, in_27_1  );
add_2 adder_28      (out_28, in_28_0, in_28_1  );
*/
`include "edge.v"
`include "scalers.v"
endmodule
