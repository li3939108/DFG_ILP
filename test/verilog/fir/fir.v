`include "interface.v"
`include "fir_accurate.v"
`include "fir_variance.v"
module fir;

reg signed [31:0] 
	in_1_0,	
        in_2_0,
        in_3_0,
        in_4_0,
        in_5_0,
        in_6_0;
wire signed [31:0] 
	out_11_0, out_11_1, out_11_0_int;


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


fir_variance fir0(
	.in_1_0(in_1_0),
	.in_2_0(in_2_0),
	.in_3_0(in_3_0),
	.in_4_0(in_4_0),
	.in_5_0(in_5_0),
	.in_6_0(in_6_0),
	.out_11(out_11_0));
//assign out_11_0 = out_11_0_int + 32'd700;

fir_accurate fir1(
	.in_1_0(in_1_0),
	.in_2_0(in_2_0),
	.in_3_0(in_3_0),
	.in_4_0(in_4_0),
	.in_5_0(in_5_0),
	.in_6_0(in_6_0),
	.out_11(out_11_1));



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
		error[i] = $signed(out_11_0) - $signed(out_11_1) ;
		
		sum += error[i] ;

		result_sum += ($signed(out_11_1) > 0 ? out_11_1 : -out_11_1);

		$display("appr:   %d\naccu:   %d\ndiff:   %d(%f)\n", 
			out_11_0, 
			out_11_1,
			error[i],
			error[i] / (out_11_1 + 0.0) );
	end
	mean = sum / (TESTSIZE + 0.0) ;

	for (i = 0; i < TESTSIZE; i = i + 1) begin		
		variance += ( ( error[i] - mean)**2) / (TESTSIZE + 0.0);
	end
	std = variance ** (1.0/2.0) ;
	mean_result = result_sum / (TESTSIZE + 0.0);
	$display("variance:  %f\nmean:      %f(%f)\nstd:       %f(%f)\nresult:    %f\n", 
		variance, mean, mean/mean_result, std, std / mean_result, mean_result );

end

endmodule
