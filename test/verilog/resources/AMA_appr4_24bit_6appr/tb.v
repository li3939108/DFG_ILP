`timescale 1ns / 1ns
`include "AMA_appr4_24bit_6appr.v"
`include "FA_X1.v"
`include "MA_4bit_Nan.v"
`include "MA_appr4_Nan.v"

module stimulus;
integer file;
reg [23:0] A;
reg [23:0] B;
reg Cin;
wire [23:0] SUM;
wire Cout;

AMA_appr4_24bit_6appr n1(Cout, SUM, A, B, Cin);

initial
begin
file = $fopen("result.txt","w");

#5 A=24'h135FAD; B=24'h8D683D; Cin=1'h1;
#5 A=24'hBAAC2A; B=24'h4EF295; Cin=1'h0;
#5 A=24'h3DD0FB; B=24'hB51E77; Cin=1'h1;
#5 A=24'hC934FC; B=24'h30D59A; Cin=1'h1;
#5 A=24'h1E6D76; B=24'h006F80; Cin=1'h0;

end

initial
$fmonitor(file,"A=%h, B=%h, Cin=%h, SUM=%h, Cout=%h",A, B, Cin, SUM, Cout);

endmodule
