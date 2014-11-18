`include "interface.v"
module fir(
	in_1_0,
	in_2_0,
	in_3_0,
	in_4_0,
	in_5_0,
	in_6_0,
	out_11);

output wire signed [31:0]
	out_11 ;
input wire signed [31:0] 
	in_1_0,	
        in_2_0,
        in_3_0,
        in_4_0,
        in_5_0,
        in_6_0;


wire signed [31:0] 
	out_1, 
        out_2, 
        out_3, 
        out_4, 
        out_5, 
        out_6, 
        out_7  ,
        out_8  ,
        out_9  ,
        out_10 ,
	in_7_0 , 
        in_8_0 , 
        in_9_0 , 
        in_10_0,
        in_11_0,
	in_7_1 ,
        in_8_1 ,
        in_9_1 ,
        in_10_1,
        in_11_1
;
wire signed [31:0]  in_1[7] ;
integer i;
real b[7] = '{0,-0.0674941238280375028,0.284167081434158086,0.444244237876052828,
	0.444244237876052828,0.284167081434158086,-0.0674941238280375028}; 


mul_1 multiplier_1 ( out_1,  in_1_0,  in_1[1 ]);
mul_1 multiplier_2 ( out_2,  in_2_0,  in_1[2 ]);
mul_1 multiplier_3 ( out_3,  in_3_0,  in_1[3 ]);
mul_1 multiplier_4 ( out_4,  in_4_0,  in_1[4 ]);
mul_1 multiplier_5 ( out_5,  in_5_0,  in_1[5 ]);
mul_1 multiplier_6 ( out_6,  in_6_0,  in_1[6 ]);
add_1 adder_7      ( out_7 , in_7_0,  in_7_1  );
add_1 adder_8      ( out_8 , in_8_0,  in_8_1  );
add_1 adder_9      ( out_9 , in_9_0,  in_9_1  );
add_1 adder_10     ( out_10, in_10_0, in_10_1 );
add_1 adder_11     ( out_11, in_11_0, in_11_1 );


assign in_7_0 = out_1 ;
assign in_7_1 = out_2 ;
assign in_8_0 = out_7 ;
assign in_8_1 = out_3 ;
assign in_9_0 = out_8 ;
assign in_9_1 = out_4 ;
assign in_10_0= out_9 ;
assign in_10_1= out_5 ;
assign in_11_0= out_10;
assign in_11_1= out_6 ; 

assign in_1[0] = 32'b0;
assign in_1[1] = $rtoi(b[1] * (2**12)) ;
assign in_1[2] = $rtoi(b[2] * (2**12)) ;
assign in_1[3] = $rtoi(b[3] * (2**12)) ;
assign in_1[4] = $rtoi(b[4] * (2**12)) ;
assign in_1[5] = $rtoi(b[5] * (2**12)) ;
assign in_1[6] = $rtoi(b[6] * (2**12)) ;

initial begin

end

endmodule
