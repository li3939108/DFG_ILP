`include "./Multiplier_appr_half.v"
`include "parameters.v"
module tb;
reg signed [15:0] in_0;
reg signed [15:0] in_1;
wire signed [31:0] out_intermediate ;
wire signed [31:0] out;
reg signed [63:0] precise_out;
wire  Cout ;

integer i, TESTSIZE;
real mean, variance, std, mean_result;
longint signed error[], sum, result_sum;

assign out = {{32{out_intermediate[31]}}, out_intermediate } >> `SHIFT_WIDTH;
Multiplier_appr_half appr0( 
	.out(out_intermediate), 
	.A(in_0), 
	.B(in_1) 
);

initial begin
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
	integer same = 0;
	integer r_seed = 200 ;
	$srandom(r_seed);
	for(i=0; i<TESTSIZE; i=i+1)begin
		/* High 16 bits as inputs*/
		in_0 = {$urandom(), $urandom()} >> (64-`INPUT_WIDTH);
		//in_1 = (  (~16'b0000_0000_0000_0011) + 1 ) << `SHIFT_WIDTH;
		//in_1 =   16'd3 << `SHIFT_WIDTH;
		//in_1 = $rtoi(-2.674941238280375028 * (2**`SHIFT_WIDTH)) ;
		in_1 = $rtoi(-1.93232* (2**`SHIFT_WIDTH)) ;
		#5;
		precise_out = {{16{in_0[15]}}, in_0[15:0]} * {{16{in_1[15]}}, in_1[15:0]} ;
		precise_out = {{32{precise_out[31]}}, precise_out[31:0]} >> `SHIFT_WIDTH ;
		error[i] = $signed(out) - $signed( precise_out[31:0] ) ;
		if(error[i] == 0)begin same += 1 ; end
		sum += error[i] ;
		result_sum += $signed(precise_out[31:0]) > 0 ? $signed(precise_out[31:0] ) : -$signed(precise_out[31:0]) ;
		$display("%d x %d \n", in_0, in_1) ;
		$display("Actual: %d\nAppr:   %d\nError:  %d\n", $signed( precise_out[31:0]) , $signed( out ), error[i]) ;
	end
	#5;
	mean = sum / (TESTSIZE + 0.0) ;
	for (i=0;i<TESTSIZE;i=i+1)begin
		variance += ( (error[i] - mean)**2)/( TESTSIZE+0.0) ;
	end
	std = variance**(1.0/2.0);
	mean_result = result_sum / (TESTSIZE + 0.0) ;
	$display("Mean:     %f(%f)\nVariance: %f\nStd:      %f(%f)\nResult:   %f\nER:       %f\n",
		mean, mean / mean_result, variance, std, std/mean_result, mean_result, (same + 0.0) / (TESTSIZE +0.0));

end

endmodule
