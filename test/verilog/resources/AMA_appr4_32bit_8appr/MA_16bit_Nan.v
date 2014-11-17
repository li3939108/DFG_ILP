// Library - Design, Cell - MA_16bit_Nan, View - schematic
// LAST TIME SAVED: Nov 12 13:56:28 2014
// NETLIST TIME: Nov 14 21:02:11 2014
`timescale 1ns / 1ns 

module MA_16bit_Nan ( Cout, S, A, B, Cin );
output  Cout;

input  Cin;

output [15:0]  S;

input [15:0]  B;
input [15:0]  A;


specify 
    specparam CDS_LIBNAME  = "Design";
    specparam CDS_CELLNAME = "MA_16bit_Nan";
    specparam CDS_VIEWNAME = "schematic";
endspecify

MA_4bit_Nan I3 ( net28, S[3:0], A[3:0], B[3:0], Cin);
MA_4bit_Nan I2 ( net27, S[7:4], A[7:4], B[7:4], net28);
MA_4bit_Nan I1 ( net26, S[11:8], A[11:8], B[11:8], net27);
MA_4bit_Nan I0 ( Cout, S[15:12], A[15:12], B[15:12], net26);

endmodule
