module pri_sel_comb #(parameter N = 4)(
	in,
	out,
	req_out
	);
parameter P = 16;
input wire [$clog2(P)-1:0] in[0:N-1];
output reg [$clog2(P)-1:0] out; //output should be OR of all the input vectors
output reg [N-1:0] req_out;

//reg [$clog2(P)-1:0] data_out[0:N-1]; //this is the real output;
reg [$clog2(P)-1:0] m1;
reg [$clog2(P)-1:0] m2;
reg [$clog2(P)-1:0] m3;

always_comb	begin
	m1 = (in[0] > in[1])? in[0] : in[1];
	m2 = (in[2] > in[3])? in[2] : in[3];
	m3 = (m2 > m1)? m2: m1;
	out = m3;
end

always_comb begin
	for (int i = 0; i < N; i++) begin
		req_out[i] = (m3 == 0)? '0 : ~(|(m3 ^ in[i]));
	end
	
end


endmodule // pri_sel_comb