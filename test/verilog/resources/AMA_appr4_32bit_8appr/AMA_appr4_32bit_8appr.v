// Library - Design, Cell - AMA_appr4_32bit_8appr, View - schematic
// LAST TIME SAVED: Nov 14 20:55:28 2014
// NETLIST TIME: Nov 14 21:02:11 2014
`timescale 1ns / 1ns 
`include "../common/FA_X1.v"
`include "../common/MA_appr4_Nan.v"
`include "MA_appr4_4bit_Nan.v"
`include "../common/MA_4bit_Nan.v"
`include "MA_16bit_Nan.v"
`include "MA_appr4_8bit_Nan.v"

module AMA_appr4_32bit_8appr ( Cout, S, A, B, Cin );

supply1 Vdd;
supply0 GND;

output  Cout;

input  Cin;

output [31:0]  S;

input [31:0]  B;
input [31:0]  A;


specify 
    specparam CDS_LIBNAME  = "Design";
    specparam CDS_CELLNAME = "AMA_appr4_32bit_8appr";
    specparam CDS_VIEWNAME = "schematic";
endspecify

MA_16bit_Nan I0 ( Cout, S[31:16], A[31:16], B[31:16], net11);
MA_4bit_Nan I2 ( net12, S[11:8], A[11:8], B[11:8], net7);
MA_4bit_Nan I1 ( net11, S[15:12], A[15:12], B[15:12], net12);
MA_appr4_8bit_Nan I3 ( net7, S[7:0], GND,
     Vdd, A[7:0], B[7:0], Cin);

endmodule
