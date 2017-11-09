module rca(
//	port_in,
//	port_out,
	req,
	grant
	);

input wire [15:0] req;
output wire [15:0] grant;
wire [15:0] h;
wire [15:0] v;
genvar i;
generate
	for(i=0; i<16; i= i+1) begin: connection
		if (i==0) begin
			arbiter arbiter(
				.north(1),
				.west(1),
				.south(v[i]),
				.east(h[i]),
				.request(req[i]),
				.grant(grant[i])
				);
		end // if (i<4)
		else if(i == 1 || i==2 || i==3)
			begin
			arbiter arbiter(
				.north(1),
				.west(h[i-1]),
				.south(v[i]),
				.east(h[i]),
				.request(req[i]),
				.grant(grant[i])
				);
			end
		else if (i==4 || i==8 || i==12) begin
			arbiter arbiter(
				.north(v[i-4]),
				.west(1),
				.south(v[i]),
				.east(h[i]),
				.request(req[i]),
				.grant(grant[i])
				);
			end
		else begin
			arbiter arbiter(
				.north(v[i-4]),
				.west(h[i-1]),
				.south(v[i]),
				.east(h[i]),
				.request(req[i]),
				.grant(grant[i])
				);
		end
	end
endgenerate
endmodule