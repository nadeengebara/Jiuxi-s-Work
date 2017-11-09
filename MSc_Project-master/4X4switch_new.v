module switch(
port_tx,
port_rx,
sel
);

input [3:0] port_tx;
input [7:0] sel;
output wire [3:0] port_rx;

wire [15:0] mid;

genvar i,j;
generate
	for (i = 0; i<4; i= i+1) begin: connection
		assign mid[4*i + 3] = port_tx[i]; 
		assign mid[4*i + 2] = port_tx[i];
		assign mid[4*i + 1] = port_tx[i];
		assign mid[4*i    ] = port_tx[i];
/*
		demux #(4, $clog2(4)) dmu(
			.demux_din(port_tx[i]),
			.demux_dout({mid[4*i + 3], mid[4*i + 2], mid[4*i + 1], mid[4*i]}),
			.demux_sel(sel[4*i + 1 : 4*i])
		);
*/
	end
	for (j = 0; j < 4; j = j+1) begin: multiplxer
		mux #(4, $clog2(4)) mu(
			.mux_dout(port_rx[j]),
			.mux_din({mid[j+12], mid[j+8], mid[j+4], mid[j]}),
			.mux_sel(sel[2*j+1 : 2*j])
		);
	end
endgenerate
/*
demux du0(
.demux_din(port_tx[0]),
.demux_dout({mid[3], mid[2], mid[1], mid[0]}),
.demux_sel(sel[1:0])
);
mux u0(
.mux_dout(port_rx[0]),
.mux_din({mid[12], mid[8], mid[4], mid[0]}),
.mux_sel(sel[3:2])
);
////////////////
demux du1(
.demux_din(port_tx[1]),
.demux_dout({mid[7], mid[6], mid[5], mid[4]}),
.demux_sel(sel[5:4])
);

mux u1(
.mux_dout(port_rx[1]),
.mux_din({mid[13], mid[9], mid[5], mid[1]}),
.mux_sel(sel[7:6])
);

////////////////
demux du2(
.demux_din(port_tx[2]),
.demux_dout({mid[11], mid[10], mid[9], mid[8]}),
.demux_sel(sel[9:8])
);

mux u2(
.mux_dout(port_rx[2]),
.mux_din({mid[14], mid[10], mid[6], mid[2]}),
.mux_sel(sel[11:10])
);

////////////////
demux du3(
.demux_din(port_tx[3]),
.demux_dout({mid[15], mid[14], mid[13], mid[12]}),
.demux_sel(sel[13:12])
);

mux u3(
.mux_dout(port_rx[3]),
.mux_din({mid[15], mid[11], mid[7], mid[3]}),
.mux_sel(sel[15:14])
);
////////////////
*/

endmodule
