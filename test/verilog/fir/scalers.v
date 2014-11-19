`include "parameters.v"

assign in_1[0] = 32'b0;
assign in_1[1] = $rtoi(b[1] * (2**`SHIFT_WIDTH)) ;
assign in_1[2] = $rtoi(b[2] * (2**`SHIFT_WIDTH)) ;
assign in_1[3] = $rtoi(b[3] * (2**`SHIFT_WIDTH)) ;
assign in_1[4] = $rtoi(b[4] * (2**`SHIFT_WIDTH)) ;
assign in_1[5] = $rtoi(b[5] * (2**`SHIFT_WIDTH)) ;
assign in_1[6] = $rtoi(b[6] * (2**`SHIFT_WIDTH)) ;


