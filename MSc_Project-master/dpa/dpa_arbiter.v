module dpa_arbiter(
	north,
	west,
	south,
	east,
	request,
	grant,
	mask
	);

input wire north, request, west, mask;
output wire south, grant, east;

assign grant = north & west & mask & request;
assign south = (north & ~grant) | ~mask;
assign east  = (west  & ~grant) | ~mask;

endmodule // dpa_arbiter