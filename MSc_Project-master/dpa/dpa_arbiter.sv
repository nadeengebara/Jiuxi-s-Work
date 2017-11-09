module dpa_arbiter #(parameter N)(
//	v, //vertical connnection
	request,
	grant,
	mask
	);

input wire [N-1:0][N-1:0] request;
//input wire [N-1:0]in;
inout wire [N-1:0] mask[N+1];
output wire [N-1:0][N-1:0] grant;

wire [N-1:0][N-1:0] left;
wire [N-1:0][N-1:0] up;//intermedia connection
wire [N:0][N-1:0]h;
wire [N-1:0][N:0]v;


genvar i,j;
generate
	for(i=0; i<N; i=i+1) begin: column
		assign v[i][0] = v[i][N];
		assign mask[i+1] = {mask[i][0], mask[i][N-1:1]};//circular shift mask
		for(j=0; j<N; j=j+1) begin: row
			assign h[0][j] = 1'b1;
			assign up[i][j] = v[i][j] | mask[i][j];
			assign left[i][j] = h[i][j] | mask[i][j];
			assign grant[i][j] = left[i][j] & up[i][j] & request[i][j];
			assign h[i+1][j]= ~grant[i][j] & left[i][j];
			assign v[i][j+1] = ~grant[i][j] & up[i][j];
		end
	
	end
endgenerate
endmodule // dpa