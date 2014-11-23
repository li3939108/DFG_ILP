// Library - Design, Cell - AMA_appr4_28bit_7appr, View - schematic
// LAST TIME SAVED: Nov 16 22:26:06 2014
// NETLIST TIME: Nov 16 22:26:37 2014
`timescale 1ns / 1ns 

module AMA_appr4_28bit_7appr ( Cout, S, A, B, Cin );

supply1 Vdd;
supply0 GND;

output  Cout;

input  Cin;

output [27:0]  S;

input [27:0]  B;
input [27:0]  A;


specify 
    specparam CDS_LIBNAME  = "Design";
    specparam CDS_CELLNAME = "AMA_appr4_28bit_7appr";
    specparam CDS_VIEWNAME = "schematic";
endspecify

MA_4bit_Nan I4 ( Cout, S[27:24], A[27:24], B[27:24], net8);
MA_4bit_Nan I7 ( net19, S[19:16], A[19:16], B[19:16], net12);
MA_4bit_Nan I0 ( net12, S[15:12], A[15:12], B[15:12], net13);
MA_4bit_Nan I1 ( net13, S[11:8], A[11:8], B[11:8], net14);
MA_4bit_Nan I2 ( net8, S[23:20], A[23:20], B[23:20], net19);
FA_X1 I6 ( A[7], B[7], net11, net14, S[7]);
MA_appr4_Nan I16 ( net18, S[0], GND, Vdd,
     A[0], B[0], Cin);
MA_appr4_Nan I15 ( net17, S[1], GND, Vdd,
     A[1], B[1], net18);
MA_appr4_Nan I14 ( net16, S[2], GND, Vdd,
     A[2], B[2], net17);
MA_appr4_Nan I13 ( net15, S[3], GND, Vdd,
     A[3], B[3], net16);
MA_appr4_Nan I12 ( net9, S[4], GND, Vdd,
     A[4], B[4], net15);
MA_appr4_Nan I3 ( net10, S[5], GND, Vdd,
     A[5], B[5], net9);
MA_appr4_Nan I5 ( net11, S[6], GND, Vdd,
     A[6], B[6], net10);

endmodule
