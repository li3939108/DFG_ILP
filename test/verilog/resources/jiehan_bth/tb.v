`include "./Multiplier_appr.v"
module tb;
reg signed [15:0] in_0;
reg signed [15:0] in_1;
wire signed [31:0] out_intermediate ;
wire signed [31:0] out;
reg signed [63:0] precise_out;
wire  Cout ;

integer i, TESTSIZE;
real mean, variance, std;
longint signed error[], sum, result_sum;

assign out = {{32{out_intermediate[31]}}, out_intermediate } >> 12;
Multiplier_appr appr0( 
	.out(out_intermediate), 
	.A(in_0), 
	.B(in_1) 
);

initial begin
	integer r_seed = 200 ;
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
		/* High 16 bits as inputs*/
		in_0 = $urandom()>>16;
		in_1 = 16'b0000_0000_0000_0011 << 12;
		#5;
		precise_out = {{16{in_0[15]}}, in_0[15:0]} * {{16{in_1[15]}}, in_1[15:0]} ;
		precise_out = precise_out >> 12 ;
		error[i] = $signed(out) - $signed( precise_out[31:0] ) ;
		sum += error[i] ;
		$display("%d x %d \n", in_0, in_1) ;
		$display("Actual: %d\nAppr:   %d\nError:  %d\n", $signed( precise_out[31:0]) , $signed( out ), error[i]) ;
	end
	#5;
	mean = sum / (TESTSIZE + 0.0) ;
	for (i=0;i<TESTSIZE;i=i+1)begin
		variance += ( (error[i] - mean)**2)/( TESTSIZE+0.0) ;
	end
	std = variance**(1.0/2.0);
	$display("Mean:     %f\nVariance: %f\nStd:      %f\n", mean, variance, std );

end

endmodule
