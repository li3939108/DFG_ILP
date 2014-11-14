module arf_variance(
	in_1_0,
	in_2_0,
	in_3_0,
	in_4_0,
	in_5_0,
	in_6_0,
	in_7_0,
	in_8_0,
	out_27,
	out_28);
input wire [15:0] 
	in_1_0,
	in_2_0,
	in_3_0,
	in_4_0,
	in_5_0,
	in_6_0,
	in_7_0,
	in_8_0;
output wire [63:0]
	out_27,out_28;
wire [15:0]
 in_1_1 ,
 in_2_1 ,
 in_3_1 ,
 in_4_1 ,
 in_5_1 ,
 in_6_1 ,
 in_7_1 ,
 in_8_1 ,
 in_15_0, in_15_1,               
 in_16_0, in_16_1,
 in_17_0, in_17_1,
 in_18_0, in_18_1,
 in_21_0, in_21_1,
 in_22_0, in_22_1,
 in_23_0, in_23_1,
 in_24_0, in_24_1;

wire [31:0]
out_1,
out_2,
out_3,
out_4,
out_5,
out_6,
out_7,
out_8,
out_15,
out_16,
out_17,
out_18,
out_21,
out_22,
out_23,
out_24;

wire [63:0]
in_9_1, 
in_10_1,
in_11_1,
in_12_1,
in_13_1,
in_14_1,
in_19_1,
in_20_1,
in_25_1,
in_26_1,
in_27_1,
in_28_1,
in_9_0, 
in_10_0,
in_11_0,
in_12_0,
in_13_0,
in_14_0,
in_19_0,
in_20_0,
in_25_0,
in_26_0,
in_27_0,
in_28_0,
out_9 ,
out_10,
out_11,
out_12,
out_13,
out_14,
out_19,
out_20,
out_25,
out_26
;

mul_0 multiplier_1 (out_1 , in_1_0 , in_1_1);
mul_0 multiplier_2 (out_2 , in_2_0 , in_2_1);
mul_0 multiplier_3 (out_3 , in_3_0 , in_3_1);
mul_0 multiplier_4 (out_4 , in_4_0 , in_4_1);
mul_0 multiplier_5 (out_5 , in_5_0 , in_5_1);
mul_1 multiplier_6 (out_6 , in_6_0 , in_6_1); 
mul_0 multiplier_7 (out_7 , in_7_0 , in_7_1); 
mul_0 multiplier_8 (out_8 , in_8_0 , in_8_1); 
add_0 adder_9      (out_9 , in_9_0 , in_9_1 );
add_1 adder_10     (out_10, in_10_0, in_10_1);
add_1 adder_11     (out_11, in_11_0, in_11_1);
add_0 adder_12     (out_12, in_12_0, in_12_1);
add_1 adder_13     (out_13, in_13_0, in_13_1);
add_1 adder_14     (out_14, in_14_0, in_14_1);
mul_0 multiplier_15(out_15, in_15_0, in_15_1);
mul_0 multiplier_16(out_16, in_16_0, in_16_1);
mul_0 multiplier_17(out_17, in_17_0, in_17_1);
mul_0 multiplier_18(out_18, in_18_0, in_18_1);
add_1 adder_19     (out_19, in_19_0, in_19_1);
add_1 adder_20     (out_20, in_20_0, in_20_1);
mul_0 multiplier_21(out_21, in_21_0, in_21_1);
mul_0 multiplier_22(out_22, in_22_0, in_22_1);
mul_0 multiplier_23(out_23, in_23_0, in_23_1);
mul_0 multiplier_24(out_24, in_24_0, in_24_1);
add_0 adder_25     (out_25, in_25_0, in_25_1);
add_0 adder_26     (out_26, in_26_0, in_26_1);
add_0 adder_27     (out_27, in_27_0, in_27_1);
add_1 adder_28     (out_28, in_28_0, in_28_1);


assign in_9_0  = {{32{out_1[15]}}, out_1};
assign in_9_1  = {{32{out_2[15]}}, out_2};
assign in_10_0 = {{32{out_3[15]}}, out_3};
assign in_10_1 = {{32{out_4[15]}}, out_4};
assign in_11_0 = {{32{out_5[15]}}, out_5};
assign in_11_1 = {{32{out_6[15]}}, out_6};
assign in_12_0 = {{32{out_7[15]}}, out_7};
assign in_12_1 = {{32{out_8[15]}}, out_8};
assign in_27_0 = out_9;
/* in_13_1 should be constant*/
assign in_13_0 = out_10;
/* in_14_1 should be constant*/
assign in_14_0 = out_11;
assign in_28_0 = out_12;
assign in_15_0 = out_13[15:0];
assign in_17_0 = out_13[15:0];
assign in_16_0 = out_14[15:0];
assign in_18_0 = out_14[15:0];
assign in_19_0 = {{32{out_15[15]}}, out_15};
assign in_19_1 = {{32{out_16[15]}}, out_16};
assign in_20_0 = {{32{out_17[15]}}, out_17};
assign in_20_1 = {{32{out_18[15]}}, out_18};
assign in_21_0 = out_19[15:0];
assign in_23_0 = out_19[15:0];
assign in_22_0 = out_20[15:0];
assign in_24_0 = out_20[15:0];
assign in_25_0 = {{32{out_21[15]}}, out_21};
assign in_25_1 = {{32{out_22[15]}}, out_22};
assign in_26_0 = {{32{out_23[15]}}, out_23};
assign in_26_1 = {{32{out_24[15]}}, out_24};
assign in_27_1 = out_25;
assign in_28_1 = out_26;

assign 	in_15_1 =   16'd3 ;
assign 	in_16_1 =   16'd3 ;
assign 	in_17_1 =   16'd3 ;	
assign 	in_18_1 =   16'd3 ;
assign 	in_21_1 = ~(16'd3) + 1 ;
assign 	in_22_1 = ~(16'd3) + 1 ;
assign 	in_23_1 = ~(16'd3) + 1 ;
assign 	in_24_1 =   16'd3 ;
	
assign 	in_1_1 =  16'd3 ;
assign 	in_2_1 =  16'd3 ;
assign 	in_3_1 =  16'd3 ;
assign 	in_4_1 =  16'd3 ;
assign 	in_5_1 =  16'd3 ;
assign 	in_6_1 =  16'd3 ;
assign 	in_7_1 =  16'd3 ;
assign 	in_8_1 =  16'd3 ;

endmodule
