`ifndef __CELL_V__
`define __CELL_V__


module cell(s_o, e_o, a, b, al, bl);
	input a, b, al, bl;
	output s_o, e_o;

	wire conn1, conn2;

	assign conn1 = ~(a ^ b), conn2 = ~(al & bl);
	assign s_o = ~(conn1 & conn2), e_o = ~(conn1 | conn2);

endmodule

`endif
