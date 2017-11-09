module dpa(
	in,
	out,
	v,
	request,
	grant,
	mask
	);

input wire [N-1:0] request [N-1:0];
inout wire [N:0] mask [N-1:0];
output wire [N-1:0][N-1:0]grant;
wire [N-1:0]up;
genvar i,j;
generate
	up[0] = up[N];
	for(i=0, i<N, i=i+1) begin
		for(j=0, j<N, j=j+1) begin 
		v[j] = up[j] | mask[j];
		assign grant = in[i][j] & up[i][j] & request[i][j];
		assign out = in & ~grant[i][j];
		assign in = ( & ~grant) | ~mask;
		end
	end 

endgenerate