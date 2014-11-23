module tb28;

`define BIT_WIDTH 28
`define INPUT_WIDTH 19

reg  signed [31: 0] in_0;
reg  signed [31: 0] in_1;
wire signed [31: 0] out ;

wire  Cout ;

integer i, TESTSIZE;
real mean, variance, std, mean_result;
longint signed error[], sum, result_sum;



assign out[31:32 - `BIT_WIDTH] = in_0[31:32 - `BIT_WIDTH] + in_1[31:32 - `BIT_WIDTH] ;
assign out[32 - `BIT_WIDTH - 1:0] = 0;

initial begin
	integer r_seed = 23232 ;
	integer tmp = $urandom(r_seed);
	integer status ;
	TESTSIZE = 0;
	status = $value$plusargs("T=%d", TESTSIZE) ;
	#5;
	error = new[TESTSIZE] ;
	sum = 0;
	variance = 0;
	result_sum = 0;
end
initial begin
	for(i=0; i<TESTSIZE; i=i+1)begin
		in_0 = $urandom()>> (32 - `INPUT_WIDTH);
		in_1 = $urandom()>> (32 - `INPUT_WIDTH);
		#5;
		error[i] = $signed(out) - $signed( in_0 + in_1 ) ;
		sum += error[i] ;
		result_sum += $signed(in_0 + in_1);
		$display("Actual: %d\nAppr:   %d\nError:  %d\n", in_0 + in_1, out, error[i]) ;
	end
	#5;
	mean = sum / (TESTSIZE + 0.0) ;
	for (i=0;i<TESTSIZE;i=i+1)begin
		variance += ( (error[i] - mean)**2)/( TESTSIZE+0.0) ;
	end
	std = variance**(1.0/2.0);
	mean_result = result_sum/ (TESTSIZE + 0.0) ;
	$display("Mean:     %f(%f)\nVariance: %f\nStd:      %f(%f)\nResult:   %f\n", 
		mean, mean / mean_result, variance, std, std/mean_result, mean_result);

end

endmodule
