`timescale 1ns / 1ns 

module MA_appr4_8bit_Nan ( Cout, S, GND, Vdd, A, B, Cin );

output  Cout;

inout  GND, Vdd;

input  Cin;

output [7:0]  S;

input [7:0]  B;
input [7:0]  A;


specify 
    specparam CDS_LIBNAME  = "Design";
    specparam CDS_CELLNAME = "MA_appr4_8bit_Nan";
    specparam CDS_VIEWNAME = "schematic";
endspecify

MA_appr4_4bit_Nan I3 ( net18, S[3:0], GND, Vdd, A[3:0], B[3:0], Cin);
MA_appr4_4bit_Nan I2 ( Cout, S[7:4], GND, Vdd, A[7:4], B[7:4], net18);

endmodule
