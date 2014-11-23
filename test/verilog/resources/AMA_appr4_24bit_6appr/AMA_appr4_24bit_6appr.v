// Library - Design, Cell - AMA_appr4_24bit_6appr, View - schematic
// LAST TIME SAVED: Nov 16 22:24:34 2014
// NETLIST TIME: Nov 16 22:24:57 2014
`timescale 1ns / 1ns 

module AMA_appr4_24bit_6appr ( Cout, S, A, B, Cin );

supply1 Vdd;
supply0 GND;

output  Cout;

input  Cin;

output [23:0]  S;

input [23:0]  A;
input [23:0]  B;


specify 
    specparam CDS_LIBNAME  = "Design";
    specparam CDS_CELLNAME = "AMA_appr4_24bit_6appr";
    specparam CDS_VIEWNAME = "schematic";
endspecify

MA_4bit_Nan I2 ( Cout, S[23:20], A[23:20], B[23:20], net8);
MA_4bit_Nan I1 ( net14, S[11:8], A[11:8], B[11:8], net13);
MA_4bit_Nan I0 ( net15, S[15:12], A[15:12], B[15:12], net14);
MA_4bit_Nan I7 ( net8, S[19:16], A[19:16], B[19:16], net15);
FA_X1 I5 ( A[6], B[6], net17, net04, S[6]);
FA_X1 I4 ( A[7], B[7], net04, net13, S[7]);
MA_appr4_Nan I12 ( net18, S[4], GND, Vdd,
     A[4], B[4], net12);
MA_appr4_Nan I13 ( net12, S[3], GND, Vdd,
     A[3], B[3], net11);
MA_appr4_Nan I14 ( net11, S[2], GND, Vdd,
     A[2], B[2], net10);
MA_appr4_Nan I15 ( net10, S[1], GND, Vdd,
     A[1], B[1], net9);
MA_appr4_Nan I16 ( net9, S[0], GND, Vdd,
     A[0], B[0], Cin);
MA_appr4_Nan I3 ( net17, S[5], GND, Vdd,
     A[5], B[5], net18);

endmodule
