// Library - Design, Cell - MA_appr4_Nan, View - schematic
// LAST TIME SAVED: Nov 14 20:30:24 2014
// NETLIST TIME: Nov 14 21:02:11 2014
`ifndef __MA_APPR4_NAN_V__
`define __MA_APPR4_NAN_V__

`timescale 1ns / 1ns 

module MA_appr4_Nan ( Cout, SUM, GND, Vdd, A, B, Cin );

output  Cout, SUM;

inout  GND, Vdd;

input  A, B, Cin;


specify 
    specparam CDS_LIBNAME  = "Design";
    specparam CDS_CELLNAME = "MA_appr4_Nan";
    specparam CDS_VIEWNAME = "schematic";
endspecify

pmos  M14 ( SUM, Vdd, cdsNet0);
pmos  M11 ( Cout, Vdd, cdsNet1);
pmos  M0 ( cdsNet1, Vdd, A);
pmos  M1 ( net57, Vdd, A);
pmos  M2 ( net57, Vdd, B);
pmos  M3 ( cdsNet0, net57, cdsNet1);
pmos  M4 ( cdsNet0, Vdd, Cin);
nmos  M12 ( Cout, GND, cdsNet1);
nmos  M13 ( SUM, GND, cdsNet0);
nmos  M5 ( cdsNet1, GND, A);
nmos  M6 ( cdsNet0, net72, cdsNet1);
nmos  M7 ( net72, GND, Cin);
nmos  M8 ( cdsNet0, net73, Cin);
nmos  M9 ( net73, net74, B);
nmos  M10 ( net74, GND, A);

endmodule

`endif
