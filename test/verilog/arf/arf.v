`include "interface.v"
`include "arf_variance.v"
`include "arf_accurate.v"
`define TEST_SIZE 100

module arf();

wire [31:0] out_27_var, out_27_acc, out_28_var, out_28_acc;

	reg [31:0] a = ~(32'd3) + 32'b1 ;
	reg [31:0] b ;
reg [31:0] 
	in_1_0,
        in_2_0,
        in_3_0,
        in_4_0,
        in_5_0,
        in_6_0,
        in_7_0,
        in_8_0;
reg [31:0]
	in_13_1, in_14_1;


arf_variance arf0(
	in_1_0,
	in_2_0,
	in_3_0,
	in_4_0,
	in_5_0,
	in_6_0,
	in_7_0,
	in_8_0,
	in_13_1,
	in_14_1,
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
	in_13_1,
	in_14_1,
	out_27_acc,
	out_28_acc);

initial begin
	integer r_seed = 200 ;
	integer tmp = $urandom(r_seed);
	integer i ;
	integer input_width = 64 - 12 ;
	assign b = 32'b1101 * a ;
	$display("%h x %h = %h\n",a, 32'b1101,  b) ;
	for(i = 0; i < `TEST_SIZE; i = i + 1 )begin
		in_1_0 = {$urandom(),$urandom()} >> input_width;
		in_2_0 = {$urandom(),$urandom()} >> input_width;
		in_3_0 = {$urandom(),$urandom()} >> input_width;
		in_4_0 = {$urandom(),$urandom()} >> input_width;
		in_5_0 = {$urandom(),$urandom()} >> input_width;
		in_6_0 = {$urandom(),$urandom()} >> input_width;
		in_7_0 = {$urandom(),$urandom()} >> input_width;
		in_8_0 = {$urandom(),$urandom()} >> input_width;
		in_13_1 = {$urandom(), $urandom()} >> input_width;
		in_14_1 = {$urandom(), $urandom()} >> input_width;
		$display ("%h, %h, %h, %h, %h, %h, %h, %h\n", in_1_0, in_2_0, in_3_0, in_4_0, in_5_0, in_6_0, in_7_0, in_8_0 ) ;
		#200
		$display("27_var: %d, 28_var: %d\n27_acc: %d, 28_acc: %d\ndiff:   %d,         %d\n"
		,$signed(out_27_var),$signed(out_28_var),$signed(out_27_acc),$signed(out_28_acc), $signed(out_27_var - out_27_acc), $signed(out_28_var - out_28_acc) );
	end
end
endmodule
