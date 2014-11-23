// Library - Design, Cell - MA_4bit_Nan, View - schematic
// LAST TIME SAVED: Nov 12 13:51:11 2014
// NETLIST TIME: Nov 16 22:24:57 2014
`timescale 1ns / 1ns 

module MA_4bit_Nan ( Cout, S, A, B, Cin );
output  Cout;

input  Cin;

output [3:0]  S;

input [3:0]  A;
input [3:0]  B;


specify 
    specparam CDS_LIBNAME  = "Design";
    specparam CDS_CELLNAME = "MA_4bit_Nan";
    specparam CDS_VIEWNAME = "schematic";
endspecify

FA_X1 I3 ( A[0], B[0], Cin, net7, S[0]);
FA_X1 I2 ( A[1], B[1], net7, net8, S[1]);
FA_X1 I1 ( A[2], B[2], net8, net9, S[2]);
FA_X1 I0 ( A[3], B[3], net9, Cout, S[3]);

endmodule
