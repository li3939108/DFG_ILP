
`include "interface.v"
`include "arf_variance.v"
`include "arf_accurate.v"

module arf();

wire [63:0] out_27_var, out_27_acc, out_28_var, out_28_acc;

reg [15:0] 
	in_1_0,
        in_2_0,
        in_3_0,
        in_4_0,
        in_5_0,
        in_6_0,
        in_7_0,
        in_8_0;


arf_variance arf0(
	in_1_0,
	in_2_0,
	in_3_0,
	in_4_0,
	in_5_0,
	in_6_0,
	in_7_0,
	in_8_0,
	out_27_var,
	out_28_var);
arf_accurate arf1(
	in_1_0,
	in_2_0,
	in_3_0,
	in_4_0,
	in_5_0,
	in_6_0,
	in_7_0,
	in_8_0,
	out_27_acc,
	out_28_acc);

initial begin
	integer r_seed = 200 ;
	integer tmp = $urandom(r_seed);
	in_1_0 = {$urandom(),$urandom()} >> 48;
	in_2_0 = {$urandom(),$urandom()} >> 48;
	in_3_0 = {$urandom(),$urandom()} >> 48;
	in_4_0 = {$urandom(),$urandom()} >> 48;
	in_5_0 = {$urandom(),$urandom()} >> 48;
	in_6_0 = {$urandom(),$urandom()} >> 48;
	in_7_0 = {$urandom(),$urandom()} >> 48;
	in_8_0 = {$urandom(),$urandom()} >> 48;
	//$display ("%d, %d, %d, %d, %d, %d, %d, %d\n", in_1_0, in_2_0, in_3_0, in_4_0, in_5_0, in_6_0, in_7_0, in_8_0 ) ;

	//$display("27_var: %d, 28_var: %d\n27_acc: %d, 28_acc: %d\n",out_27_var,out_28_var,out_27_acc,out_28_acc);
end
endmodule
