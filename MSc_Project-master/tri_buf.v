module tri_buf(
	tri_in,
	tri_out,
	tri_en,
	);
input wire tri_in, tri_en;
output wire tri_out;

assign tri_out = (tri_en)? tri_in:1'bz;

endmodule