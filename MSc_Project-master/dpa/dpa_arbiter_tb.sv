module dpa_arbiter_tb;

wire [3:0][3:0]request;
wire [3:0]mask[5];
logic [3:0]m0;
assign mask[0] = m0;
wire [3:0][3:0]grant;

dpa_arbiter #(4) a (
	.request(request),
	.grant(grant),
	.mask(mask)
	);

genvar j,k;
generate

	for(j=0; j<4; j=j+1) begin
		for (k=0; k<4; k=k+1) begin
		assign request[j][k] = (j != k);
		end
	end
endgenerate

initial
begin
	m0 = 4'b0001;
	forever #10 m0 = {m0[2:0], m0[3]};
end
endmodule // arbiter_cell_tb