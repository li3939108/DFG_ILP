`include "fir_accurate.v"
module fir;

reg signed [31:0] 
	in_1_0,	
        in_2_0,
        in_3_0,
        in_4_0,
        in_5_0,
        in_6_0;
wire signed [31:0] 
	out_11;


integer i, TESTSIZE;
real 
	mean       , 
	variance   , 
	std        , 
	mean_result
;
longint signed 
	error[], 
	sum, 
	result_sum;


fir_accurate fir0(
	.in_1_0(in_1_0),
	.in_2_0(in_2_0),
	.in_3_0(in_3_0),
	.in_4_0(in_4_0),
	.in_5_0(in_5_0),
	.in_6_0(in_6_0),
	.out_11(out_11));



initial begin
	integer r_seed = 200 ;
	integer tmp = $urandom(r_seed);
	integer status ;
	TESTSIZE = 0;
	status = $value$plusargs("T=%d", TESTSIZE) ;
	#5;
	error = new[TESTSIZE] ;
	sum = 0;
	variance = 0.0;
	result_sum = 0;
end


initial begin
	integer input_width = 64 - 12 ;

	for(i = 0; i < TESTSIZE; i = i + 1 )begin
		in_6_0 = in_5_0 ;
		in_5_0 = in_4_0 ;
		in_4_0 = in_3_0 ;
		in_3_0 = in_2_0 ;
		in_2_0 = in_1_0 ;
		in_1_0 = {$urandom(),$urandom()} >> input_width;
		#5;
		$display("%d %d\n", out_11, in_1_0);
	end
end

endmodule
