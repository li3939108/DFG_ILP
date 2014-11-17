`include "interface.v"
`include "arf_variance.v"
`include "arf_accurate.v"

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

integer i, TESTSIZE;
real mean[2], variance[2], std[2];
longint signed error[2][], sum[2], result_sum;

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
	integer status ;
	TESTSIZE = 0;
	status = $value$plusargs("T=%d", TESTSIZE) ;
	#5;
	error[0] = new[TESTSIZE] ;
	error[1] = new[TESTSIZE] ;
	sum[0] = 0;
	sum[1] = 0;
	variance[0] = 0.0;
	variance[1] = 0.0;
	result_sum = 0;
end

initial begin
	integer input_width = 64 - 12 ;

	for(i = 0; i < TESTSIZE; i = i + 1 )begin
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
	
		error[0][i] = $signed(out_27_var) - $signed(out_27_acc) ;
		error[1][i] = $signed(out_28_var) - $signed(out_28_acc) ;
	
		sum[0] += error[0][i] ;
		sum[1] += error[1][i] ;

		$display ("%h, %h, %h, %h, %h, %h, %h, %h\n", in_1_0, in_2_0, in_3_0, in_4_0, in_5_0, in_6_0, in_7_0, in_8_0 ) ;
		#200
		$display("27_var: %d, 28_var: %d\n27_acc: %d, 28_acc: %d\ndiff:   %d,         %d\n"
		,$signed(out_27_var),$signed(out_28_var),$signed(out_27_acc),$signed(out_28_acc), $signed(out_27_var - out_27_acc), $signed(out_28_var - out_28_acc) );
	end
	#5;
	
	mean[0] = sum[0] / (TESTSIZE + 0.0) ;
	mean[1] = sum[1] / (TESTSIZE + 0.0) ;
	for (i = 0; i < TESTSIZE; i = i + 1) begin		
		variance[0] += ( ( error[0][i] - mean[0])**2) / (TESTSIZE + 0.0) ;
		variance[1] += ( ( error[1][i] - mean[1])**2) / (TESTSIZE + 0.0) ;
	end
	
	std[0] = variance[0]**(1.0 / 2.0) ;
	std[1] = variance[1]**(1.0 / 2.0) ;
	$display("variance:  %f\t\t%f\nmean:      %f\t\t%f\nstd:       %f\t\t%f\n", 
		variance[0], variance[1], mean[0], mean[1], std[0], std[1] );
end
endmodule
