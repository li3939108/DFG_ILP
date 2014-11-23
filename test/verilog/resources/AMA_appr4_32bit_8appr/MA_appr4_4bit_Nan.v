`timescale 1ns / 1ns 

module MA_appr4_4bit_Nan ( Cout, S, GND, Vdd, A, B, Cin );

output  Cout;

inout  GND, Vdd;

input  Cin;

output [3:0]  S;

input [3:0]  B;
input [3:0]  A;


specify 
    specparam CDS_LIBNAME  = "Design";
    specparam CDS_CELLNAME = "MA_appr4_4bit_Nan";
    specparam CDS_VIEWNAME = "schematic";
endspecify

MA_appr4_Nan I3 ( net32, S[0], GND, Vdd, A[0], B[0], Cin);
MA_appr4_Nan I2 ( net31, S[1], GND, Vdd, A[1], B[1], net32);
MA_appr4_Nan I1 ( net30, S[2], GND, Vdd, A[2], B[2], net31);
MA_appr4_Nan I0 ( Cout, S[3], GND, Vdd, A[3], B[3], net30);

endmodule
