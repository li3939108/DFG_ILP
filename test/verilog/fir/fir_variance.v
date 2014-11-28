module fir_variance(
	in_1_0,
	in_2_0,
	in_3_0,
	in_4_0,
	in_5_0,
	in_6_0,
	out_11);
`include "declarations.v"
mul_1 multiplier_1 ( out_1,  in_1_0,  in_1[1 ]);
mul_1 multiplier_2 ( out_2,  in_2_0,  in_1[2 ]);
mul_1 multiplier_3 ( out_3,  in_3_0,  in_1[3 ]);
mul_1 multiplier_4 ( out_4,  in_4_0,  in_1[4 ]);
mul_1 multiplier_5 ( out_5,  in_5_0,  in_1[5 ]);
mul_1 multiplier_6 ( out_6,  in_6_0,  in_1[6 ]);
add_2 adder_7      ( out_7 , in_7_0,  in_7_1  );
add_2 adder_8      ( out_8 , in_8_0,  in_8_1  );
add_2 adder_9      ( out_9 , in_9_0,  in_9_1  );
add_2 adder_10     ( out_10, in_10_0, in_10_1 );
add_2 adder_11     ( out_11, in_11_0, in_11_1 );

`include "edge.v"
`include "scalers.v"
endmodule
