`include "interface.v"
module fir;


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
		in_1_0 = {$urandom(),$urandom()} >> input_width;
		in_2_0 = {$urandom(),$urandom()} >> input_width;
		in_3_0 = {$urandom(),$urandom()} >> input_width;
		in_4_0 = {$urandom(),$urandom()} >> input_width;
		in_5_0 = {$urandom(),$urandom()} >> input_width;
		in_6_0 = {$urandom(),$urandom()} >> input_width;
		
		$display("%d \n", out_11);
	end
end

endmodule
