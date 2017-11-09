// themal decoder
module thermal_dec (
	in,
	out
	);
parameter N = 4;
input wire [$clog2(N)-1:0] in;
output wire [N-1:0] out;
wire [N-1:0] n = {N{1'b1}};
assign out = n >> (N - in);
endmodule