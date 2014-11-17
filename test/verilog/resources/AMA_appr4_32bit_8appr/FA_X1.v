// Library - Design, Cell - MA_Nan, View - schematic
// LAST TIME SAVED: Nov 14 22:56:26 2014
// NETLIST TIME: Nov 14 22:56:48 2014
`timescale 1ns / 1ns 

module FA_X1 ( A, B, Cin, Cout, SUM );

supply1 Vdd;
supply0 GND;

output  Cout, SUM;

//inout  GND, Vdd;

input  A, B, Cin;


specify 
    specparam CDS_LIBNAME  = "Design";
    specparam CDS_CELLNAME = "FA_X1";
    specparam CDS_VIEWNAME = "schematic";
endspecify

pmos  M27 ( Cout, Vdd, cdsNet0);
pmos  M24 ( SUM, Vdd, net95);
pmos  M0 ( net90, Vdd, A);
pmos  M1 ( net90, Vdd, B);
pmos  M2 ( net117, Vdd, B);
pmos  M3 ( cdsNet0, net90, Cin);
pmos  M4 ( cdsNet0, net117, A);
pmos  M5 ( net96, Vdd, A);
pmos  M6 ( net96, Vdd, B);
pmos  M7 ( net96, Vdd, Cin);
pmos  M8 ( net95, net96, cdsNet0);
pmos  M9 ( net119, Vdd, A);
pmos  M10 ( net118, net119, B);
pmos  M11 ( net95, net118, Cin);
nmos  M25 ( SUM, GND, net95);
nmos  M26 ( Cout, GND, cdsNet0);
nmos  M12 ( cdsNet0, net88, Cin);
nmos  M13 ( cdsNet0, net116, A);
nmos  M14 ( net88, GND, A);
nmos  M15 ( net88, GND, B);
nmos  M16 ( net116, GND, B);
nmos  M17 ( net95, net94, cdsNet0);
nmos  M18 ( net94, GND, B);
nmos  M19 ( net94, GND, Cin);
nmos  M20 ( net94, GND, A);
nmos  M21 ( net95, net120, Cin);
nmos  M22 ( net120, net121, A);
nmos  M23 ( net121, GND, B);

endmodule
